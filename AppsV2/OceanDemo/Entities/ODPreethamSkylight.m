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
#import "Graphics/Model/NPSUX2Model.h"
#import "Graphics/Model/NPSUX2MaterialInstance.h"
#import "Graphics/State/NPStateSet.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPEngineInput.h"
#import "NP.h"
#import "ODCamera.h"
#import "ODPreethamSkylight.h"


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

    thetaSunDegrees = 45.0f;
    phiSunDegrees = 0.0f;

    fv2_v_init_with_zeros(&sunTheta);
    fv3_v_init_with_zeros(&lightDirection);
    fv3_v_init_with_zeros(&zenithColor);

    // turbidity must be in the range 2 - 6
    turbidity = 4.0f;

    return self;
}

- (void) dealloc
{
    [[[ NP Input ] inputActions ] removeInputAction:sunZenithDistanceIncreaseAction ];
    [[[ NP Input ] inputActions ] removeInputAction:sunZenithDistanceDecreaseAction ];
    [[[ NP Input ] inputActions ] removeInputAction:sunAzimuthIncreaseAction ];
    [[[ NP Input ] inputActions ] removeInputAction:sunAzimuthDecreaseAction ];

    SAFE_DESTROY(camera);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    BOOL result
        = [ super loadFromDictionary:config
                               error:error ];

    if ( result == NO )
    {
        return NO;
    }


    NPSUX2MaterialInstance * mInstance = [ model materialInstanceAtIndex:0 ];
    NPEffect * effect = [ mInstance effect ];
    NPEffectTechnique * technique
        = [ effect techniqueWithName:[ mInstance techniqueName ]];

    NSAssert(technique != nil, @"");

    A_Yxy_P = [ effect variableWithName:@"AColor" ];
    B_Yxy_P = [ effect variableWithName:@"BColor" ];
    C_Yxy_P = [ effect variableWithName:@"CColor" ];
    D_Yxy_P = [ effect variableWithName:@"DColor" ];
    E_Yxy_P = [ effect variableWithName:@"EColor" ];
    zenithColor_P = [ effect variableWithName:@"ZenithColor" ];
    lighDirection_P = [ effect variableWithName:@"DirectionToSun" ];

    return YES;
}

- (FVector3) lightDirection
{
    return lightDirection;
}

- (void) setCamera:(ODCamera *)newCamera
{
    ASSIGN(camera, newCamera);
}

- (void) update:(const float)frameTime
{

    if ( [ sunZenithDistanceIncreaseAction active ] == YES )
    {
        thetaSunDegrees += 1.0f;
    }

    if ( [ sunZenithDistanceDecreaseAction active ] == YES )
    {
        thetaSunDegrees -= 1.0f;
    }

    if ( [ sunAzimuthIncreaseAction active ] == YES )
    {
        phiSunDegrees += 1.0f;
    }

    if ( [ sunAzimuthDecreaseAction active ] == YES )
    {
        phiSunDegrees -= 1.0f;
    }

    if ( thetaSunDegrees < 0.0f )
    {
        thetaSunDegrees = 0.0f;
    }

    if (thetaSunDegrees > 90.0f)
    {
        thetaSunDegrees = 90.0f;
    }

    if ( phiSunDegrees > 360.0f )
    {
        phiSunDegrees -= 360.0f;
    }

    if ( phiSunDegrees < 0.0f )
    {
        phiSunDegrees += 360.0f;
    }

    const double thetaSunAngle = DEGREE_TO_RADIANS(thetaSunDegrees);
    const double phiSunAngle   = DEGREE_TO_RADIANS(phiSunDegrees);

    const double sinThetaSun = sin(thetaSunAngle);
    const double cosThetaSun = cos(thetaSunAngle);
    const double sinPhiSun = sin(phiSunAngle);
    const double cosPhiSun = cos(phiSunAngle);

    lightDirection.x = sinThetaSun * sinPhiSun;
    lightDirection.y = cosThetaSun;
    lightDirection.z = sinThetaSun * cosPhiSun;

    // zenith color computation
    // A Practical Analytic Model for Daylight
    // page 22/23    

    #define CBQ(X)		((X) * (X) * (X))
    #define SQR(X)		((X) * (X))

    zenithColor.x
        = ( 0.00165 * CBQ(thetaSunAngle) - 0.00374  * SQR(thetaSunAngle) +
            0.00208 * thetaSunAngle + 0.0f) * SQR(turbidity) +
          (-0.02902 * CBQ(thetaSunAngle) + 0.06377  * SQR(thetaSunAngle) -
            0.03202 * thetaSunAngle  + 0.00394) * turbidity +
          ( 0.11693 * CBQ(thetaSunAngle) - 0.21196  * SQR(thetaSunAngle) +
            0.06052 * thetaSunAngle + 0.25885);

    zenithColor.y
        = ( 0.00275 * CBQ(thetaSunAngle) - 0.00610  * SQR(thetaSunAngle) +
            0.00316 * thetaSunAngle + 0.0) * SQR(turbidity) +
          (-0.04214 * CBQ(thetaSunAngle) + 0.08970  * SQR(thetaSunAngle) -
            0.04153 * thetaSunAngle  + 0.00515) * turbidity  +
          ( 0.15346 * CBQ(thetaSunAngle) - 0.26756  * SQR(thetaSunAngle) +
            0.06669 * thetaSunAngle  + 0.26688);

    zenithColor.z
        = (4.0453 * turbidity - 4.9710) * 
          tan((4.0 / 9.0 - turbidity / 120.0) * (M_PI - 2.0 * thetaSunAngle))
          - 0.2155 * turbidity + 2.4192;

	// convert kcd/m² to cd/m²
	zenithColor.z *= 1000.0f;

    #undef SQR
    #undef CBQ

    // max skylight luminance (right at sun position)
    // A Practical Analytic Model for Daylight
    // page 9
    //             F(thetaSunAngle, 0)
    // Ymax = Yz ----------------------
    //             F(0, thetaSunAngle)

    double ABCDE_Y[5];

	ABCDE_Y[0] =  0.17872 * turbidity - 1.46303;
	ABCDE_Y[1] = -0.35540 * turbidity + 0.42749;
	ABCDE_Y[2] = -0.02266 * turbidity + 5.32505;
	ABCDE_Y[3] =  0.12064 * turbidity - 2.57705;
	ABCDE_Y[4] = -0.06696 * turbidity + 0.37027;

    const double numerator
        = ( 1.0 + ABCDE_Y[0] * exp( ABCDE_Y[1] / cosThetaSun )) * ( 1.0 + ABCDE_Y[2] + ABCDE_Y[4] );

    const double denominator
        = ( 1.0 + ABCDE_Y[0] * exp( ABCDE_Y[1] )) * ( 1.0 + ABCDE_Y[2] * exp( ABCDE_Y[3] * thetaSunAngle) + ABCDE_Y[4] * cosThetaSun * cosThetaSun);

    const double factor = numerator / denominator;

    double xyY[3];
    xyY[0] = zenithColor.x * factor;
    xyY[1] = zenithColor.y * factor;
    xyY[2] = zenithColor.z * factor;

    double XYZ[3];
    XYZ[0] = (xyY[0] / xyY[1]) * xyY[2];
    XYZ[1] = xyY[2];
    XYZ[2] = ((1.0 - xyY[0] - xyY[1]) / xyY[1]) * xyY[2];

    //NSLog(@"1: %f %f %f", XYZ[0], XYZ[1], XYZ[2]);

    double RGB[3];
    RGB[0] =  3.2404542 * XYZ[0] - 1.5371385 * XYZ[1] - 0.4985314 * XYZ[2];
    RGB[1] = -0.9692660 * XYZ[0] + 1.8760108 * XYZ[1] + 0.0415560 * XYZ[2];
    RGB[2] =  0.0556434 * XYZ[0] - 0.2040259 * XYZ[1] + 1.0572252 * XYZ[2];

    RGB[0] *= 0.00025f;
    RGB[1] *= 0.00025f;
    RGB[2] *= 0.00025f;

    XYZ[0] = 0.4124564 * RGB[0] + 0.3575761 * RGB[1] + 0.1804375 * RGB[2];
    XYZ[1] = 0.2126729 * RGB[0] + 0.7151522 * RGB[1] + 0.0721750 * RGB[2];
    XYZ[2] = 0.0193339 * RGB[0] + 0.1191920 * RGB[1] + 0.9503041 * RGB[2];

    //NSLog(@"2: %f %f %f", XYZ[0], XYZ[1], XYZ[2]);

    position = [ camera position ];
    position.y -= 2.0f;
}

- (void) render
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

    const FVector3 A = { ABCDE_x[0], ABCDE_y[0], ABCDE_Y[0] };
    const FVector3 B = { ABCDE_x[1], ABCDE_y[1], ABCDE_Y[1] };
    const FVector3 C = { ABCDE_x[2], ABCDE_y[2], ABCDE_Y[2] };
    const FVector3 D = { ABCDE_x[3], ABCDE_y[3], ABCDE_Y[3] };
    const FVector3 E = { ABCDE_x[4], ABCDE_y[4], ABCDE_Y[4] };

    [ A_Yxy_P setValue:A ];
    [ B_Yxy_P setValue:B ];
    [ C_Yxy_P setValue:C ];
    [ D_Yxy_P setValue:D ];
    [ E_Yxy_P setValue:E ];
    [ zenithColor_P setValue:zenithColor ];
    [ lighDirection_P setValue:lightDirection ];

    fm4_mv_translation_matrix(&modelMatrix, &position);
    [[[ NPEngineCore instance ] transformationState ] setModelMatrix:&modelMatrix ];
    [ model renderLOD:0 withMaterial:YES ];
}

@end

