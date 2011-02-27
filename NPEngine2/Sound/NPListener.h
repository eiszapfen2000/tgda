#import "AL/al.h"
#import "AL/alc.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface NPListener : NPObject
{
    FVector3 listenerPosition;
    FVector3 listenerPositionLastFrame;
    FQuaternion listenerRotation;
}

- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) setListenerPosition:(FVector3)newListenerPosition;
- (void) setListenerOrientation:(FQuaternion)newListenerOrientation;

- (void) update;

@end
