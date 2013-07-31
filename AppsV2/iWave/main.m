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

static void G(int32_t P, double sigma, int32_t n, double deltaQ, float ** kernel)
{
    assert(kernel != NULL);

    const int32_t kernelSize = 2 * P + 1;
    const double gZero = G_zero(sigma, n, deltaQ);

    *kernel = ALLOC_ARRAY(float, kernelSize * kernelSize);

    /*
        Memory layout

        6 7 8
        3 4 5
        0 1 2
    */

    for (int32_t l = -P; l < P + 1; l++)
    {
        for (int32_t k = -P; k < P + 1; k++)
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
            const int32_t index = indexl * kernelSize + indexk;

            (*kernel)[index] = (float)(element / gZero);
        }
    }
}

static void convolve(const float * const source, int32_t sourceWidth, int32_t sourceHeight,
    const float * const kernel, int32_t P, float * target)
{
    const int32_t kernelWidth = 2 * P + 1;

    const int32_t startx = P;
    const int32_t starty = P;
    const int32_t endx = sourceWidth  - P;
    const int32_t endy = sourceHeight - P;

    for (int32_t i = starty; i < endy; i++)
    {
        for (int32_t j = startx; j < endx; j++)
        {
            float result = 0.0f;

            for (int32_t ky = -P; ky < P + 1; ky++)
            {
                for (int32_t kx = -P; kx < P + 1; kx++)
                {
                    const int32_t indexkx = kx + P;
                    const int32_t indexky = ky + P;
                    const int32_t kernelIndex = indexky * kernelWidth + indexkx;

                    const int32_t indexi = i + ky;
                    const int32_t indexj = j + kx;
                    const int32_t sourceIndex = indexi * sourceWidth + indexj;

                    result += (source[sourceIndex] * kernel[kernelIndex]);
                }
            }

            target[i*sourceWidth + j] = result;
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
    glfwOpenWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_TRUE);
    
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
    glfwSwapInterval(1);
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

    const int32_t gridWidth  = 200;
    const int32_t gridHeight = 150;
    const double scaleX = ((double)gridWidth) / ((double)widgetSize.x);
    const double scaleY = ((double)gridHeight) / ((double)widgetSize.y);

    float * heights     = ALLOC_ARRAY(float, gridWidth * gridHeight);
    float * prevHeights = ALLOC_ARRAY(float, gridWidth * gridHeight);
    float * gpuHeights  = ALLOC_ARRAY(float, gridWidth * gridHeight);
    float * derivative  = ALLOC_ARRAY(float, gridWidth * gridHeight);
    float * phi         = ALLOC_ARRAY(float, gridWidth * gridHeight);
    float * dphi        = ALLOC_ARRAY(float, gridWidth * gridHeight);

    float * source      = ALLOC_ARRAY(float, gridWidth * gridHeight);
    float * obstruction = ALLOC_ARRAY(float, gridWidth * gridHeight);

    memset(heights,     0, sizeof(float) * gridWidth * gridHeight);
    memset(prevHeights, 0, sizeof(float) * gridWidth * gridHeight);
    memset(gpuHeights,  0, sizeof(float) * gridWidth * gridHeight);
    memset(derivative,  0, sizeof(float) * gridWidth * gridHeight);
    memset(source,      0, sizeof(float) * gridWidth * gridHeight);
    memset(phi,         0, sizeof(float) * gridWidth * gridHeight);
    memset(dphi,        0, sizeof(float) * gridWidth * gridHeight);

    for (int32_t i = 0; i < gridWidth * gridHeight; i++)
    {
        obstruction[i] = 1.0f;
    }

    float sourceBrush[3][3];
    sourceBrush[1][1] = 1.0f;
    sourceBrush[0][1] = 0.5f;
    sourceBrush[2][1] = 0.5f;
    sourceBrush[1][0] = 0.5f;
    sourceBrush[1][2] = 0.5f;
    sourceBrush[0][0] = 0.25f;
    sourceBrush[0][2] = 0.25f;
    sourceBrush[2][0] = 0.25f;
    sourceBrush[2][2] = 0.25f;

    float obstructionBrush[3][3];
    obstructionBrush[1][1] = 0.0f;
    obstructionBrush[0][1] = 0.5f;
    obstructionBrush[2][1] = 0.5f;
    obstructionBrush[1][0] = 0.5f;
    obstructionBrush[1][2] = 0.5f;
    obstructionBrush[0][0] = 0.75f;
    obstructionBrush[0][2] = 0.75f;
    obstructionBrush[2][0] = 0.75f;
    obstructionBrush[2][2] = 0.75f;

    const float alpha = 0.3;
    const float dt = 1.0f / 60.0f;
    const float halfdt = dt * 0.5f;
    const float gravity = 9.81f;
    const float gravityHalfDt = gravity * halfdt;
    const float gdtdt = gravity * dt * dt;

    const int32_t kernelRadius = 6;
    const int32_t kernelSize = 2 * kernelRadius + 1;

    float * kernel = NULL;
    G(kernelRadius, 1.0, 10000, 0.001, &kernel);

    NSAutoreleasePool * rPool = [ NSAutoreleasePool new ];


    NSData * heightData
        = [ NSData dataWithBytesNoCopy:heights
                                length:sizeof(float) * gridWidth * gridHeight
                          freeWhenDone:NO ];

    NSData * sourceData
        = [ NSData dataWithBytesNoCopy:source
                                length:sizeof(float) * gridWidth * gridHeight
                          freeWhenDone:NO ];

    NSData * obstructionData
        = [ NSData dataWithBytesNoCopy:obstruction
                                length:sizeof(float) * gridWidth * gridHeight
                          freeWhenDone:NO ];

    NSData * derivativeData
        = [ NSData dataWithBytesNoCopy:derivative
                                length:sizeof(float) * gridWidth * gridHeight
                          freeWhenDone:NO ];

    NSData * kernelData
        = [ NSData dataWithBytesNoCopy:kernel
                                length:sizeof(float) * kernelSize * kernelSize
                          freeWhenDone:NO ];

    NPTexture2D * heightTexture      = [[ NPTexture2D alloc ] initWithName:@"Height" ];
    NPTexture2D * sourceTexture      = [[ NPTexture2D alloc ] initWithName:@"Source" ];
    NPTexture2D * obstructionTexture = [[ NPTexture2D alloc ] initWithName:@"Obstruction" ];
    NPTexture2D * derivativeTexture  = [[ NPTexture2D alloc ] initWithName:@"Derivative"  ];

    NPBufferObject  * kernelBuffer  = [[ NPBufferObject alloc ]  initWithName:@"Kernel BO" ];
    NPTextureBuffer * kernelTexture = [[ NPTextureBuffer alloc ] initWithName:@"Kernel TB" ];

    NPRenderTexture * heightsTarget     = [[ NPRenderTexture alloc ] initWithName:@"Height Target"      ];
    NPRenderTexture * prevHeightsTarget = [[ NPRenderTexture alloc ] initWithName:@"Prev Height Target" ];
    NPRenderTexture * derivativeTarget  = [[ NPRenderTexture alloc ] initWithName:@"Derivative Target"  ];
    NPRenderTexture * tempTarget        = [[ NPRenderTexture alloc ] initWithName:@"Temp Target"        ];

    NPRenderTargetConfiguration * rtc = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC" ];

    BOOL allok
        = [ kernelBuffer
                generateStaticGeometryBuffer:NpBufferDataFormatFloat32
                                  components:1
                                        data:kernelData
                                  dataLength:[ kernelData length ]
                                       error:NULL ];

    assert(allok == YES);

    [ kernelTexture attachBuffer:kernelBuffer
                numberOfElements:kernelSize * kernelSize
                     pixelFormat:NpTexturePixelFormatR
                      dataFormat:NpTextureDataFormatFloat32 ];


    [ heightTexture generateUsingWidth:gridWidth
                          height:gridHeight
                     pixelFormat:NpTexturePixelFormatR
                      dataFormat:NpTextureDataFormatFloat32
                         mipmaps:NO
                            data:heightData ];

    [ sourceTexture generateUsingWidth:gridWidth
                          height:gridHeight
                     pixelFormat:NpTexturePixelFormatR
                      dataFormat:NpTextureDataFormatFloat32
                         mipmaps:NO
                            data:sourceData ];

    [ obstructionTexture generateUsingWidth:gridWidth
                          height:gridHeight
                     pixelFormat:NpTexturePixelFormatR
                      dataFormat:NpTextureDataFormatFloat32
                         mipmaps:NO
                            data:obstructionData ];

    [ derivativeTexture generateUsingWidth:gridWidth
                          height:gridHeight
                     pixelFormat:NpTexturePixelFormatR
                      dataFormat:NpTextureDataFormatFloat32
                         mipmaps:NO
                            data:derivativeData ];


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


    NPEffect * effect
        = [[[ NPEngineGraphics instance ]
                effects ] getAssetWithFileName:@"default.effect" ];

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

    #define SOURCE YES
    #define OBSTRUCTION NO

    BOOL running = YES;
    BOOL paintMode = SOURCE;

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

        // on right click reset all data
        if ( [ rightClick activated ] == YES )
        {
            memset(heights,     0, sizeof(float) * gridWidth * gridHeight);
            memset(prevHeights, 0, sizeof(float) * gridWidth * gridHeight);
            memset(derivative,  0, sizeof(float) * gridWidth * gridHeight);
            memset(source,      0, sizeof(float) * gridWidth * gridHeight);
            memset(phi,         0, sizeof(float) * gridWidth * gridHeight);
            memset(dphi,        0, sizeof(float) * gridWidth * gridHeight);

            for (int32_t i = 0; i < gridWidth * gridHeight; i++)
            {
                obstruction[i] = 1.0f;
            }
        }

        if ( [ wheelUp activated ] == YES || [ wheelDown activated ] == YES )
        {
            paintMode = !paintMode;
        }

        if ( [ leftClick active ] == YES )
        {
            int32_t mouseX = [[[ NP Input ] mouse ] x ];
            int32_t mouseY = [[[ NP Input ] mouse ] y ];

            const uint32_t widgetHeight
                = [[[ NP Graphics ] viewport ] widgetHeight ];

            mouseY = widgetHeight - mouseY - 1;

            const double dx = ((double)mouseX) * scaleX;
            const double dy = ((double)mouseY) * scaleY;

            const int32_t dmousex = (int32_t)floor(dx + 0.5);
            const int32_t dmousey = (int32_t)floor(dy + 0.5);

            //NSLog(@"%d %d %lf %lf %d %d", mouseX, mouseY, dx, dy, dmousex, dmousey);

            int32_t xstart = MAX(0, dmousex - 1);
            int32_t ystart = MAX(0, dmousey - 1);
            int32_t xend   = MIN(dmousex + 1, gridWidth  - 1);
            int32_t yend   = MIN(dmousey + 1, gridHeight - 1);

            //NSLog(@"%d %d %d %d", xstart, ystart, xend, yend);

            if ( paintMode == SOURCE )
            {
                for (int32_t i = ystart; i < yend + 1; i++)
                {
                    for (int32_t j = xstart; j < xend + 1; j++)
                    {
                        const int32_t sourceIndex = i * gridWidth + j;
                        source[sourceIndex] += sourceBrush[i-ystart][j-xstart];
                        //printf("%f\n", source[sourceIndex]);
                    }
                }
            }

            if ( paintMode == OBSTRUCTION )
            {
                for (int32_t i = ystart; i < yend + 1; i++)
                {
                    for (int32_t j = xstart; j < xend + 1; j++)
                    {
                        const int32_t obstructionIndex = i * gridWidth + j;
                        obstruction[obstructionIndex] = obstructionBrush[i-ystart][j-xstart];
                        //printf("%f\n", obstruction[obstructionIndex]);
                    }
                }
            }
        }

        NSData * sourceData
            = [ NSData dataWithBytesNoCopy:gpuHeights
                                    length:sizeof(float) * gridWidth * gridHeight
                              freeWhenDone:NO ];

        NSData * obstructionData
            = [ NSData dataWithBytesNoCopy:obstruction
                                    length:sizeof(float) * gridWidth * gridHeight
                              freeWhenDone:NO ];

        [ sourceTexture generateUsingWidth:gridWidth
                              height:gridHeight
                         pixelFormat:NpTexturePixelFormatR
                          dataFormat:NpTextureDataFormatFloat32
                             mipmaps:NO
                                data:sourceData ];

        [ obstructionTexture generateUsingWidth:gridWidth
                              height:gridHeight
                         pixelFormat:NpTexturePixelFormatR
                          dataFormat:NpTextureDataFormatFloat32
                             mipmaps:NO
                                data:obstructionData ];

        [ rtc bindFBO ];

        [ heightsTarget
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:0
                                      bindFBO:NO ];

        // configure draw buffers
        [ rtc activateDrawBuffers ];

        // set viewport
        [ rtc activateViewport ];

        // check FBO completeness
        NSError * fboError = nil;
        if ([ rtc checkFrameBufferCompleteness:&fboError ] == NO )
        {
            NPLOG_ERROR(fboError);
        }

        [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

        

        [ rtc deactivate ];
        
        // advance surface
        const float adt  = alpha*dt;
        const float adt2 = 1.0f / (1.0f + adt);
        const int32_t size = gridWidth * gridHeight;

        for (int32_t i = 0; i < size; i++)
        {
            heights[i] += source[i];
            heights[i] *= obstruction[i];
        }

        memcpy(gpuHeights, heights, sizeof(float) * gridWidth * gridHeight);

        convolve(heights, gridWidth, gridHeight, kernel, 6, derivative);

        for (int32_t i = 0; i < size; i++)
        {
            const float temp = heights[i];

            heights[i] = heights[i] * (2.0f - adt) - prevHeights[i] - gdtdt*derivative[i];
            heights[i] *= adt2;

            //assert(!isinff(heights[i]));

            prevHeights[i] = temp;

            source[i] = 0.0f;
        }        

        FVector2 heightRange = {.x = FLT_MAX, .y = -FLT_MAX};
        FVector2 sourceRange = {.x = FLT_MAX, .y = -FLT_MAX};

        for (int32_t i = 0; i < size; i++)
        {
            heightRange.x = MIN(heights[i], heightRange.x);
            heightRange.y = MAX(heights[i], heightRange.y);

            sourceRange.x = MIN(source[i], sourceRange.x);
            sourceRange.y = MAX(source[i], sourceRange.y);
        }

        //printf("%f %f\n", heightRange.x, heightRange.y);
        
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

        
        NSData * heightData
            = [ NSData dataWithBytesNoCopy:heights
                                    length:sizeof(float) * gridWidth * gridHeight
                              freeWhenDone:NO ];



        NSData * derivativeData
            = [ NSData dataWithBytesNoCopy:derivative
                                    length:sizeof(float) * gridWidth * gridHeight
                              freeWhenDone:NO ];


        [ heightTexture generateUsingWidth:gridWidth
                              height:gridHeight
                         pixelFormat:NpTexturePixelFormatR
                          dataFormat:NpTextureDataFormatFloat32
                             mipmaps:NO
                                data:heightData ];

        [ derivativeTexture generateUsingWidth:gridWidth
                              height:gridHeight
                         pixelFormat:NpTexturePixelFormatR
                          dataFormat:NpTextureDataFormatFloat32
                             mipmaps:NO
                                data:derivativeData ];

        NPEffectVariableFloat2 * heightRangeV  = [ effect variableWithName:@"heightRange"  ];
        NPEffectVariableFloat2 * sourceRangeV  = [ effect variableWithName:@"sourceRange"  ];
        NPEffectVariableInt    * kernelRadiusV = [ effect variableWithName:@"kernelRadius" ];

        [ heightRangeV setFValue:heightRange  ];
        [ sourceRangeV setFValue:sourceRange  ];
        [ kernelRadiusV setValue:kernelRadius ];

        [[[ NP Graphics ] textureBindingState ] setTexture:derivativeTexture texelUnit:0 ];
        [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

        [[ effect techniqueWithName:@"texture"] activate ];

        glBegin(GL_QUADS);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 0.0f, 0.0f);
            glVertex4f(-1.0f, 0.0f, 0.0f, 1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 1.0f, 0.0f);
            glVertex4f(0.0f, 0.0f, 0.0f, 1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 1.0f, 1.0f);
            glVertex4f(0.0f, 1.0f, 0.0f, 1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 0.0f, 1.0f);
            glVertex4f(-1.0f, 1.0f, 0.0f, 1.0f);
        glEnd();

        [[[ NP Graphics ] textureBindingState ] setTexture:sourceTexture texelUnit:0 ];
        [[[ NP Graphics ] textureBindingState ] setTexture:kernelTexture texelUnit:1 ];
        [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

        [[ effect techniqueWithName:@"convolution"] activate ];

        glBegin(GL_QUADS);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 0.0f, 0.0f);
            glVertex4f(0.0f, -1.0f, 0.0f, 1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 1.0f, 0.0f);
            glVertex4f(1.0f, -1.0f, 0.0f, 1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 1.0f, 1.0f);
            glVertex4f(1.0f, 0.0f, 0.0f, 1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, 0.0f, 1.0f);
            glVertex4f(0.0f, 0.0f, 0.0f, 1.0f);
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

    SAFE_FREE(kernel);

    DESTROY(leftClick);
    DESTROY(rightClick);
    DESTROY(wheelUp);
    DESTROY(wheelDown);

    DESTROY(effect);

    DESTROY(rtc);
    DESTROY(derivativeTarget);
    DESTROY(prevHeightsTarget);
    DESTROY(heightsTarget);
    DESTROY(tempTarget);

    DESTROY(heightTexture);
    DESTROY(sourceTexture);
    DESTROY(obstructionTexture);
    DESTROY(derivativeTexture);
    DESTROY(kernelTexture);
    DESTROY(kernelBuffer);

    FREE(heights);
    FREE(prevHeights);
    FREE(gpuHeights);
    FREE(derivative);
    FREE(phi);
    FREE(dphi);
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

