#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"

@class ODCamera;
@class ODProjector;
@class ODPreethamSkylight;
@class ODMenu;

@class NPRenderTargetConfiguration;
@class NPRenderTexture;
@class NPRenderBuffer;
@class NPEffect;
@class NPFullscreenQuad;
@class NPStateSet;

@interface ODScene : NPObject
{
    ODCamera * camera;
    ODProjector * projector;
    ODPreethamSkylight * skylight;

    NSMutableArray * entities;

    ODMenu * menu;

    // tonemapping parameters
    Float referenceWhite;
    Float key;
    Float adaptationTimeScale;
    Int32 luminanceMaxMipMapLevel;
    Float lastFrameLuminance;
    Float currentFrameLuminance;

    // effect + parameter handles
    NPEffect * fullscreenEffect;
    CGparameter toneMappingParameters;

    // render targets
    NPRenderTargetConfiguration * sceneRTC;
    NPRenderTexture * sceneRT;
    NPRenderTexture * luminanceRT;
    NPRenderBuffer * depthRB;

    NPStateSet * defaultStateSet;
    NPFullscreenQuad * fullscreenQuad;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (ODCamera *) camera;
- (ODProjector *) projector;
- (id) entityWithName:(NSString *)entityName;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
