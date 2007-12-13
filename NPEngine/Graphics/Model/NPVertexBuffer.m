#import "NPVertexBuffer.h"

@implementation NPVertexBuffer

- (id) init
{
    return [ self initWithName:@"NPVertexBuffer" parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    return self;
}

@end
