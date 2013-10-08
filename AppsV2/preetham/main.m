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
#import "Graphics/Texture/NPTextureBuffer.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectVariableInt.h"
#import "Graphics/Font/NPFont.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
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
    glClearColor(0.0, 0.0, 0.0, 0.0);

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

    /*
    NPTexture2D * sourceTexture      = [[ NPTexture2D alloc ] initWithName:@"Source" ];
    NPTexture2D * obstructionTexture = [[ NPTexture2D alloc ] initWithName:@"Obstruction" ];
    NPTexture2D * depthTexture       = [[ NPTexture2D alloc ] initWithName:@"Depth" ];

    NPBufferObject  * kernelBuffer  = [[ NPBufferObject alloc ]  initWithName:@"Kernel BO" ];
    NPTextureBuffer * kernelTexture = [[ NPTextureBuffer alloc ] initWithName:@"Kernel TB" ];

    NPRenderTexture * heightsTarget         = [[ NPRenderTexture alloc ] initWithName:@"Height Target"           ];
    NPRenderTexture * prevHeightsTarget     = [[ NPRenderTexture alloc ] initWithName:@"Prev Height Target"      ];
    NPRenderTexture * depthDerivativeTarget = [[ NPRenderTexture alloc ] initWithName:@"Depth Derivative Target" ];
    NPRenderTexture * derivativeTarget      = [[ NPRenderTexture alloc ] initWithName:@"Derivative Target"       ];
    NPRenderTexture * tempTarget            = [[ NPRenderTexture alloc ] initWithName:@"Temp Target"             ];

    NPRenderTargetConfiguration * rtc = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC" ];
    NPRenderTargetConfiguration * rtcCopy = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC Copy" ];

    BOOL allok
        = [ kernelBuffer
               generate:NpBufferObjectTypeTexture
             updateRate:NpBufferDataUpdateOnceUseOften
              dataUsage:NpBufferDataWriteCPUToGPU
             dataFormat:NpBufferDataFormatFloat32
             components:1
                   data:kernelData
             dataLength:[ kernelData length ]
                  error:NULL ];

    assert(allok == YES);

    [ kernelTexture attachBuffer:kernelBuffer
                numberOfElements:kernelSize * kernelSize
                     pixelFormat:NpTexturePixelFormatR
                      dataFormat:NpTextureDataFormatFloat32 ];

    [ heightsTarget generate:NpRenderTargetColor
                       width:gridWidth
                      height:gridHeight
                 pixelFormat:NpTexturePixelFormatR
                  dataFormat:NpTextureDataFormatFloat32
               mipmapStorage:NO
                       error:NULL ];

    [ prevHeightsTarget generate:NpRenderTargetColor
                           width:gridWidth
                          height:gridHeight
                     pixelFormat:NpTexturePixelFormatR
                      dataFormat:NpTextureDataFormatFloat32
                   mipmapStorage:NO
                           error:NULL ];

    [ depthDerivativeTarget generate:NpRenderTargetColor
                               width:gridWidth
                              height:gridHeight
                         pixelFormat:NpTexturePixelFormatR
                          dataFormat:NpTextureDataFormatFloat32
                       mipmapStorage:NO
                               error:NULL ];

    [ derivativeTarget generate:NpRenderTargetColor
                          width:gridWidth
                         height:gridHeight
                    pixelFormat:NpTexturePixelFormatR
                     dataFormat:NpTextureDataFormatFloat32
                  mipmapStorage:NO
                          error:NULL ];

    [ tempTarget generate:NpRenderTargetColor
                    width:gridWidth
                   height:gridHeight
              pixelFormat:NpTexturePixelFormatR
               dataFormat:NpTextureDataFormatFloat32
            mipmapStorage:NO
                    error:NULL ];

    [ rtc setWidth:gridWidth ];
    [ rtc setHeight:gridHeight ];

    [ rtc bindFBO ];

    [ heightsTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:0
                                  bindFBO:NO ];

    [ prevHeightsTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:1
                                  bindFBO:NO ];

    [ derivativeTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:2
                                  bindFBO:NO ];

    [ depthDerivativeTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:3
                                  bindFBO:NO ];

    [ tempTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:4
                                  bindFBO:NO ];

    [ rtc activateDrawBuffers ];
    [ rtc activateViewport ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [ tempTarget            detach:NO ];
    [ depthDerivativeTarget detach:NO ];
    [ derivativeTarget      detach:NO ];
    [ prevHeightsTarget     detach:NO ];
    [ heightsTarget         detach:NO ];

    [ rtc deactivate ];
    */


    NPEffect * effect
        = [[[ NPEngineGraphics instance ]
                effects ] getAssetWithFileName:@"default.effect" ];

    assert( effect != nil );

    RETAIN(effect);

    NPInputAction * leftClick
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"LeftClick"
                            inputEvent:NpMouseButtonLeft ];

    NPInputAction * rightClick
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"RightClick"
                            inputEvent:NpMouseButtonRight ];

    NPInputAction * wheelUp
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"WheelUp"
                            inputEvent:NpMouseWheelUp ];

    NPInputAction * wheelDown
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"WheelDown"
                            inputEvent:NpMouseWheelDown ];

    RETAIN(leftClick);
    RETAIN(rightClick);
    RETAIN(wheelUp);
    RETAIN(wheelDown);

    DESTROY(rPool);

    BOOL running = YES;
    double deltaTime = 0.0;

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

        //NSLog(@"%lf", frameTime);

        NPCullingState * cullingState = [[[ NP Graphics ] stateConfiguration ] cullingState ];
        NPBlendingState * blendingState = [[[ NP Graphics ] stateConfiguration ] blendingState ];
        NPDepthTestState * depthTestState = [[[ NP Graphics ] stateConfiguration ] depthTestState ];
        NPStencilTestState * stencilTestState = [[[ NP Graphics ] stateConfiguration ] stencilTestState ];

        // activate culling, depth write and depth test
        [ blendingState  setEnabled:NO ];
        [ cullingState   setCullFace:NpCullfaceBack ];
        [ cullingState   setEnabled:YES ];
        [ depthTestState setWriteEnabled:YES ];
        [ depthTestState setEnabled:YES ];
        [[[ NP Graphics ] stateConfiguration ] activate ];

        [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

        /*
        [[[ NP Graphics ] textureBindingState ] setTexture:[ heightsTarget texture ] texelUnit:0 ];
        [[[ NP Graphics ] textureBindingState ] setTexture:sourceTexture      texelUnit:1 ];
        [[[ NP Graphics ] textureBindingState ] setTexture:obstructionTexture texelUnit:2 ];
        [[[ NP Graphics ] textureBindingState ] setTexture:depthTexture       texelUnit:3 ];
        [[[ NPEngineGraphics instance ] textureBindingState ] activate ];
        [[ effect techniqueWithName:@"fluid"] activate ];

        glBegin(GL_QUADS);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 0.0f, 0.0f);
            glVertex4f(-1.0f, -1.0f, 0.0f, 1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 1.0f, 0.0f);
            glVertex4f( 1.0f, -1.0f, 0.0f, 1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 1.0f, 1.0f);
            glVertex4f( 1.0f,  1.0f, 0.0f, 1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 0.0f, 1.0f);
            glVertex4f(-1.0f,  1.0f, 0.0f, 1.0f);
        glEnd(); 
        */      

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

    DESTROY(leftClick);
    DESTROY(rightClick);
    DESTROY(wheelUp);
    DESTROY(wheelDown);

    DESTROY(effect);

    /*
    DESTROY(rtc);
    DESTROY(derivativeTarget);
    DESTROY(depthDerivativeTarget);
    DESTROY(prevHeightsTarget);
    DESTROY(heightsTarget);
    DESTROY(tempTarget);

    DESTROY(sourceTexture);
    DESTROY(obstructionTexture);
    DESTROY(depthTexture);
    DESTROY(kernelTexture);
    DESTROY(kernelBuffer);
    */

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

