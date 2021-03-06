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
#import "Core/Utilities/NSData+NPEngine.h"
#import "Graphics/Texture/NPTexture2DArray.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectVariableInt.h"
#import "Graphics/Font/NPFont.h"
#import "Graphics/State/NPStateConfiguration.h"
#import "Graphics/State/NPBlendingState.h"
#import "Graphics/State/NPCullingState.h"
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
    glfwOpenWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_TRUE);
    
    // Open a window and create its OpenGL context
    if( !glfwOpenWindow( 512, 512, 0, 0, 0, 0, 0, 0, GLFW_WINDOW ) )
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
    glClearColor(0.0, 1.0, 0.0, 1.0);

    // create and register log file
    NPLogFile * logFile = AUTORELEASE([[ NPLogFile alloc ] init ]);
    [[ NP Log ] addLogger:logFile ];

    // start up GFX
    if ( [[ NP Graphics ] startup ] == NO )
    {
        NSLog(NPGraphicsStartupError, NSHomeDirectory());
        exit(EXIT_FAILURE);
    }

    [[ NP Graphics ] checkForGLErrors ];
    [[[ NP Core ] timer ] reset ];

    /*
    glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB);
    */

    [[ NP Graphics ] checkForGLErrors ];

    // adopt viewport to current widget size
    NPViewport * viewport = [[ NP Graphics ] viewport ];
    [ viewport setWidgetWidth:widgetSize.x  ];
    [ viewport setWidgetHeight:widgetSize.y ];
    [ viewport reset ];

    NSAutoreleasePool * rPool = [ NSAutoreleasePool new ];

    NPEffect * effect
        = [[[ NPEngineGraphics instance ]
                effects ] getAssetWithFileName:@"default.effect" ];

    assert( effect != nil );

    RETAIN(effect);

    const uint32_t resolution = 4;
    const uint32_t layers = 4;

    FVector4 colors[4] = {{1.0f, 0.0f, 0.0f, 1.0f}, {0.0f, 1.0f, 0.0f, 1.0f}, {0.0f, 0.0f, 1.0f, 1.0f}, {1.0f, 1.0f, 0.0f, 1.0f}};
    FVector4 * textureData = ALLOC_ARRAY(FVector4, resolution * resolution  * layers);

    for ( uint32_t l = 0; l < layers; l++ )
    {
        uint32_t offset = resolution * resolution  * l;

        for ( uint32_t i = 0; i < resolution * resolution; i++ )
        {
            textureData[offset + i] = colors[l];
            printf("%u ", offset + i);
        }

        printf("\n");
    }

    const NSUInteger numberOfBytes
        = resolution * resolution * layers * sizeof(FVector4);

    NSData * data
        = [ NSData dataWithBytesNoCopyNoFree:textureData
                                      length:numberOfBytes ];

    NPTexture2DArray * texture = [[ NPTexture2DArray alloc ] init ];

    [ texture generateUsingWidth:resolution
                          height:resolution
                          layers:layers
                     pixelFormat:NpTexturePixelFormatRGBA
                      dataFormat:NpTextureDataFormatFloat32
                         mipmaps:NO
                            data:data ];

    DESTROY(rPool);

    BOOL running = YES;

    // run loop
    while ( running )
    {
        // create an autorelease pool for every run-loop iteration
        NSAutoreleasePool * innerPool = [ NSAutoreleasePool new ];

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

        //NSLog(@"%lf %d", frameTime, fps);

        // clear context framebuffer
        [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

        [[[ NP Graphics ] textureBindingState ] clear ];
        [[[ NP Graphics ] textureBindingState ] setTexture:texture texelUnit:0 ];
        [[[ NP Graphics ] textureBindingState ] activate ];

        [[ effect techniqueWithName:@"texture" ] activate ];

        glBegin(GL_QUADS);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 0.0f,  0.0f);
            glVertexAttrib2f(NpVertexStreamPositions, -1.0f, -1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 1.0f,  0.0f);
            glVertexAttrib2f(NpVertexStreamPositions,  1.0f, -1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 1.0f,  1.0f);
            glVertexAttrib2f(NpVertexStreamPositions,  1.0f,  1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 0.0f,  1.0f);
            glVertexAttrib2f(NpVertexStreamPositions, -1.0f,  1.0f);
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

    DESTROY(texture);
    DESTROY(effect);

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

