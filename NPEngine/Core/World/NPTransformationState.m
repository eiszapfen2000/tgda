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

    modelMatrix                 = fm4_alloc_init();
    viewMatrix                  = fm4_alloc_init();
    projectionMatrix            = fm4_alloc_init();
    modelViewMatrix             = fm4_alloc_init();
    viewProjectionMatrix        = fm4_alloc_init();
    modelViewProjectionMatrix   = fm4_alloc_init();
    inverseViewProjectionMatrix = fm4_alloc_init();

    return self;
}

- (void) dealloc
{
    fm4_free(modelMatrix);
    fm4_free(viewMatrix);
    fm4_free(projectionMatrix);
    fm4_free(modelViewMatrix);
    fm4_free(viewProjectionMatrix);
    fm4_free(modelViewProjectionMatrix);
    fm4_free(inverseViewProjectionMatrix);

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

- (FMatrix4 *) modelViewMatrix
{
    return modelViewMatrix;
}

- (FMatrix4 *) viewProjectionMatrix
{
    return viewProjectionMatrix;
}

- (FMatrix4 *) modelViewProjectionMatrix
{
    return modelViewProjectionMatrix;
}

- (FMatrix4 *) inverseViewProjectionMatrix
{
    return inverseViewProjectionMatrix;
}

- (void) computeCombinedMatrices
{
    fm4_mm_multiply_m(viewMatrix,modelMatrix,modelViewMatrix);
    fm4_mm_multiply_m(projectionMatrix,viewMatrix,viewProjectionMatrix);
    fm4_mm_multiply_m(projectionMatrix,modelViewMatrix,modelViewProjectionMatrix);
    fm4_m_inverse_m(viewProjectionMatrix,inverseViewProjectionMatrix);
}

@end
