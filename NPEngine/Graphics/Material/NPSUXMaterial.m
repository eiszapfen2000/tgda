#import "NPSUXMaterial.h"

@implementation NPSUXMaterial

- (id) init
{
    return [ self initWithName:@"NPSUXMaterial" parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    return self;
}

- (void)loadFromFile:(NPFile *)file
{
}

@end
