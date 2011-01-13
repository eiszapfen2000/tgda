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
    NSUInteger numberOfLeakedObjects = [ objects count ];
    if ( numberOfLeakedObjects > 0 )
    {
        NSLog(@"Memory leak, listing leaked objects:");

        for ( NSUInteger i = 0; i < numberOfLeakedObjects; i++ )
        {
            NSLog(@"%@", [(id)[[ objects objectAtIndex:i ] pointerValue ] description ]);
        }

    }

    DESTROY(objects);
    DESTROY(name);
    parent = nil;

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
    id <NPPObject> object = nil;
    NSUInteger numberOfObjects = [ objects count ];

    for ( NSUInteger i = 0; i < numberOfObjects; i++ )
    {
        object = [[ objects objectAtIndex:i ] pointerValue ];

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
    parent = newParent;
}

@end
