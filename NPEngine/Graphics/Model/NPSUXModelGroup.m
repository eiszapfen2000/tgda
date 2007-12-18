#import "NPSUXModelGroup.h"

@implementation NPSUXModelGroup

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPSUXModelGroup" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    primitiveType = -1;
    firstIndex = -1;
    lastIndex = -1;
    materialInstanceIndex = -1;

    return self;
}

- (void) loadFromFile:(NPFile *)file
{
    NSString * groupName = [ file readSUXString ];
    NSLog(groupName);
    [ self setName:groupName ];
    [ groupName release ];

    [ file readInt32:&primitiveType ];
    [ file readInt32:&firstIndex ];
    [ file readInt32:&lastIndex ];
    [ file readInt32:&materialInstanceIndex ];
}

@end
