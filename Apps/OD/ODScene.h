#import "Core/NPObject/NPObject.h"

@class ODCamera;
@class ODProjector;
@class NPRenderTargetConfiguration;
@class NPPixelBuffer;
@class NPTexture;

@interface ODScene : NPObject
{
    ODCamera * camera;
    ODProjector * projector;
    id skybox;
    id entities;

    NPRenderTargetConfiguration * rtconfig;
    NPPixelBuffer * pbo;
    NPTexture * tex;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;

- (id) camera;
- (id) projector;

- (void) update;
- (void) render;

@end
