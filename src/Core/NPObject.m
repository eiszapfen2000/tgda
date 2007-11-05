#import "NPObject.h"

@implementation NPObject

- (id) init
{
    self = [ super init ];

    name = @"NPObject";

    return self;
}

- (id) initWithName: (NSString *) newName
{
    self = [ super init ];

    name = [ newName retain ];

    return self;
}

- (void) dealloc
{
    [ name release ];

    [ super dealloc ];
}

- (void) setup
{
}

- (NSString *) name
{
    return name;
}

- (void) setName: (NSString *) newName
{
    if ( name != newName )
    {
        [ name release ];

        name = [ newName retain ];
    }
}

@end
