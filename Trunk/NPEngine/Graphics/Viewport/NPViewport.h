#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface NPViewport : NPObject
{
    IVector2 * controlSize;
    IVector2 * viewportSize;
    IVector2 * viewportOrigin;
    IVector2 * viewportSizeLastFrame;
    IVector2 * viewportOriginLastFrame;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (Float) aspectRatio;
- (IVector2 *) controlSize;
- (IVector2 *) viewportSize;
- (void) setControlSize:(IVector2 *)newControlSize;
- (void) setViewportSize:(IVector2 *)newViewportSize;
- (void) setToControlSize;

@end
