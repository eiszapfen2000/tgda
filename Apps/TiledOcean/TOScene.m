#import "TOScene.h"

#import "Graphics/Model/NPVertexBuffer.h"
#import "Graphics/Model/NPSUXGroup.h"
#import "Graphics/Model/NPSUXModelLod.h"
#import "Graphics/Model/NPSUXModel.h"
#import "Graphics/Model/NPModelManager.h"

#import "Graphics/Camera/NPCamera.h"
#import "Graphics/Camera/NPCameraManager.h"

@implementation TOScene

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"TOScene" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    camera = nil;
    surface = nil;
    ready = NO;

    return self;
}

- (void) dealloc
{
    [ camera release ];
    [ surface release ];

    [ super dealloc ];
}

- (void) setup
{
    surface = [[ NPSUXModel alloc ] initWithParent:self ];
}

- (void) update
{
    [ camera update ];
}

- (void) render
{
    [ camera render ];
    [ surface render ];
}

@end
