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
@class NPEffectVariableMatrix4x4;
@class NPFullscreenQuad;
@class ODBasePlane;
@class ODWorldCoordinateAxes;

@interface ODScene : NPObject < NPPPersistentObject >
{
    BOOL ready;
    NSString * file;

    // enitities
    ODCamera * camera;
    ODFrustum * cameraFrustum;
    ODOceanEntity * ocean;
    ODProjectedGrid * projectedGrid;
    ODPreethamSkylight * skylight;
    ODWorldCoordinateAxes * axes;
    NSMutableArray * entities;

    ODCamera * testCamera;
    ODFrustum * testCameraFrustum;
    ODFrustum * testProjectorFrustum;

    // camera animation
    FQuaternion startOrientation;
    FQuaternion endOrientation;
    FVector3 startPosition;
    FVector3 endPosition;
    float animationTime;
    BOOL connecting;
    BOOL disconnecting;

    // whitecaps threshold
    double jacobianEpsilon;

    // tonemapping parameters
    double deltaTime;
    double lastAdaptedLuminance;
    double referenceWhite;
    double key;
    double adaptationTimeScale;
    double lastFrameLuminance;
    double currentFrameLuminance;

    // scene render target resolution
    IVector2 currentResolution;
    IVector2 lastFrameResolution;

    // whitecaps precompute render target
    NPRenderTargetConfiguration * whitecapsRtc;
    NPRenderTexture * whitecapsTarget;
    uint32_t lastDispDerivativesLayers;

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
    NPEffectVariableFloat * tonemapAdaptedAverageLuminance;
    NPEffectVariableFloat * tonemapWhiteLuminance;

    NPEffect * projectedGridEffect;
    NPEffectTechnique * whitecapsPrecompute;
    NPEffectTechnique * projectedGridTFTransform;
    NPEffectTechnique * projectedGridTFFeedback;
    // projected grid, transform phase    
    NPEffectVariableFloat * transformAreaScale;
    NPEffectVariableFloat * transformDisplacementScale;
    NPEffectVariableFloat * transformHeightScale;
    NPEffectVariableFloat2 * transformVertexStep;
    NPEffectVariableMatrix4x4 * transformInvMVP;
    // projected grid, feedback phase
    NPEffectVariableFloat  * feedbackJacobianEpsilon;
    NPEffectVariableFloat3 * feedbackCameraPosition;
    NPEffectVariableFloat3 * feedbackDirectionToSun;
    NPEffectVariableFloat3 * feedbackSunColor;
    NPEffectVariableFloat3 * feedbackSkyIrradiance;
    NPEffectVariableFloat2 * feedbackWaterColorCoordinate;
    NPEffectVariableFloat2 * feedbackWaterColorIntensityCoordinate;

    // variance LUT for Ross BRDF
    NSUInteger varianceLUTLastResolutionIndex;
    NSUInteger varianceLUTResolutionIndex;
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
