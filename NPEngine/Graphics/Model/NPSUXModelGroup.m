#import "NPSUXModelGroup.h"
#import "Graphics/Model/NPVertexBuffer.h"
#import "Graphics/Model/NPSUXModelLod.h"
#import "Core/NPEngineCore.h"

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

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    NSString * groupName = [ file readSUXString ];
    [ self setName:groupName ];
    [ groupName release ];
    NPLOG(([NSString stringWithFormat:@"Group Name: %@", name]));

    [ file readInt32:&primitiveType ];

    [ file readInt32:&firstIndex ];
    NPLOG(([NSString stringWithFormat:@"First Index: %d", firstIndex]));
    [ file readInt32:&lastIndex ];
    NPLOG(([NSString stringWithFormat:@"Last Index: %d", lastIndex]));

    [ file readInt32:&materialInstanceIndex ];
    NPLOG(([NSString stringWithFormat:@"Material Instance Index: %d", materialInstanceIndex]));

    return YES;
}

- (void) reset
{
    primitiveType = -1;
    firstIndex = -1;
    lastIndex = -1;
    materialInstanceIndex = -1;

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}

- (void) render
{
    [[(NPSUXModelLod *)parent vertexBuffer ] renderElementWithFirstindex:firstIndex andLastindex:lastIndex ];
}

@end
