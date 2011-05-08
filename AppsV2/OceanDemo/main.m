#import <Foundation/Foundation.h>
#import "Log/NPLogFile.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Timer/NPTimer.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Geometry/NPVertexArray.h"
#import "Graphics/Model/NPSUX2Model.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/NPViewport.h"
#import "Input/NPKeyboard.h"
#import "Input/NPMouse.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "NP.h"
#import "ODCamera.h"
#import "GL/glfw.h"

NpKeyboardState keyboardState;
NpMouseState mouseState;
IVector2 mousePosition;

void GLFWCALL keyboard_callback(int key, int state)
{
    keyboardState.keys[key] = state;
}

void GLFWCALL mouse_pos_callback(int x, int y)
{
    mousePosition.x = x;
    mousePosition.y = y;
}

void mouse_button_callback(int button, int state)
{
    mouseState.buttons[button] = state;
}

void GLFWCALL mouse_wheel_callback(int wheel)
{
    mouseState.scrollWheel = wheel;
}

int windowWidth, windowHeight;
void GLFWCALL window_resize_callback(int width, int height)
{
    windowWidth = width;
    windowHeight = height;
}

int running = GL_TRUE;

int main (int argc, char **argv)
{
    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    // register log file
    NPLogFile * logFile = AUTORELEASE([[ NPLogFile alloc ] init ]);
    [[ NP Log ] addLogger:logFile ];

    // Initialise GLFW
    if( !glfwInit() )
    {
        NSLog(@"Failed to initialize GLFW");
        exit( EXIT_FAILURE );
    }

    // do not allow window resizing
    glfwOpenWindowHint(GLFW_WINDOW_NO_RESIZE, GL_TRUE);

    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MAJOR, 3);
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MINOR, 2);
//    glfwOpenWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwOpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_COMPAT_PROFILE);
    
    // Open a window and create its OpenGL context
    if( !glfwOpenWindow( 640, 480, 0, 0, 0, 0, 0, 0, GLFW_WINDOW ) )
    {
        NSLog(@"Failed to open GLFW window");
        glfwTerminate();
        exit( EXIT_FAILURE );
    }

    int d = glfwGetWindowParam(GLFW_DEPTH_BITS);
    NSLog(@"%d", d);

    int major = glfwGetWindowParam(GLFW_OPENGL_VERSION_MAJOR);
    int minor = glfwGetWindowParam(GLFW_OPENGL_VERSION_MINOR);
    NSLog(@"%d . %d", major, minor);

    int profile = glfwGetWindowParam(GLFW_OPENGL_PROFILE);
    NSLog(@"Got profile %d", profile);

    // callback for window resizes
    glfwSetWindowSizeCallback(window_resize_callback);

    // initialise keyboard and mouse state
    keyboardstate_reset(&keyboardState);
    reset_mouse_state(&mouseState);
    mousePosition.x = mousePosition.y = 0;

    // VSync
    glfwSwapInterval(1);
    // do not poll events on glfwSwapBuffers
    glfwDisable(GLFW_AUTO_POLL_EVENTS);
    // register keyboard callback
    glfwSetKeyCallback(keyboard_callback);
    // register mouse callbacks
    glfwSetMousePosCallback(mouse_pos_callback);
    glfwSetMouseButtonCallback(mouse_button_callback);
    glfwSetMouseWheelCallback(mouse_wheel_callback);

    if ( [[ NP Graphics ] startup ] == NO )
    {
        NSLog(@"GFX BRAK");
    }

    [[[ NP Graphics ] viewport ] setWidgetWidth:640 ];
    [[[ NP Graphics ] viewport ] setWidgetHeight:480 ];
    [[[ NP Graphics ] viewport ] reset ];

    NSAutoreleasePool * innerPool = [[ NSAutoreleasePool alloc ] init ];
    NPEffect * e = RETAIN([[[ NP Graphics ] effects ] getAssetWithFileName:@"test.effect" ]);
    NPEffectTechnique * t = [ e techniqueWithName:@"texture" ];

    NSDictionary * arguments = [ NSDictionary dictionaryWithObject:@"YES" forKey:@"sRGB" ];
    NPTexture2D * tex = RETAIN([[[ NP Graphics ] textures2D ] getAssetWithFileName:@"editorobjects.jpg" arguments:arguments]);
    if ( tex == nil )
    {
        NSLog(@"KBUMM");
    }

    [ tex setTextureFilter:NpTexture2DFilterTrilinear ];

    [[ NP Graphics ] checkForGLErrors ];

    NPSUX2Model * model = [[ NPSUX2Model alloc ] init ];
    BOOL modelResult = [ model loadFromFile:@"skybox.model" arguments:NULL error:NULL ];
    if ( modelResult == NO )
    {
        NSLog(@"MODEL FAUIL");
    }

    float vertices[12] = {-0.5f, -0.5f, 0.5f, -0.5f, 0.5f, 0.5f, 0.5f, 0.5f, -0.5f, 0.5f, -0.5f, -0.5f};
    float texcoords[12] = {0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 0.0f};
    uint16_t indices[6] = {0, 1, 2, 3, 4, 5};

    NSData * vData = [ NSData dataWithBytes:vertices length:sizeof(vertices) ];
    NSData * tData = [ NSData dataWithBytes:texcoords length:sizeof(texcoords) ];
    NSData * iData = [ NSData dataWithBytes:indices length:sizeof(indices) ];

    NPBufferObject * vBuffer = [[ NPBufferObject alloc ] init ];
    NPBufferObject * tBuffer = [[ NPBufferObject alloc ] init ];
    NPBufferObject * iBuffer = [[ NPBufferObject alloc ] init ];

    BOOL vOK =
    [ vBuffer generate:NpBufferObjectTypeGeometry
            updateRate:NpBufferDataUpdateOnceUseOften
             dataUsage:NpBufferDataWriteCPUToGPU
            dataFormat:NpBufferDataFormatFloat32
            components:2
                  data:vData
            dataLength:[ vData length ]
                 error:NULL ];

    BOOL tOK =
    [ tBuffer generate:NpBufferObjectTypeGeometry
            updateRate:NpBufferDataUpdateOnceUseOften
             dataUsage:NpBufferDataWriteCPUToGPU
            dataFormat:NpBufferDataFormatFloat32
            components:2
                  data:tData
            dataLength:[ tData length ]
                 error:NULL ];

    BOOL iOK =
    [ iBuffer generate:NpBufferObjectTypeIndices
            updateRate:NpBufferDataUpdateOnceUseOften
             dataUsage:NpBufferDataWriteCPUToGPU
            dataFormat:NpBufferDataFormatUInt16
            components:1
                  data:iData
            dataLength:[ iData length ]
                 error:NULL ];


    if ( vOK == NO || tOK == NO || iOK == NO )
    {
        NSLog(@"BUFFERFAIL");
    }

    NPVertexArray * vertexArray = [[ NPVertexArray alloc ] init ];
    BOOL rak = [ vertexArray addVertexStream:vBuffer atLocation:NpVertexStreamAttribute0 error:NULL ];
    rak = rak && [ vertexArray addVertexStream:tBuffer atLocation:NpVertexStreamAttribute3 error:NULL ];
    rak = rak && [ vertexArray addIndexStream:iBuffer error:NULL ];

    if ( rak == NO )
    {
        NSLog(@"FUCK");
    }

    [[ NP Graphics ] checkForGLErrors ];

    ODCamera * camera = [[ ODCamera alloc ] init ];

    while ( running )
    {
        // poll events, callbacks for mouse and keyboard
        // are called automagically
        glfwPollEvents();

        // push current keyboard and mouse state into NPInput
        [[[ NP Input ] keyboard ] setKeyboardState:&keyboardState ];
        [[[ NP Input ] mouse ] setMouseState:mouseState ];
        [[[ NP Input ] mouse ] setMousePosition:mousePosition ];
        // Update NPInput's internal state (actions)
        [[ NP Input ] update ];

        [[ NP Core ] update ];
        float frameTime = [[[ NP Core ] timer ] frameTime ];

        [ camera update:frameTime ];

        // Do GL stuff
        glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

        [[[ NP Core ] transformationState ] setViewMatrix:[ camera view ]];
        [[[ NP Core ] transformationState ] setProjectionMatrix:[ camera projection ]];

        [[[ NP Graphics ] textureBindingState ] setTexture:tex texelUnit:0 ];
        [[[ NP Graphics ] textureBindingState ] activate ];
        [ t activate ];

        [ vertexArray renderWithPrimitiveType:NpPrimitiveTriangles ];

        //[ model render ];

        // Check for GL errors
        [[ NP Graphics ] checkForGLErrors ];

        // Swap front and back rendering buffers
        glfwSwapBuffers();
        // Check if ESC key was pressed or window was closed
        running = running && glfwGetWindowParam( GLFW_OPENED );
    }

    DESTROY(model);
    DESTROY(vertexArray);

    RELEASE(tex);
    RELEASE(e);

    DESTROY(iBuffer);
    DESTROY(vBuffer);
    DESTROY(tBuffer);

    [ innerPool release ];

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

    //DESTROY(logFile);

    [ pool release ];

    return EXIT_SUCCESS;
}

