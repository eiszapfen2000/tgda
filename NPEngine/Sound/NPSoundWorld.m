#import "NPSoundWorld.h"

@implementation NPSoundWorld

- (id) init
{
    return [ self initWithName:@"NP Sound World" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    listenerPosition = fv3_alloc_init();
    listenerPositionLastFrame = fv3_alloc_init();
    listenerRotation = fquat_alloc_init();

    return self;
}

- (void) dealloc
{
    listenerRotation = fquat_free(listenerRotation);
    listenerPositionLastFrame = fv3_free(listenerPositionLastFrame);
    listenerPosition = fv3_free(listenerPosition);    

    [ super dealloc ];
}

- (void) setListenerPosition:(FVector3)newListenerPosition
{
    *listenerPosition = newListenerPosition;
}

- (void) setListenerOrientation:(FQuaternion)newListenerOrientation
{
    *listenerRotation = newListenerOrientation;
}


@end
