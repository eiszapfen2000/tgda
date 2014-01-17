#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;
@class ODCamera;
@class ODFrustum;
@class ODProjector;
@class ODProjectedGrid;
@class ODPreethamSkylight;
@class ODOceanEntity;
@class NPRenderTargetConfiguration;
@class NPRenderTexture;
@class NPRenderBuffer;
@class NPEffect;
@class NPEffectTechniqueVariable;
@class NPEffectVariableInt;
@class NPEffectVariableFloat;
@class NPEffectVariableFloat2;
@class NPEffectVariableFloat3;
@class NPFullscreenQuad;
@class ODBasePlane;
@class ODIWave;

@interface ODScene : NPObject < NPPPersistentObject >
{
    BOOL ready;
    NSString * file;

    // enitities
    ODCamera * camera;
    ODIWave * iwave;
    ODOceanEntity * ocean;
    ODProjectedGrid * projectedGrid;
    ODPreethamSkylight * skylight;
    NSMutableArray * entities;

    ODCamera * testCamera;
    ODFrustum * testCameraFrustum;
    ODProjector * testProjector;
    ODFrustum * testProjectorFrustum;

    // camera animation
    FQuaternion startOrientation;
    FQuaternion endOrientation;
    FVector3 startPosition;
    FVector3 endPosition;
    float animationTime;
    BOOL connecting;
    BOOL disconnecting;

    //
    double jacobianEpsilon;

    // tonemapping parameters
    double referenceWhite;
    double key;
    double adaptationTimeScale;
    double lastFrameLuminance;
    double currentFrameLuminance;

    //
    IVector2 currentResolution;
    IVector2 lastFrameResolution;

    //
    NPRenderTargetConfiguration * whitecapsRtc;
    NPRenderTexture * whitecapsTarget;

    // general rendering stuff
    NPRenderTargetConfiguration * rtc;
    NPRenderTexture * linearsRGBTarget;
    NPRenderTexture * logLuminanceTarget;
    NPRenderBuffer  * depthBuffer;

    // effect + variables
    NPEffect * deferredEffect;
    NPEffectTechnique * logLuminance;
    NPEffectTechnique * tonemap;
    NPEffectVariableFloat * tonemapKey;
    NPEffectVariableInt   * tonemapAverageLuminanceLevel;
    NPEffectVariableFloat * tonemapWhiteLuminance;

    NPEffect * projectedGridEffect;
    NPEffectTechnique * whitecapsPrecompute;
    NPEffectTechnique * projectedGridTFTransform;
    NPEffectTechnique * projectedGridTFFeedback;

    // variance LUT for Ross BRDF
    uint32_t varianceLUTLastResolution;
    uint32_t varianceLUTResolution;
    NPRenderTargetConfiguration * varianceRTC;
    NPRenderTexture * varianceLUT;
    NPEffectTechnique * variance;
    NPEffectVariableFloat * layer;
    NPEffectVariableFloat * varianceTextureResolution;
    NPEffectVariableFloat * deltaVariance;

    // fullscreen quad geometry
    NPFullscreenQuad * fullscreenQuad;
}

+ (void) shutdown;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (ODCamera *) camera;
- (ODPreethamSkylight *) skylight;
- (ODOceanEntity *) ocean;

- (void) update:(const double)frameTime;
- (void) render;

@end
