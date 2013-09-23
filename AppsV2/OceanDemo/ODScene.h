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

    // tonemapping parameters
    float referenceWhite;
    float key;
    float adaptationTimeScale;
    float lastFrameLuminance;
    float currentFrameLuminance;

    //
    IVector2 currentResolution;
    IVector2 lastFrameResolution;

    // G buffer
    NPRenderTargetConfiguration * gBuffer;
    NPRenderTexture * positionsTarget;
    NPRenderTexture * normalsTarget;
    NPRenderTexture * depthTarget;

    // effect + variables
    NPEffect * deferredEffect;
    NPEffectVariableFloat2 * heightfieldMinMax;
    NPEffectVariableFloat3 * lightDirection;
    NPEffectVariableFloat3 * cameraPosition;

    NPEffect * projectedGridEffect;
    NPEffectTechnique * projectedGridTFTransform;
    NPEffectTechnique * projectedGridTFFeedback;

    uint32_t varianceLUTLastResolution;
    uint32_t varianceLUTResolution;
    NPRenderTargetConfiguration * varianceRTC;
    NPRenderTexture * varianceLUT;
    NPEffectTechnique * variance;
    NPEffectVariableFloat * layer;
    NPEffectVariableFloat * varianceTextureResolution;
    NPEffectVariableFloat2 * baseSpectrumSize;
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
