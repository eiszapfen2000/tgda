#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <math.h>
#import <stdlib.h>
#import <time.h>
#import <Foundation/NSException.h>
#import <Foundation/NSPointerArray.h>
#import <Foundation/Foundation.h>
#import "Log/NPLogFile.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Thread/NPSemaphore.h"
#import "Core/Timer/NPTimer.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "Graphics/Geometry/NPCPUVertexArray.h"
#import "Graphics/Geometry/NPVertexArray.h"
#import "Graphics/Model/NPSUX2Model.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Font/NPFont.h"
#import "Graphics/State/NPStateConfiguration.h"
#import "Graphics/State/NPBlendingState.h"
#import "Graphics/State/NPDepthTestState.h"
#import "Graphics/NPViewport.h"
#import "Graphics/NPOrthographic.h"
#import "Input/NPKeyboard.h"
#import "Input/NPMouse.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "NP.h"
#import "GL/glew.h"
#import "GL/glfw.h"

NpKeyboardState keyboardState;
NpMouseState mouseState;
IVector2 mousePosition;
IVector2 widgetSize;

static void GLFWCALL keyboard_callback(int key, int state)
{
    keyboardState.keys[key] = state;
}

static void GLFWCALL mouse_pos_callback(int x, int y)
{
    mousePosition.x = x;
    mousePosition.y = y;
}

static void mouse_button_callback(int button, int state)
{
    mouseState.buttons[button] = state;
}

static void GLFWCALL mouse_wheel_callback(int wheel)
{
    mouseState.scrollWheel = wheel;
}

static void GLFWCALL window_resize_callback(int width, int height)
{
    widgetSize.x = width;
    widgetSize.y = height;
}

static double G_zero(double sigma, int32_t n, double deltaQ)
{
    double result = 0.0;

    for (int32_t i = 0; i < n; i++)
    {
        double di = (double)i;
        double qn = di * deltaQ;
        double qnSquare = qn * qn;

        result += qnSquare * exp(-1.0 * sigma * qnSquare);        
    }

    return result;
}

static void G(int32_t P, double sigma, int32_t n, double deltaQ, double ** kernel)
{
    assert(kernel != NULL);

    const int32_t kernelSize = 2 * P + 1;
    const double gZero = G_zero(sigma, n, deltaQ);

    *kernel = ALLOC_ARRAY(double, kernelSize * kernelSize);

    for (int32_t k = -P; k < P + 1; k++)
    {
        for (int32_t l = -P; l < P + 1; l++)
        {
            const double dl = (double)l;
            const double dk = (double)k;
            const double r = sqrt(dk * dk + dl * dl);

            double element = 0.0;

            for (int32_t i = 0; i < n; i++)
            {
                double di = (double)i;
                double qn = di * deltaQ;
                double qnSquare = qn * qn;

                element += qnSquare * exp(-1.0 * sigma * qnSquare) * j0(r * qn);
            }

            const int32_t indexk = k + P;
            const int32_t indexl = l + P;
            const int32_t index = indexk * kernelSize + indexl;

            (*kernel)[index] = element / gZero;
        }
    }
}

static NSString * const NPGraphicsStartupError = @"NPEngineGraphics failed to start up. Consult %@/np.log for details.";

int main (int argc, char **argv)
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    // Initialise GLFW
    if( !glfwInit() )
    {
        NSLog(@"Failed to initialize GLFW");
        exit(EXIT_FAILURE);
    }

    // do not allow window resizing
    glfwOpenWindowHint(GLFW_WINDOW_NO_RESIZE, GL_TRUE);
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MAJOR, 3);
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MINOR, 3);
    // glew needs compatibility profile
    glfwOpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_COMPAT_PROFILE);
    glfwOpenWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_FALSE);
    
    // Open a window and create its OpenGL context
    if( !glfwOpenWindow( 800, 600, 0, 0, 0, 0, 0, 0, GLFW_WINDOW ) )
    {
        NSLog(@"Failed to open GLFW window");
        glfwTerminate();
        exit(EXIT_FAILURE);
    }

    // initialise keyboard and mouse state
    keyboardstate_reset(&keyboardState);
    mousestate_reset(&mouseState);
    mousePosition.x = mousePosition.y = 0;

    // VSync
    glfwSwapInterval(0);
    // do not poll events on glfwSwapBuffers
    glfwDisable(GLFW_AUTO_POLL_EVENTS);
    // register keyboard callback
    glfwSetKeyCallback(keyboard_callback);
    // register mouse callbacks
    glfwSetMousePosCallback(mouse_pos_callback);
    glfwSetMouseButtonCallback(mouse_button_callback);
    glfwSetMouseWheelCallback(mouse_wheel_callback);
    // callback for window resizes
    glfwSetWindowSizeCallback(window_resize_callback);

    glClearDepth(1);
    glClearStencil(0);

    // create and register log file
    NPLogFile * logFile = AUTORELEASE([[ NPLogFile alloc ] init ]);
    [[ NP Log ] addLogger:logFile ];

    // start up GFX
    if ( [[ NP Graphics ] startup ] == NO )
    {
        NSLog(NPGraphicsStartupError, NSHomeDirectory());
        exit(EXIT_FAILURE);
    }

    double * result = NULL;
    G(6, 1.0, 10000, 0.001,&result);
    SAFE_FREE(result);

    [[ NP Graphics ] checkForGLErrors ];
    [[[ NP Core ] timer ] reset ];


    const int32_t gridWidth  = 400;
    const int32_t gridHeight = 300;

    float * heights     = ALLOC_ARRAY(float, gridWidth * gridHeight);
    float * prevHeights = ALLOC_ARRAY(float, gridWidth * gridHeight);
    float * derivative  = ALLOC_ARRAY(float, gridWidth * gridHeight);
    float * source      = ALLOC_ARRAY(float, gridWidth * gridHeight);
    float * obstruction = ALLOC_ARRAY(float, gridWidth * gridHeight);

    memset(heights,     0, sizeof(float) * gridWidth * gridHeight);
    memset(prevHeights, 0, sizeof(float) * gridWidth * gridHeight);
    memset(derivative,  0, sizeof(float) * gridWidth * gridHeight);
    memset(source,      0, sizeof(float) * gridWidth * gridHeight);

    for (int32_t i = 0; i < gridWidth * gridHeight; i++)
    {
        obstruction[i] = 1.0f;
    }

    NSAutoreleasePool * rPool = [ NSAutoreleasePool new ];


    NSData * heightData
        = [ NSData dataWithBytesNoCopy:heights
                                length:sizeof(float) * gridWidth * gridHeight
                          freeWhenDone:NO ];

    NPTexture2D * texture = [[ NPTexture2D alloc ] initWithName:@"GridTexture" ];
    [ texture generateUsingWidth:gridWidth
                          height:gridHeight
                     pixelFormat:NpTexturePixelFormatR
                      dataFormat:NpTextureDataFormatFloat32
                         mipmaps:NO
                            data:heightData ];

    NPEffect * effect
        = [[[ NPEngineGraphics instance ]
                effects ] getAssetWithFileName:@"default.effect" ];

    RETAIN(effect);

    DESTROY(rPool);

    BOOL running = YES;

    // run loop
    while ( running )
    {
        // create an autorelease pool for every run-loop iteration
        NSAutoreleasePool * innerPool = [ NSAutoreleasePool new ];

        // adopt viewport to current widget size
        NPViewport * viewport = [[ NP Graphics ] viewport ];
        [ viewport setWidgetWidth:widgetSize.x  ];
        [ viewport setWidgetHeight:widgetSize.y ];
        [ viewport reset ];

        // push current keyboard and mouse state into NPInput
        [[[ NP Input ] keyboard ] setKeyboardState:&keyboardState ];
        [[[ NP Input ] mouse ] setMouseState:&mouseState ];
        [[[ NP Input ] mouse ] setMousePosition:mousePosition ];

        // update NPEngineInput's internal state (actions)
        [[ NP Input ] update ];

        // update NPEngineCore
        [[ NP Core ] update ];

        // get current frametime
        const double frameTime = [[[ NP Core ] timer ] frameTime ];
        const int32_t fps = [[[ NP Core ] timer ] fps ];

        [[[ NP Graphics ] textureBindingState ] setTexture:texture texelUnit:0 ];
        [[ effect techniqueWithName:@"texture"] activate ];

        glBegin(GL_QUADS);
            glTexCoord2f(0.0f, 0.0f);
            glVertex4f(-1.0f, -1.0f, 0.0f, 1.0f);
            glTexCoord2f(1.0f, 0.0f);
            glVertex4f(1.0f, -1.0f, 0.0f, 1.0f);
            glTexCoord2f(1.0f, 1.0f);
            glVertex4f(1.0f, 1.0f, 0.0f, 1.0f);
            glTexCoord2f(0.0f, 1.0f);
            glVertex4f(-1.0f, 1.0f, 0.0f, 1.0f);
        glEnd();

        // check for GL errors
        [[ NP Graphics ] checkForGLErrors ];

        // swap front and back rendering buffers
        glfwSwapBuffers();

        // poll events, callbacks for mouse and keyboard
        // are called automagically
        // we need to call this here, because only this way
        // window closing events are processed
        glfwPollEvents();

        // check if window was closed
        running = running && glfwGetWindowParam( GLFW_OPENED );

        // kill autorelease pool
        DESTROY(innerPool);
    }

    DESTROY(effect);
    DESTROY(texture);

    FREE(heights);
    FREE(prevHeights);
    FREE(derivative);
    FREE(source);
    FREE(obstruction);

    // Shutdown NPGraphics, deallocates a lot of stuff
    [[ NP Graphics ] shutdown ];

    // Close OpenGL window and terminate GLFW
    glfwTerminate();

    // Kill singletons by force, sending them
    // "release" would have no effect
    
    [[ NP Input    ] dealloc ];
    [[ NP Graphics ] dealloc ];
    [[ NP Core     ] dealloc ];
    [[ NP Log      ] dealloc ];
    

    DESTROY(pool);

    return EXIT_SUCCESS;
}

