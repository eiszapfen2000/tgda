#import "AL/al.h"
#import "AL/alc.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface NPSoundWorld : NPObject
{
    FVector3 listenerPosition;
    FVector3 listenerPositionLastFrame;
    FQuaternion listenerRotation;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setListenerPosition:(FVector3)newListenerPosition;
- (void) setListenerOrientation:(FQuaternion)newListenerOrientation;

- (void) update;

@end
