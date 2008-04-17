#import "TOScene.h"

#import "Graphics/Model/NPVertexBuffer.h"
#import "Graphics/Model/NPSUXModelGroup.h"
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

- (NPSUXModel *) surface
{
    return surface;
}

- (NPSUXModelLod *) surfaceLod
{
    return surfaceLod;
}

- (NPSUXModelGroup *) surfaceGroup
{
    return surfaceGroup;
}

- (NPVertexBuffer *) surfaceVBO
{
    return surfaceVBO;
}

- (void) setup
{
    surface = [[ NPSUXModel alloc ] initWithParent:self ];
    surfaceLod = [[ NPSUXModelLod alloc ] initWithParent:surface ];
    surfaceGroup = [[ NPSUXModelGroup alloc ] initWithParent:surfaceLod ];
    surfaceVBO = [[ NPVertexBuffer alloc ] initWithParent:surfaceLod ];

    [ surfaceLod setVertexBuffer:surfaceVBO ];
    [ surfaceLod addGroup:surfaceGroup ];
    [ surface addLod:surfaceLod ];
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
