#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;
@class ODCamera;
@class ODProjector;
@class ODProjectedGrid;
@class ODPreethamSkylight;
@class NPRenderTargetConfiguration;
@class NPRenderTexture;
@class NPRenderBuffer;
@class NPEffect;
@class NPFullscreenQuad;

@interface ODScene : NPObject < NPPPersistentObject >
{
    BOOL ready;
    NSString * file;

    // enitities
    ODCamera * camera;
    ODProjector * projector;
    ODProjectedGrid * projectedGrid;
    ODPreethamSkylight * skylight;
    NSMutableArray * entities;

    // tonemapping parameters
    float referenceWhite;
    float key;
    float adaptationTimeScale;
    int32_t luminanceMaxMipMapLevel;
    float lastFrameLuminance;
    float currentFrameLuminance;

    //
    IVector2 currentResolution;
    IVector2 lastFrameResolution;

    // render targets
    NPRenderTargetConfiguration * rtc;
    NPRenderTexture * sceneTarget;
    NPRenderTexture * luminanceTarget;
    NPRenderBuffer * depthBuffer;

    //
    NPEffect * fullscreenEffect;
    NPFullscreenQuad * fullscreenQuad;
}

+ (void) shutdown;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (ODCamera *) camera;
- (ODProjector *) projector;
- (ODProjectedGrid *) projectedGrid;
- (ODPreethamSkylight *) skylight;

- (void) update:(const float)frameTime;
- (void) render;

@end
