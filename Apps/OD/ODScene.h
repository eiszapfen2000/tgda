#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"

@interface ODScene : NPObject
{
    id camera;
    id projector;

    id skybox;
    NSMutableArray * entities;

    id font;
    id menu;

    id fullscreenEffect;
    id fullscreenQuad;

    id renderTargetConfiguration;
    id sceneRenderTexture;
    id luminanceRenderTexture;
    id depthRenderBuffer;

    id defaultStateSet;

    Int32 luminanceMaxMipMapLevel;
    Float referenceWhite;
    Float key;
    CGparameter toneMappingParameters;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (id) camera;
- (id) projector;
- (id) entityWithName:(NSString *)entityName;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
