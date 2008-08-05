#import "NPObjectManager.h"

@implementation NPObjectManager

- (id) init
{
    self = [ super init ];

    objects = [[ NSMutableArray alloc ] init ];

    return self;
}

/*- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    objects = [[ NSMutableArray alloc ] init ];

    return self;
}*/

- (void) dealloc
{
    [ objects release ];

    [ super dealloc ];
}

- (void) addObject:(NSValue *)newObject
{
    [ objects addObject:newObject ];
}

- (void) removeObject:(NSValue *)object
{
    if ( [ objects indexOfObjectIdenticalTo:object ] == NSNotFound )
    {
        NSLog(@"object not found");
    }

    [ objects removeObjectIdenticalTo:object ];
}

- (NSString *)descriptions
{
    //return [ objects description ];
    NSMutableArray * objectDescriptions = [[ NSMutableArray alloc ] init ];

    NSEnumerator * enumerator = [ objects objectEnumerator ];
    NSValue * pointer;

    while ( (pointer = [ enumerator nextObject ]) )
    {
        [ objectDescriptions addObject:[[ pointer pointerValue ] description ]];
    }

    return objectDescriptions;
}

@end
