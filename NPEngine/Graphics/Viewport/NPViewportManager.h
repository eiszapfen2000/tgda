#import "Core/NPObject/NPObject.h"

@class NPViewport;

@interface NPViewportManager : NPObject
{
    NSMutableArray * viewports;
    NPViewport * currentViewport;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (Float) currentAspectRatio;
- (IVector2 *) currentViewportSize;
- (IVector2 *) currentControlSize;

- (NPViewport *) currentViewport;
- (void) setCurrentViewport:(NPViewport *)newCurrentViewport;

@end
