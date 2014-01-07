#import "Core/Basics/NpCrc32.h"
#import "NPObjectManager.h"
#import "Core/NPEngineCore.h"
#import "NPObject.h"

@implementation NPObject

- (id) initWithName:(NSString *)newName
{
    self = [ super init ];

    name = [newName copy ];
    objectID = crc32_of_pointer(self);

    [[[ NPEngineCore instance ] objectManager ] addObject:self ];

    return self;
} 

- (void) dealloc
{
    DESTROY(name);
    [[[ NPEngineCore instance ] objectManager ] removeObject:self ];

    [ super dealloc ];
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

- (NSString *) description
{
    return [ NSString stringWithFormat:@"Class:%@ Name:%@ retainCount:%lu ID:%ud",
             NSStringFromClass([self class]), name, [self retainCount], objectID ];
}

@end

