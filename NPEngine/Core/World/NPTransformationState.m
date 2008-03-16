#import "NPTransformationState.h"

@implementation NPTransformationState

- (id) init
{
    return [ self initWithName:@"NPEngine Core Transformation State" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    modelMatrix = fm4_alloc_init();
    viewMatrix = fm4_alloc_init();
    projectionMatrix = fm4_alloc_init();

    return self;
}

- (void) dealloc
{
    fm4_free(modelMatrix);
    fm4_free(viewMatrix);
    fm4_free(projectionMatrix);

    [ super dealloc ];
}

- (FMatrix4 *)modelMatrix
{
    return modelMatrix;
}

- (void) setModelMatrix:(FMatrix4 *)newModelMatrix
{
    *modelMatrix = *newModelMatrix;
}

- (FMatrix4 *)viewMatrix
{
    return viewMatrix;
}

- (void) setViewMatrix:(FMatrix4 *)newViewMatrix
{
    *viewMatrix = *newViewMatrix;
}

- (FMatrix4 *)projectionMatrix
{
    return projectionMatrix;
}

- (void) setProjectionMatrix:(FMatrix4 *)newProjectionMatrix
{
    *projectionMatrix = *newProjectionMatrix;
}

@end
