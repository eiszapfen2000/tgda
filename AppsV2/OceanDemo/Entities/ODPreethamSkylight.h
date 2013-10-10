#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPEffect;
@class NPEffectTechnique;
@class NPEffectVariableFloat3;
@class NPInputAction;

@interface ODPreethamSkylight : NPObject
{
    NPInputAction * sunZenithDistanceIncreaseAction;
    NPInputAction * sunZenithDistanceDecreaseAction;
    NPInputAction * sunAzimuthIncreaseAction;
    NPInputAction * sunAzimuthDecreaseAction;

    double turbidity;
    double thetaSun;
    double phiSun;
    Vector3 directionToSun;

    NPEffectVariableFloat3 * A_Yxy_P;
    NPEffectVariableFloat3 * B_Yxy_P;
    NPEffectVariableFloat3 * C_Yxy_P;
    NPEffectVariableFloat3 * D_Yxy_P;
    NPEffectVariableFloat3 * E_Yxy_P;
    NPEffectVariableFloat3 * zenithColor_P;
    NPEffectVariableFloat3 * lighDirection_P;
    NPEffectVariableFloat3 * denominator_P;
    NPEffectVariableFloat  * radiusForMaxTheta_P;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (Vector3) directionToSun;

- (void) update:(const double)frameTime;

@end

