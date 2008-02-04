#import "NPObjectManager.h"

@implementation NPObjectManager

- (id) init
{
    return [ self initWithName:@"NPEngine Object Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    objects = [ [ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ objects release ];

    [ super dealloc ];
}

- (void) addObject:(NPObject *)newObject
{
    [ objects addObject: newObject ];
}

- (NSString *)description
{
    return [ objects description ];
}

@end
