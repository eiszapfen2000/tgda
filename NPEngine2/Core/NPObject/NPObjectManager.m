#import "NPObjectManager.h"
#import "Core/Basics/NpCrc32.h"

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

    ASSIGNCOPY(name, newName);

    //Weak reference
    parent = newParent;

    objectID = crc32_of_pointer(self);
    objects = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    DESTROY(name);
    parent = nil;

    if ( [ objects count ] > 0 )
    {
        NSLog(@"Memory leak, listing leaked objects:");

        NSEnumerator * e = [ objects objectEnumerator ];
        NSValue * o;

        while (( o = [ e nextObject ] ))
        {
            NSLog(@"%@", [(id)[ o pointerValue ] description ]);
        }
    }

    DESTROY(objects);

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

- (id <NPPObject>) objectByName:(NSString *)objectName
{
    NSEnumerator * objectsEnumerator = [ objects objectEnumerator ];
    NSValue * value;
    id <NPPObject> object;

    while ( (value = [ objectsEnumerator nextObject ]) )
    {
        object = (id <NPPObject>)[ value pointerValue ];

        if ( [[ object name ] isEqual:objectName ] == YES )
        {
            return object;
        }
    }

    return nil;
}

- (NSString *) name
{
    return name;
}

- (id <NPPObject>) parent
{
    return parent;
}

- (uint32_t) objectID
{
    return objectID;
}

- (void) setName:(NSString *)newName
{
    ASSIGNCOPY(name, newName);
}

- (void) setParent:(id <NPPObject>)newParent
{
    if ( parent != newParent )
    {
        parent = newParent;
    }
}

@end
