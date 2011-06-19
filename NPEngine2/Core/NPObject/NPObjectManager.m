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

    NSPointerFunctionsOptions options
        = NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality;

    objects = [[ NSPointerArray alloc ] initWithOptions:options ];

    return self;
}

- (void) dealloc
{
    NSUInteger numberOfLeakedObjects = [ objects count ];
    for ( NSUInteger i = 0; i < numberOfLeakedObjects; i++ )
    {
        NSLog(@"%@", [(id)[ objects pointerAtIndex:i ] description ]);
    }

    DESTROY(objects);
    DESTROY(name);

    [ super dealloc ];
}

- (void) addObject:(id <NPPObject>)newObject
{
    [ objects addPointer:newObject ];
}

- (void) removeObject:(id <NPPObject>)object
{
    [ objects removePointerIdenticalTo:object ];
}

- (id <NPPObject>) objectByName:(NSString *)objectName
{
    return [ objects pointerWithName:objectName ];
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
