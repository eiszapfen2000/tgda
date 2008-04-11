#import "TOOceanSurface.h"
#import "Core/Basics/NpMemory.h"

@implementation TOOceanSurface

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"TOOceanSurface" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    positions = NULL;
    indices = NULL;

    ready = NO;
    changed = NO;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) setup
{
    positions = ALLOC_ARRAY(Float,9);
    positions[1]=positions[2]=positions[4]=positions[5]=positions[6]=positions[8]=0.0f;
    positions[0]=-0.5f; positions[3]=positions[7]=0.5f;

    indices = ALLOC_ARRAY(Int,3);
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;

    ready = YES;
    changed = YES;
}

@end
