#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
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
#import "Entities/ODPerlinNoise.h"
#import "Entities/Ocean/ODPFrequencySpectrumGeneration.h"
#import "Menu/ODMenu.h"
#import "ODScene.h"
#import "GL/glew.h"
#import "GL/glfw.h"

IVector2 widgetSize;
IVector2 mousePosition;

NpMouseState mouseState;
NpKeyboardState keyboardState;

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

int main (int argc, char **argv)
{
    //feenableexcept(FE_DIVBYZERO | FE_INVALID);

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
    glfwOpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwOpenWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_TRUE);
    
    // Open a window and create its OpenGL context
    if( !glfwOpenWindow( 1280, 720, 0, 0, 0, 0, 0, 0, GLFW_WINDOW ) )
    {
        NSLog(@"Failed to open GLFW window");
        glfwTerminate();
        exit(EXIT_FAILURE);
    }

    glClearDepth(1);
    glClearStencil(0);

    // callback for window resizes
    glfwSetWindowSizeCallback(window_resize_callback);

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

    // create and register log file
    NPLogFile * logFile = AUTORELEASE([[ NPLogFile alloc ] init ]);
    [[ NP Log ] addLogger:logFile ];

    // add content subdirectory to lookup paths
    NSString * contentPath =
        [[[ NSFileManager defaultManager ] currentDirectoryPath ]
                stringByAppendingPathComponent:@"Content" ];

    [[[ NP Core ] localPathManager ] addLookUpPath:contentPath ];

    // start up GFX
    if ( [[ NP Graphics ] startup ] == NO )
    {
        NSLog(@"NPEngineGraphics failed to start up. Consult %@/np.log for details.",  NSHomeDirectory());
        exit(EXIT_FAILURE);
    }

    //glDisable(GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB);
    //glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB);

    // resource loading creates a lot of temporary objects, so we
    // create an autorelease pool right for that task and
    // release it afterwards, but before we enter the main loop
    NSAutoreleasePool * resourcePool = [ NSAutoreleasePool new ];

    NSError * sceneError = nil;
    ODScene * scene = [[ ODScene alloc ] init ];

    if ( [ scene loadFromFile:@"test.scene"
                    arguments:nil
                        error:&sceneError ] == NO )
    {
        NPLOG_ERROR(sceneError);
    }

    [[ NP Graphics ] checkForGLErrors ];

    NSError * menuError = nil;
    ODMenu * menu = [[ ODMenu alloc ] init ];

    if ( [ menu loadFromFile:@"test.menu"
                   arguments:nil
                       error:&menuError ] == NO )
    {
        NPLOG_ERROR(menuError);
    }

    [[ NP Graphics ] checkForGLErrors ];

    // delete all autoreleased objects created during resource loading
    DESTROY(resourcePool);

    [[[ NP Core ] timer ] reset ];

    int running = GL_TRUE;

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

        //NSLog(@"%d", fps);

        // update scene
        [ scene update:frameTime ];

        // update menu
        [ menu update:frameTime ];

        // scene render
        [ scene render ];

        // menu
        [ menu render ];

        // check for debug messages
        //[[ NP Graphics ] checkForDebugMessages ];

        // check for GL errors
        [[ NP Graphics ] checkForGLErrors ];

        // swap front and back rendering buffers
        glfwSwapBuffers();

        // poll events, callbacks for mouse and keyboard
        // are called automagically
        // we need to call this here, because only this way
        // window closing events are processed
        glfwPollEvents();

        // check if ESC key was pressed or window was closed
        running = running && glfwGetWindowParam( GLFW_OPENED );

        // kill autorelease pool
        DESTROY(innerPool);
    }

    DESTROY(scene);
    DESTROY(menu);

    // delete static data
    [ ODScene shutdown ];

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

