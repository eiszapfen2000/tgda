#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODEntity.h"

@class NPSUX2Model;
@class NPStateSet;
@class NPEffect;
@class NPEffectTechnique;
@class NPEffectVariableFloat3;
@class NPInputAction;
@class ODCamera;

@interface ODPreethamSkylight : ODEntity
{
    ODCamera * camera;
    NPInputAction * sunZenithDistanceIncreaseAction;
    NPInputAction * sunZenithDistanceDecreaseAction;
    NPInputAction * sunAzimuthIncreaseAction;
    NPInputAction * sunAzimuthDecreaseAction;

    float thetaSunDegrees;
    float phiSunDegrees;

    FVector2 sunTheta;
    FVector3 lightDirection;
    FVector3 zenithColor;
    float turbidity;

    NPEffectVariableFloat3 * A_Yxy_P;
    NPEffectVariableFloat3 * B_Yxy_P;
    NPEffectVariableFloat3 * C_Yxy_P;
    NPEffectVariableFloat3 * D_Yxy_P;
    NPEffectVariableFloat3 * E_Yxy_P;
    NPEffectVariableFloat3 * zenithColor_P;
    NPEffectVariableFloat3 * lighDirection_P;

    /*
    CGparameter lightDirectionP;
    CGparameter thetaSunP;
    */
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) setCamera:(ODCamera *)newCamera;

@end

