#import "Core/NPObject/NPObject.h"

@class ODCamera;
@class ODProjector;
@class NPRenderTargetConfiguration;
@class NPPixelBuffer;
@class NPTexture;
@class NPTexture3D;
@class ODEntity;

@interface ODScene : NPObject
{
    ODCamera * camera;
    ODProjector * projector;
    ODEntity * skybox;
    NSMutableArray * entities;
    id font;
    id ocean;
    id pbos;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (id) camera;
- (id) projector;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
