#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;
@class ODCamera;
@class ODProjector;
@class ODProjectedGrid;

@interface ODScene : NPObject < NPPPersistentObject >
{
    BOOL ready;
    NSString * file;

    ODCamera * camera;
    ODProjector * projector;
    ODProjectedGrid * projectedGrid;

    NSMutableArray * entities;
}

+ (void) shutdown;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (ODCamera *) camera;
- (ODProjector *) projector;

- (void) update:(const float)frameTime;
- (void) render;

@end
