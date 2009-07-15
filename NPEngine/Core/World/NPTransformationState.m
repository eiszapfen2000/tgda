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

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

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

- (void) setModelMatrix:(FMatrix4 *)newModelMatrix
{
    *modelMatrix = *newModelMatrix;

    recomputeModelViewMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
}

- (void) setViewMatrix:(FMatrix4 *)newViewMatrix
{
    *viewMatrix = *newViewMatrix;

    recomputeModelViewMatrix = YES;
    recomputeViewProjectionMatrix = YES;
    recomputeModelViewProjectionMatrix = YES;
    recomputeInverseViewProjectionMatrix = YES;    
}

- (void) setProjectionMatrix:(FMatrix4 *)newProjectionMatrix
{
    *projectionMatrix = *newProjectionMatrix;

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
