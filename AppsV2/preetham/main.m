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

static Vector3 preetham_zenith(double turbidity, double thetaSun)
{
    // zenith color computation
    // A Practical Analytic Model for Daylight                              
    // page 22/23    

    #define CBQ(X)		((X) * (X) * (X))
    #define SQR(X)		((X) * (X))

    Vector3 zenithColor;

    zenithColor.x
        = ( 0.00166 * CBQ(thetaSun) - 0.00375  * SQR(thetaSun) +
            0.00209 * thetaSun + 0.0f) * SQR(turbidity) +
          (-0.02903 * CBQ(thetaSun) + 0.06377  * SQR(thetaSun) -
            0.03202 * thetaSun  + 0.00394) * turbidity +
          ( 0.11693 * CBQ(thetaSun) - 0.21196  * SQR(thetaSun) +
            0.06052 * thetaSun + 0.25886);

    zenithColor.y
        = ( 0.00275 * CBQ(thetaSun) - 0.00610  * SQR(thetaSun) +
            0.00317 * thetaSun + 0.0) * SQR(turbidity) +
          (-0.04214 * CBQ(thetaSun) + 0.08970  * SQR(thetaSun) -
            0.04153 * thetaSun  + 0.00516) * turbidity  +
          ( 0.15346 * CBQ(thetaSun) - 0.26756  * SQR(thetaSun) +
            0.06670 * thetaSun  + 0.26688);

    zenithColor.z
        = (4.0453 * turbidity - 4.9710) * 
          tan((4.0 / 9.0 - turbidity / 120.0) * (MATH_PI - 2.0 * thetaSun))
          - 0.2155 * turbidity + 2.4192;

    // convert kcd/m² to cd/m²
    zenithColor.z *= 1000.0;

    #undef SQR
    #undef CBQ

    return zenithColor;
}

static double digamma(double theta, double gamma, double ABCDE[5])
{
    const double cosTheta = cos(theta);
    const double cosGamma = cos(gamma);

    const double term_one = 1.0 + ABCDE[0] * exp(ABCDE[1] / cosTheta);
    const double term_two = 1.0 + ABCDE[2] * exp(ABCDE[3] * gamma) + (ABCDE[4] * cosGamma * cosGamma);

    return term_one * term_two;
}

static NSString * const NPGraphicsStartupError = @"NPEngineGraphics failed to start up. Consult %@/np.log for details.";

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
    glfwOpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_COMPAT_PROFILE);
    glfwOpenWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_FALSE);
    
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

    const uint32_t skyResolution = 512;

    NPRenderTargetConfiguration * rtc = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC"  ];
    NPRenderTexture * preethamTarget  = [[ NPRenderTexture alloc ] initWithName:@"Preetham Target"  ];
    NPRenderTexture * luminanceTarget = [[ NPRenderTexture alloc ] initWithName:@"Luminance Target" ];

    [ preethamTarget generate:NpRenderTargetColor
                        width:skyResolution
                       height:skyResolution
                  pixelFormat:NpTexturePixelFormatRGBA
                   dataFormat:NpTextureDataFormatFloat32
                mipmapStorage:NO
                        error:NULL ];

    [ luminanceTarget generate:NpRenderTargetColor
                         width:skyResolution
                        height:skyResolution
                   pixelFormat:NpTexturePixelFormatR
                    dataFormat:NpTextureDataFormatFloat32
                 mipmapStorage:YES
                         error:NULL ];

    [ rtc setWidth:skyResolution  ];
    [ rtc setHeight:skyResolution ];


    NPEffect * effect
        = [[[ NPEngineGraphics instance ]
                effects ] getAssetWithFileName:@"default.effect" ];

    assert( effect != nil );

    RETAIN(effect);

    NPEffectTechnique * preetham = [ effect techniqueWithName:@"preetham" ];
    NPEffectTechnique * texture  = [ effect techniqueWithName:@"texture"  ];

    NPEffectTechnique * logLuminance
        = [ effect techniqueWithName:@"linear_sRGB_to_log_luminance" ];

    assert(preetham != nil && texture != nil && logLuminance != nil);

    RETAIN(preetham);
    RETAIN(texture);
    RETAIN(logLuminance);

    NPEffectVariableFloat * radiusForMaxTheta_P
        = [ effect variableWithName:@"radiusForMaxTheta" ];

    NPEffectVariableFloat3 * directionToSun_P
        = [ effect variableWithName:@"directionToSun" ];

    NPEffectVariableFloat3 * zenithColor_P
        = [ effect variableWithName:@"zenithColor" ];

    NPEffectVariableFloat3 * denominator_P
        = [ effect variableWithName:@"denominator" ];

    NPEffectVariableFloat3 * A_xyY_P = [ effect variableWithName:@"A" ];
    NPEffectVariableFloat3 * B_xyY_P = [ effect variableWithName:@"B" ];
    NPEffectVariableFloat3 * C_xyY_P = [ effect variableWithName:@"C" ];
    NPEffectVariableFloat3 * D_xyY_P = [ effect variableWithName:@"D" ];
    NPEffectVariableFloat3 * E_xyY_P = [ effect variableWithName:@"E" ];

    assert(A_xyY_P != nil && B_xyY_P != nil && C_xyY_P != nil && D_xyY_P != nil
           && E_xyY_P != nil && radiusForMaxTheta_P != nil && directionToSun_P != nil
           && zenithColor_P != nil && denominator_P != nil);

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
    double turbidity = 2.0;
    double phiSun = 0.0;
    double thetaSun = MATH_PI_DIV_4;

    const float halfSkyResolution = ((float)skyResolution) / (2.0f);

    const float cStart = -halfSkyResolution;
    const float cEnd   =  halfSkyResolution;

    const double infinity = log(0.0);

    printf("\n%lf\n", MAX(infinity, 0.0));

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

        if ([ wheelUp activated ] == YES )
        {
            thetaSun += MATH_DEG_TO_RAD * 3.0;
        }

        if ([ wheelDown activated ] == YES )
        {
            thetaSun -= MATH_DEG_TO_RAD * 3.0;
        }

        thetaSun = MIN(thetaSun, MATH_PI_DIV_2);
        thetaSun = MAX(thetaSun, 0.1);

        //
        const double maxThetaRadius = halfSkyResolution;
        const double sinThetaSun = sin(thetaSun);
        const double cosThetaSun = cos(thetaSun);
        const double sinPhiSun = sin(phiSun);
        const double cosPhiSun = cos(phiSun);

        Vector3 directionToSun;
        directionToSun.x = maxThetaRadius * sinThetaSun * cosPhiSun;
        directionToSun.y = maxThetaRadius * sinThetaSun * sinPhiSun;
        directionToSun.z = maxThetaRadius * cosThetaSun;
        Vector3 directionToSunNormalised = v3_v_normalised(&directionToSun);

        // Preetham Skylight Zenith color
        // xyY space, cd/m²
        Vector3 zenithColor = preetham_zenith(turbidity, thetaSun);

        // Page 22/23 compute coefficients
	    double ABCDE_x[5], ABCDE_y[5], ABCDE_Y[5];

	    ABCDE_x[0] = -0.01925 * turbidity - 0.25922;
	    ABCDE_x[1] = -0.06651 * turbidity + 0.00081;
	    ABCDE_x[2] = -0.00041 * turbidity + 0.21247;
	    ABCDE_x[3] = -0.06409 * turbidity - 0.89887;
	    ABCDE_x[4] = -0.00325 * turbidity + 0.04517;

	    ABCDE_y[0] = -0.01669 * turbidity - 0.26078;
	    ABCDE_y[1] = -0.09495 * turbidity + 0.00921;
	    ABCDE_y[2] = -0.00792 * turbidity + 0.21023;
	    ABCDE_y[3] = -0.04405 * turbidity - 1.65369;
	    ABCDE_y[4] = -0.01092 * turbidity + 0.05291;

	    ABCDE_Y[0] =  0.17872 * turbidity - 1.46303;
	    ABCDE_Y[1] = -0.35540 * turbidity + 0.42749;
	    ABCDE_Y[2] = -0.02266 * turbidity + 5.32505;
	    ABCDE_Y[3] =  0.12064 * turbidity - 2.57705;
	    ABCDE_Y[4] = -0.06696 * turbidity + 0.37027;

        // Page 9 eq. 4, precompute F(0, thetaSun)
        Vector3 denominator;
        denominator.x = digamma(0.0, thetaSun, ABCDE_x);
        denominator.y = digamma(0.0, thetaSun, ABCDE_y);
        denominator.z = digamma(0.0, thetaSun, ABCDE_Y);

        const FVector3 A = { ABCDE_x[0], ABCDE_y[0], ABCDE_Y[0] };
        const FVector3 B = { ABCDE_x[1], ABCDE_y[1], ABCDE_Y[1] };
        const FVector3 C = { ABCDE_x[2], ABCDE_y[2], ABCDE_Y[2] };
        const FVector3 D = { ABCDE_x[3], ABCDE_y[3], ABCDE_Y[3] };
        const FVector3 E = { ABCDE_x[4], ABCDE_y[4], ABCDE_Y[4] };

        [ A_xyY_P setFValue:A ];
        [ B_xyY_P setFValue:B ];
        [ C_xyY_P setFValue:C ];
        [ D_xyY_P setFValue:D ];
        [ E_xyY_P setFValue:E ];

        [ radiusForMaxTheta_P setFValue:halfSkyResolution ];
        [ directionToSun_P setValue:directionToSunNormalised ];
        [ zenithColor_P setValue:zenithColor ];
        [ denominator_P setValue:denominator ];

        // clear preetham target
        [ rtc bindFBO ];

        [ preethamTarget
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:0
                                      bindFBO:NO ];

        [ rtc activateDrawBuffers ];
        [ rtc activateViewport ];

        const FVector4 clearColor = {.x = 1.0f, .y = 0.0f, .z = 0.0f, .w = 0.0f};
        [[ NP Graphics ] clearDrawBuffer:0 color:clearColor ];

        [ preetham activate ];

        glBegin(GL_QUADS);
            glVertexAttrib2f(NpVertexStreamTexCoords0, cStart, cStart);
            glVertexAttrib2f(NpVertexStreamPositions, -1.0f, -1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, cEnd, cStart);
            glVertexAttrib2f(NpVertexStreamPositions,  1.0f, -1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, cEnd,  cEnd);
            glVertexAttrib2f(NpVertexStreamPositions,  1.0f,  1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, cStart,  cEnd);
            glVertexAttrib2f(NpVertexStreamPositions, -1.0f,  1.0f);
        glEnd();

        [ preethamTarget detach:NO ];

        [ luminanceTarget
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:0
                                      bindFBO:NO ];

        [[ NP Graphics ] clearDrawBuffer:0 color:clearColor ];

        [[[ NP Graphics ] textureBindingState ] setTexture:[ preethamTarget texture ] texelUnit:0 ];
        [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

        [ logLuminance activate ];

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

        [ luminanceTarget detach:NO ];

        [ rtc deactivate ];

        const int32_t numberOfLevels
            = 1 + (int32_t)floor(logb(skyResolution));

        [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:[ luminanceTarget texture ]];

        float averageLuminance = FLT_MAX;

        glGenerateMipmap(GL_TEXTURE_2D);
        glGetTexImage(GL_TEXTURE_2D, numberOfLevels - 1, GL_RED, GL_FLOAT, &averageLuminance);

        [[[ NP Graphics ] textureBindingState ] restoreOriginalTextureImmediately ];

        NSLog(@"%f %f", averageLuminance, expf(averageLuminance));

        // activate culling, depth write and depth test
        NPCullingState * cullingState = [[[ NP Graphics ] stateConfiguration ] cullingState ];
        NPBlendingState * blendingState = [[[ NP Graphics ] stateConfiguration ] blendingState ];
        NPDepthTestState * depthTestState = [[[ NP Graphics ] stateConfiguration ] depthTestState ];
        NPStencilTestState * stencilTestState = [[[ NP Graphics ] stateConfiguration ] stencilTestState ];

        [ blendingState  setEnabled:NO ];
        [ cullingState   setCullFace:NpCullfaceBack ];
        [ cullingState   setEnabled:YES ];
        [ depthTestState setWriteEnabled:YES ];
        [ depthTestState setEnabled:YES ];
        [[[ NP Graphics ] stateConfiguration ] activate ];

        // clear context framebuffer
        [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

        [[[ NP Graphics ] textureBindingState ] clear ];
        [[[ NP Graphics ] textureBindingState ] setTexture:[ luminanceTarget texture ] texelUnit:0 ];
        [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

        [ texture activate ];

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

    DESTROY(leftClick);
    DESTROY(rightClick);
    DESTROY(wheelUp);
    DESTROY(wheelDown);

    DESTROY(logLuminance);
    DESTROY(preetham);
    DESTROY(texture);
    DESTROY(effect);

    DESTROY(rtc);
    DESTROY(preethamTarget);
    DESTROY(luminanceTarget);

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

