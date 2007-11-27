#import "NPObject.h"
#import "Core/Basics/Crc32.h"

@implementation NPObject

- (id) init
{
    self = [ self initWithName:@"" parent:nil ];

    return self;
}

- (id) initWithName:(NSString *)newName
{
    self = [ self initWithName:newName parent:nil ];

    return self;
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super init ];

    name = [ newName retain ];

    //Weak reference
    parent = newParent;

    objectID = [ self _generateIDFromPointer ];

    return self;
} 

- (void) dealloc
{
    [ name release ];
    parent = nil;

    [ super dealloc ];
}

- (NSString *) name
{
    return name;
}

- (void) setName:(NSString *)newName
{
    if ( name != newName )
    {
        [ name release ];

        name = [ newName retain ];

    }
}

- (NPObject *) parent
{
    return parent;
}

- (void) setParent:(NPObject *)newParent
{
    if ( parent != newParent )
    {
        parent = newParent;
    }
}

- (UInt32) objectID
{
    return objectID;
}

- (UInt32) _generateIDFromPointer
{
    return crc32_of_pointer(self);
}

- (NSString *) description
{
    return [ NSString stringWithFormat: @"ID:%ud Name:%@", objectID, name ];
}

@end
