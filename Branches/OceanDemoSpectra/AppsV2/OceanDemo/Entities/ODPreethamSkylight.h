#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPEffect;
@class NPEffectTechnique;
@class NPEffectVariableFloat;
@class NPEffectVariableFloat3;
@class NPFullscreenQuad;
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

    double lastSunDiskA;
    double lastSunDiskB;
    double lastSunDiskC;
    double sunDiskA;
    double sunDiskB;
    double sunDiskC;

    Vector3 directionToSun;
    Vector3 irradianceXYZ;
    Vector3 irradianceRGB;
    Vector3 sunColor;

    NPRenderTargetConfiguration * rtc;
    NPRenderTexture * skylightTarget;
    NPRenderTexture * sunlightTarget;
    NPFullscreenQuad * fullscreenQuad;

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
    NPEffectVariableFloat3 * sunColor_P;
    NPEffectVariableFloat3 * denominator_P;
    NPEffectVariableFloat  * sunHalfApparentAngle_P;
    NPEffectVariableFloat3 * sunDisk_abc_P;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (id < NPPTexture >) skylightTexture;
- (Vector3) directionToSun;
- (Vector3) irradiance;
- (Vector3) sunColor;

- (void) update:(double)frameTime;

@end

