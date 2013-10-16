#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPEffect;
@class NPEffectTechnique;
@class NPEffectVariableFloat;
@class NPEffectVariableFloat3;
@class NPRenderTargetConfiguration;
@class NPTexture2D;
@class NPRenderTexture;
@class NPInputAction;

@interface ODPreethamSkylight : NPObject
{
    NPInputAction * sunZenithDistanceIncreaseAction;
    NPInputAction * sunZenithDistanceDecreaseAction;
    NPInputAction * sunAzimuthIncreaseAction;
    NPInputAction * sunAzimuthDecreaseAction;

    double lastTurbidity;
    double turbidity;
    double lastThetaSun;
    double thetaSun;
    double lastPhiSun;
    double phiSun;
    Vector3 directionToSun;

    NPRenderTargetConfiguration * rtc;
    NPRenderTexture * skylightTarget;

    int32_t lastSkylightResolution;
    int32_t skylightResolution;

    NPEffect * effect;
    NPEffectTechnique * preetham;
    NPEffectVariableFloat3 * A_xyY_P;
    NPEffectVariableFloat3 * B_xyY_P;
    NPEffectVariableFloat3 * C_xyY_P;
    NPEffectVariableFloat3 * D_xyY_P;
    NPEffectVariableFloat3 * E_xyY_P;
    NPEffectVariableFloat3 * zenithColor_P;
    NPEffectVariableFloat3 * directionToSun_P;
    NPEffectVariableFloat3 * denominator_P;
    NPEffectVariableFloat  * radiusForMaxTheta_P;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (id < NPPTexture >) skylightTexture;
- (Vector3) directionToSun;

- (void) update:(double)frameTime;

@end

