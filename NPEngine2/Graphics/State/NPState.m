#import "NPState.h"

@implementation NPState

- (id) init
{
    return [ self initWithName:@"NPState" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName parent:newParent configuration:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName parent:newParent ];

    locked = NO;
    configuration = newConfiguration;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) locked
{
    return locked;
}

- (void) setLocked:(BOOL)newLocked
{
    locked = newLocked;
}

- (BOOL) changeable
{
    return ( !locked && ( (configuration == nil) || (![ configuration locked ]) ));
}

@end
