#import "NPTransformationState.h"

@implementation NPTransformationState

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    modelMatrix                         = fm4_alloc_init();
    inverseModelMatrix                  = fm4_alloc_init();
    viewMatrix                          = fm4_alloc_init();
    inverseViewMatrix                   = fm4_alloc_init();
    projectionMatrix                    = fm4_alloc_init();
    inverseProjectionMatrix             = fm4_alloc_init();
    modelViewMatrix                     = fm4_alloc_init();
    inverseModelViewMatrix              = fm4_alloc_init();
    viewProjectionMatrix                = fm4_alloc_init();
    inverseViewProjectionMatrix         = fm4_alloc_init();
    modelViewProjectionMatrix           = fm4_alloc_init();
    inverseModelViewProjectionMatrix    = fm4_alloc_init();

    recomputeInverseModelMatrix = NO;
    recomputeInverseViewMatrix = NO;
    recomputeInverseProjectionMatrix = NO;
    recomputeModelViewMatrix = NO;
    recomputeInverseModelViewMatrix = NO;
    recomputeViewProjectionMatrix = NO;
    recomputeInverseViewProjectionMatrix = NO;
    recomputeModelViewProjectionMatrix = NO;
    recomputeInverseModelViewProjectionMatrix = NO;

    return self;
}

- (void) dealloc
{
    fm4_free(modelMatrix);
    fm4_free(inverseModelMatrix);
    fm4_free(viewMatrix);
    fm4_free(inverseViewMatrix);
    fm4_free(projectionMatrix);
    fm4_free(inverseProjectionMatrix);
    fm4_free(modelViewMatrix);
    fm4_free(inverseModelViewMatrix);
    fm4_free(viewProjectionMatrix);
    fm4_free(inverseViewProjectionMatrix);
    fm4_free(modelViewProjectionMatrix);
    fm4_free(inverseModelViewProjectionMatrix);

    [ super dealloc ];
}

- (void) reset
{
    fm4_m_set_identity(modelMatrix);
    fm4_m_set_identity(viewMatrix);
    fm4_m_set_identity(projectionMatrix);

    recomputeInverseModelMatrix = YES;
    recomputeInverseViewMatrix = YES;
    recomputeInverseProjectionMatrix = YES;
    recomputeModelViewMatrix = YES;
    recomputeInverseModelViewMatrix = YES;
    recomputeViewProjectionMatrix = YES;
    recomputeInverseViewProjectionMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
    recomputeInverseModelViewProjectionMatrix = YES;
}

- (void) resetModelMatrix
{
    fm4_m_set_identity(modelMatrix);

    recomputeInverseModelMatrix = YES;
    recomputeModelViewMatrix = YES;
    recomputeInverseModelViewMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
    recomputeInverseModelViewProjectionMatrix = YES;
}

- (void) resetViewMatrix
{
    fm4_m_set_identity(viewMatrix);

    recomputeInverseViewMatrix = YES;
    recomputeInverseProjectionMatrix = YES;
    recomputeModelViewMatrix = YES;
    recomputeInverseModelViewMatrix = YES;
    recomputeViewProjectionMatrix = YES;
    recomputeInverseViewProjectionMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
    recomputeInverseModelViewProjectionMatrix = YES;
}

- (void) resetProjectionMatrix
{
    fm4_m_set_identity(projectionMatrix);

    recomputeInverseProjectionMatrix = YES;
    recomputeViewProjectionMatrix = YES;
    recomputeInverseViewProjectionMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
    recomputeInverseModelViewProjectionMatrix = YES;
}


- (FMatrix4 *) modelMatrix
{
    return modelMatrix;
}

- (FMatrix4 *) inverseModelMatrix
{
    if ( recomputeInverseModelMatrix == YES )
    {
        [ self computeInverseModelMatrix ];
    }

    return inverseModelMatrix;
}

- (FMatrix4 *) viewMatrix
{
    return viewMatrix;
}

- (FMatrix4 *) inverseViewMatrix
{
    if ( recomputeInverseViewMatrix == YES )
    {
        [ self computeInverseViewMatrix ];
    }

    return inverseViewMatrix;
}

- (FMatrix4 *)  projectionMatrix
{
    return projectionMatrix;
}

- (FMatrix4 *) inverseProjectionMatrix
{
    if ( recomputeInverseProjectionMatrix == YES )
    {
        [ self computeInverseProjectionMatrix ];
    }

    return inverseProjectionMatrix;
}

- (FMatrix4 *) modelViewMatrix
{
    if ( recomputeModelViewMatrix == YES )
    {
        [ self computeModelViewMatrix ];
    }

    return modelViewMatrix;
}

- (FMatrix4 *) inverseModelViewMatrix
{
    if ( recomputeInverseModelViewMatrix == YES )
    {
        [ self computeInverseModelViewMatrix ];
    }

    return inverseModelViewMatrix;
}

- (FMatrix4 *) viewProjectionMatrix
{
    if ( recomputeViewProjectionMatrix == YES )
    {
        [ self computeViewProjectionMatrix ];
    }

    return viewProjectionMatrix;
}

- (FMatrix4 *) inverseViewProjectionMatrix
{
    if ( recomputeInverseViewProjectionMatrix == YES )
    {
        [ self computeInverseViewProjectionMatrix ];
    }

    return inverseViewProjectionMatrix;
}

- (FMatrix4 *) modelViewProjectionMatrix
{
    if ( recomputeModelViewProjectionMatrix == YES )
    {
        [ self computeModelViewProjectionMatrix ];
    }

    return modelViewProjectionMatrix;
}

- (FMatrix4 *) inverseModelViewProjectionMatrix
{
    if ( recomputeInverseModelViewProjectionMatrix == YES )
    {
        [ self computeInverseModelViewProjectionMatrix ];
    }

    return inverseModelViewProjectionMatrix;
}

- (void) setFModelMatrix:(const FMatrix4 * const)newModelMatrix
{
    *modelMatrix = *newModelMatrix;

    recomputeModelViewMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
}

- (void) setFViewMatrix:(const FMatrix4 * const)newViewMatrix
{
    *viewMatrix = *newViewMatrix;

    recomputeModelViewMatrix = YES;
    recomputeViewProjectionMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
    recomputeInverseViewProjectionMatrix = YES;    
}

- (void) setFProjectionMatrix:(const FMatrix4 * const)newProjectionMatrix
{
    *projectionMatrix = *newProjectionMatrix;

    recomputeViewProjectionMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
    recomputeInverseViewProjectionMatrix = YES;
}

- (void) setModelMatrix:(const Matrix4 * const)newModelMatrix
{
    fm4_m_init_with_m4(modelMatrix, newModelMatrix);

    recomputeModelViewMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
}

- (void) setViewMatrix:(const Matrix4 * const)newViewMatrix
{
    fm4_m_init_with_m4(viewMatrix, newViewMatrix);

    recomputeModelViewMatrix = YES;
    recomputeViewProjectionMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
    recomputeInverseViewProjectionMatrix = YES;    
}

- (void) setProjectionMatrix:(const Matrix4 * const)newProjectionMatrix
{
    fm4_m_init_with_m4(projectionMatrix, newProjectionMatrix);

    recomputeViewProjectionMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
    recomputeInverseViewProjectionMatrix = YES;
}

- (void) computeInverseModelMatrix
{
    fm4_m_inverse_m(modelMatrix, inverseModelMatrix);
    recomputeInverseModelMatrix = NO;
}

- (void) computeInverseViewMatrix
{
    fm4_m_inverse_m(viewMatrix, inverseViewMatrix);
    recomputeInverseViewMatrix = NO;
}

- (void) computeInverseProjectionMatrix
{
    fm4_m_inverse_m(projectionMatrix, inverseProjectionMatrix);
    recomputeInverseProjectionMatrix = NO;
}

- (void) computeModelViewMatrix
{
    fm4_mm_multiply_m(viewMatrix, modelMatrix, modelViewMatrix);
    recomputeModelViewMatrix = NO;
}

- (void) computeInverseModelViewMatrix
{
    if ( recomputeModelViewMatrix == YES )
    {
        [ self computeModelViewMatrix ];
    }

    fm4_m_inverse_m(modelViewMatrix, inverseModelViewMatrix);
    recomputeInverseModelViewMatrix = NO;    
}

- (void) computeViewProjectionMatrix
{
    fm4_mm_multiply_m(projectionMatrix, viewMatrix, viewProjectionMatrix);
    recomputeViewProjectionMatrix = NO;
}

- (void) computeInverseViewProjectionMatrix
{
    if ( recomputeViewProjectionMatrix == YES )
    {
        [ self computeViewProjectionMatrix ];
    }

    fm4_m_inverse_m(viewProjectionMatrix, inverseViewProjectionMatrix);
    recomputeInverseViewProjectionMatrix = NO;    
}

- (void) computeModelViewProjectionMatrix
{
    FMatrix4 tmp;
    fm4_mm_multiply_m(projectionMatrix, viewMatrix, &tmp);
    fm4_mm_multiply_m(&tmp, modelMatrix, modelViewProjectionMatrix);
    recomputeModelViewProjectionMatrix = NO;
}

- (void) computeInverseModelViewProjectionMatrix
{
    if ( recomputeModelViewProjectionMatrix == YES )
    {
        [ self computeModelViewProjectionMatrix ];
    }

    fm4_m_inverse_m(modelViewProjectionMatrix, inverseModelViewProjectionMatrix);
    recomputeInverseModelViewProjectionMatrix = NO;
}


@end
