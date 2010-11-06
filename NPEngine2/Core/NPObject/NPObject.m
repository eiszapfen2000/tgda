#import "Core/Basics/NpCrc32.h"
#import "NPObject.h"
//#import "NPObjectManager.h"
//#import "Core/NPEngineCore.h"

NSString* const NPEngineErrorDomain = @"NPEngineErrorDomain";

@implementation NPObject

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

    pointer = [[ NSValue alloc ] initWithBytes:&self objCType:@encode(void *) ];
    //[[[ NPEngineCore instance ] objectManager ] addObject:pointer ];

    return self;
} 

- (void) dealloc
{
    DESTROY(name);
    parent = nil;

    //[[[ NPEngineCore instance ] objectManager ] removeObject:pointer ];
    DESTROY(pointer);

    [ super dealloc ];
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

- (NSString *) description
{
    return [ NSString stringWithFormat: @"ID:%ud retainCount:%u Name:%@ Class:%@",
             objectID, (uint32_t)[self retainCount], name, NSStringFromClass([self class]) ];
}

@end

/*
@implementation NPObject ( NPCoding )

- (void) encodeWithCoder:(NSCoder *)coder
{
    if ( [coder allowsKeyedCoding] )
    {
        [ coder encodeObject:name forKey:@"Name" ];
        [ coder encodeConditionalObject:parent forKey:@"Parent" ];
    }
    else
    {
        [ coder encodeObject:name ];
        [ coder encodeConditionalObject:parent ];
    }
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [ super init ];

    if ( [coder allowsKeyedCoding] )
    {
        name = [ [ coder decodeObjectForKey:@"Name" ] retain ];
        parent = [ coder decodeObjectForKey:@"Parent" ];
    }
    else
    {
        name = [ [ coder decodeObject ] retain ];
        parent = [ coder decodeObject ];
    }

    objectID = crc32_of_pointer(self);

    return self;
}

@end
*/
