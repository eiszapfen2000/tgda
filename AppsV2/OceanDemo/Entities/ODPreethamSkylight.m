#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPEngineInput.h"
#import "NP.h"
#import "ODPreethamSkylight.h"

static Vector3 preetham_zenith_color(double turbidity, double thetaSun)
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

@interface ODPreethamSkylight (Private)

- (void) processInput:(double)frameTime;
- (BOOL) generateRenderTarget:(NSError **)error;

@end

@implementation ODPreethamSkylight (Private)

- (void) processInput:(double)frameTime
{
    if ( [ sunZenithDistanceIncreaseAction active ] == YES )
    {
        thetaSun += (MATH_DEG_TO_RAD * 25.0 * frameTime);
    }

    if ( [ sunZenithDistanceDecreaseAction active ] == YES )
    {
        thetaSun -= (MATH_DEG_TO_RAD * 25.0 * frameTime);
    }

    if ( [ sunAzimuthIncreaseAction active ] == YES )
    {
        phiSun += (MATH_DEG_TO_RAD * 25.0 * frameTime);
    }

    if ( [ sunAzimuthDecreaseAction active ] == YES )
    {
        phiSun -= (MATH_DEG_TO_RAD * 25.0 * frameTime);
    }

    thetaSun = MIN(MAX(0.0, thetaSun), MATH_PI_DIV_2);

    if ( phiSun > MATH_2_MUL_PI )
    {
        phiSun -= MATH_2_MUL_PI;
    }

    if ( phiSun < 0.0f )
    {
        phiSun += MATH_2_MUL_PI;
    }
}

- (BOOL) generateRenderTarget:(NSError **)error
{
    return 
        [ skylightTarget generate:NpRenderTargetColor
                            width:skylightResolution
                           height:skylightResolution
                      pixelFormat:NpTexturePixelFormatRGBA
                       dataFormat:NpTextureDataFormatFloat16
                    mipmapStorage:YES
                            error:error ];
}

@end


@implementation ODPreethamSkylight

- (id) init
{
    return [ self initWithName:@"ODPreethamSkylight" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    sunZenithDistanceIncreaseAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"SunZenithDistanceIncrease" inputEvent:NpKeyboardKeypad2 ];

    sunZenithDistanceDecreaseAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"SunZenithDistanceDecrease" inputEvent:NpKeyboardKeypad8 ];

    sunAzimuthIncreaseAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"SunAzimuthIncrease" inputEvent:NpKeyboardKeypad4 ];

    sunAzimuthDecreaseAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"SunAzimuthDecrease" inputEvent:NpKeyboardKeypad6 ];

    lastTurbidity = lastThetaSun = lastPhiSun = DBL_MAX;

    // turbidity must be in the range 2 - 6
    turbidity = 2.0;

    // thetaSun range 0 ... PI/2
    thetaSun = MATH_PI_DIV_4;

    // phi range 0 ... 2*PI
    phiSun = MATH_PI;

    directionToSun = v3_zero();

    rtc = [[ NPRenderTargetConfiguration alloc] initWithName:@"Preetham RTC" ];
    skylightTarget = [[ NPRenderTexture alloc ] initWithName:@"Skylight Target" ];

    lastSkylightResolution = INT_MAX;
    skylightResolution = 1024;

    effect = [[[ NP Graphics ] effects ] getAssetWithFileName:@"preetham.effect" ];
    ASSERT_RETAIN(effect);
    preetham = [ effect techniqueWithName:@"preetham" ];
    ASSERT_RETAIN(preetham);

    radiusForMaxTheta_P = [ effect variableWithName:@"radiusForMaxTheta" ];
    directionToSun_P    = [ effect variableWithName:@"directionToSun"    ];
    zenithColor_P       = [ effect variableWithName:@"zenithColor"       ];
    denominator_P       = [ effect variableWithName:@"denominator"       ];

    A_xyY_P = [ effect variableWithName:@"A" ];
    B_xyY_P = [ effect variableWithName:@"B" ];
    C_xyY_P = [ effect variableWithName:@"C" ];
    D_xyY_P = [ effect variableWithName:@"D" ];
    E_xyY_P = [ effect variableWithName:@"E" ];

    NSAssert(radiusForMaxTheta_P != nil && directionToSun_P != nil
             && zenithColor_P != nil && denominator_P != nil && A_xyY_P != nil
             && B_xyY_P != nil && C_xyY_P != nil && D_xyY_P != nil && E_xyY_P != nil, @"");

    return self;
}

- (void) dealloc
{
    DESTROY(skylightTarget);
    DESTROY(rtc);
    DESTROY(preetham);
    DESTROY(effect);

    [[[ NP Input ] inputActions ] removeInputAction:sunZenithDistanceIncreaseAction ];
    [[[ NP Input ] inputActions ] removeInputAction:sunZenithDistanceDecreaseAction ];
    [[[ NP Input ] inputActions ] removeInputAction:sunAzimuthIncreaseAction ];
    [[[ NP Input ] inputActions ] removeInputAction:sunAzimuthDecreaseAction ];

    [ super dealloc ];
}

- (id < NPPTexture >) skylightTexture
{
    return [ skylightTarget texture ];
}

- (Vector3) directionToSun
{
    return directionToSun;
}

- (void) update:(double)frameTime
{
    [ self processInput:frameTime ];

    if ( turbidity != lastTurbidity || thetaSun != lastThetaSun
         || phiSun != lastPhiSun || skylightResolution != lastSkylightResolution )
    {
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

        Vector3 zenithColor = preetham_zenith_color(turbidity, thetaSun);

        Vector3 denominator;
        denominator.x = digamma(0.0, thetaSun, ABCDE_x);
        denominator.y = digamma(0.0, thetaSun, ABCDE_y);
        denominator.z = digamma(0.0, thetaSun, ABCDE_Y);

        const double sinThetaSun = sin(thetaSun);
        const double cosThetaSun = cos(thetaSun);
        const double sinPhiSun = sin(phiSun);
        const double cosPhiSun = cos(phiSun);

        directionToSun.x = sinThetaSun * sinPhiSun;
        directionToSun.y = cosThetaSun;
        directionToSun.z = sinThetaSun * cosPhiSun;

        const float halfSkyResolution = ((float)skylightResolution) / (2.0f);

        const float cStart = -halfSkyResolution;
        const float cEnd   =  halfSkyResolution;

        const Vector3 A = { ABCDE_x[0], ABCDE_y[0], ABCDE_Y[0] };
        const Vector3 B = { ABCDE_x[1], ABCDE_y[1], ABCDE_Y[1] };
        const Vector3 C = { ABCDE_x[2], ABCDE_y[2], ABCDE_Y[2] };
        const Vector3 D = { ABCDE_x[3], ABCDE_y[3], ABCDE_Y[3] };
        const Vector3 E = { ABCDE_x[4], ABCDE_y[4], ABCDE_Y[4] };

        [ radiusForMaxTheta_P setFValue:halfSkyResolution ];
        [ directionToSun_P setValue:directionToSun ];
        [ zenithColor_P setValue:zenithColor ];
        [ denominator_P setValue:denominator ];

        [ A_xyY_P setValue:A ];
        [ B_xyY_P setValue:B ];
        [ C_xyY_P setValue:C ];
        [ D_xyY_P setValue:D ];
        [ E_xyY_P setValue:E ];

        if ( skylightResolution != lastSkylightResolution )
        {
            [ rtc setWidth:skylightResolution  ];
            [ rtc setHeight:skylightResolution ];

            NSError * error = nil;
            if ( [ self generateRenderTarget:&error ] == NO )
            {
                NPLOG_ERROR(error);
            }
        }

        [ rtc bindFBO ];

        [ skylightTarget
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:0
                                      bindFBO:NO ];

        [ rtc activateDrawBuffers ];
        [ rtc activateViewport ];

        [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

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

        [ skylightTarget detach:NO ];

        [ rtc deactivate ];

        [[[ NP Graphics ] textureBindingState ] setTextureImmediately:[ skylightTarget texture ]];
        glGenerateMipmap(GL_TEXTURE_2D);
        [[[ NP Graphics ] textureBindingState ] restoreOriginalTextureImmediately ];

        lastTurbidity = turbidity;
        lastThetaSun  = thetaSun;
        lastPhiSun    = phiSun;

        lastSkylightResolution = skylightResolution;

        //NSLog(@"%lf %lf", thetaSun, phiSun);
    }
}

@end

