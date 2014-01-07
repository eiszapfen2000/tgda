#import <Foundation/NSPointerArray.h>
#import "Core/Basics/NpCrc32.h"
#import "Core/Container/NSPointerArray+NPEngine.h"
#import "Core/Container/NSPointerArray+NPPObject.h"
#import "NPObjectManager.h"


@implementation NPObjectManager

- (id) init
{
    return [ self initWithName:@"NPEngineCore Object Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super init ];

    ASSIGNCOPY(name, newName);
    objectID = crc32_of_pointer(self);

    sync = [[ NSRecursiveLock alloc ] init ];

    NSPointerFunctionsOptions options
        = NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality;

    objects = [[ NSPointerArray alloc ] initWithOptions:options ];
    //[ objects setCount:2048 ];

    return self;
}

- (void) dealloc
{
    [ objects compact ];

    NSUInteger numberOfLeakedObjects = [ objects count ];
    for ( NSUInteger i = 0; i < numberOfLeakedObjects; i++ )
    {
        NSLog(@"%@", [(id)[ objects pointerAtIndex:i ] description ]);
    }

    DESTROY(objects);
    DESTROY(sync);
    DESTROY(name);

    [ super dealloc ];
}

- (void) addObject:(id <NPPObject>)newObject
{
    [ sync lock ];
    [ objects addPointer:newObject ];
    [ sync unlock ];
}

- (void) removeObject:(id <NPPObject>)object
{
    [ sync lock ];
    [ objects removePointerIdenticalTo:object ];
    [ sync unlock ];
}

- (id <NPPObject>) objectByName:(NSString *)objectName
{
    [ sync lock ];
    id < NPPObject > result = [ objects pointerWithName:objectName ];
    [ sync unlock ];

    return result;
}

- (NSString *) name
{
    return name;
}

- (uint32_t) objectID
{
    return objectID;
}

- (void) setName:(NSString *)newName
{
    ASSIGNCOPY(name, newName);
}

- (void) setObjectID:(uint32_t)newObjectID
{
    objectID = newObjectID;
}

@end
