#import <Foundation/NSPointerArray.h>
#import "Core/Basics/NpCrc32.h"
#import "Core/Utilities/NSPointerArray+NPEngine.h"
#import "NSPointerArray+NPPObject.h"
#import "NPObjectManager.h"


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
    parent = nil;

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
