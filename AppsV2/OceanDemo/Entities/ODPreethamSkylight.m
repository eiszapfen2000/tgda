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

    sunZenithDistanceAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"SunZenithDistance" inputEvent:NpKeyboardO ];

    sunAzimuthAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"SunAzimuth" inputEvent:NpKeyboardL ];

    thetaSunDegrees = 45.0f;
    phiSunDegrees = 0.0f;

    fv2_v_init_with_zeros(&sunTheta);
    fv3_v_init_with_zeros(&lightDirection);
    fv3_v_init_with_zeros(&zenithColor);

    // turbidity must be in the range 2 - 6
    turbidity = 3.0f;

    return self;
}

- (void) dealloc
{
    [[[ NP Input ] inputActions ] removeInputAction:sunZenithDistanceAction ];
    [[[ NP Input ] inputActions ] removeInputAction:sunAzimuthAction ];

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

    /*
    lightDirectionP = [ effect parameterWithName:@"LightDirection" ];
    thetaSunP       = [ effect parameterWithName:@"ThetaSun" ];
    zenithColorP    = [ effect parameterWithName:@"ZenithColor" ];
    */

    return YES;
}

- (void) setCamera:(ODCamera *)newCamera
{
    ASSIGN(camera, newCamera);
}

- (void) update:(const float)frameTime
{
    position = [ camera position ];

    const double thetaSunAngle = DEGREE_TO_RADIANS(thetaSunDegrees);
    const double phiSunAngle   = DEGREE_TO_RADIANS(phiSunDegrees);

    const double sinThetaSun = sin(thetaSunAngle);
    const double cosThetaSun = cos(thetaSunAngle);
    const double sinPhiSun = sin(phiSunAngle);
    const double cosPhiSun = cos(phiSunAngle);

    lightDirection.x = sinThetaSun * sinPhiSun;
    lightDirection.y = cosThetaSun;
    lightDirection.z = sinThetaSun * cosPhiSun;

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

    [ super render ];
}

@end

