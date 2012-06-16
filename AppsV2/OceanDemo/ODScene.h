#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;
@class ODCamera;
@class ODProjector;
@class ODProjectedGrid;
@class ODPreethamSkylight;
@class ODOceanEntity;
@class NPRenderTargetConfiguration;
@class NPRenderTexture;
@class NPRenderBuffer;
@class NPEffect;
@class NPEffectVariableFloat3;
@class NPFullscreenQuad;

@interface ODScene : NPObject < NPPPersistentObject >
{
    BOOL ready;
    NSString * file;

    // enitities
    ODCamera * camera;
    ODPreethamSkylight * skylight;
    ODOceanEntity * ocean;
    NSMutableArray * entities;

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

    NPEffect * deferredEffect;
    NPEffectVariableFloat3 * lightDirection;

    NPFullscreenQuad * fullscreenQuad;
}

+ (void) shutdown;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (ODCamera *) camera;
- (ODPreethamSkylight *) skylight;
- (ODOceanEntity *) ocean;

- (void) update:(const float)frameTime;
- (void) render;

@end
