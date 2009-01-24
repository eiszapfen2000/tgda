#import "NPObjectManager.h"
#import "Core/Basics/NpCrc32.h"
#import "NP.h"

@implementation NPObjectManager

- (id) init
{
    return [ self initWithName:@"" parent:nil ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super init ];

    name = [ newName retain ];

    //Weak reference
    parent = newParent;

    objectID = crc32_of_pointer(self);
    objects = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ name release ];
    parent = nil;

    if ( [ objects count ] > 0 )
    {
        NSLog(@"Memory leak, listing leaked objects:");

        NSEnumerator * e = [ objects objectEnumerator ];
        NSValue * o;

        while (( o = [ e nextObject ] ))
        {
            NSLog(@"%@ %@ %d",[(id)[o pointerValue] className], [(id)[o pointerValue] name],[(id)[o pointerValue] retainCount]);
        }
    }

    [ objects release ];

    [ super dealloc ];
}

- (void) addObject:(NSValue *)newObject
{
    [ objects addObject:newObject ];
}

- (void) removeObject:(NSValue *)object
{
    [ objects removeObjectIdenticalTo:object ];
}

- (NSString *) name
{
    return name;
}

- (id <NPPObject>) parent
{
    return parent;
}

- (UInt32) objectID
{
    return objectID;
}

- (void) setName:(NSString *)newName
{
    if ( name != newName )
    {
        [ name release ];

        name = [ newName retain ];
    }
}

- (void) setParent:(id <NPPObject>)newParent
{
    if ( parent != newParent )
    {
        parent = newParent;
    }
}

@end
