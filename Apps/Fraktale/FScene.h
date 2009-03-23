#import "Core/NPObject/NPObject.h"

@class FTerrain;
@class FCamera;

@interface FScene : NPObject
{
    FTerrain * terrain;
    FCamera * camera;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (FTerrain *) terrain;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
