#import "NPState.h"

@implementation NPState

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName 
      configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName ];

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
