#import "NP.h"
#import "FCore.h"
#import "FAttractor.h"

@implementation FAttractor

- (id) init
{
	return [ self initWithName:@"FAttractor" ];
}

- (id) initWithName:(NSString *)newName;
{
	return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
{
	self = [ super initWithName:newName parent:newParent ];

    mode = -1;

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"attractor.cgfx" ];

    [ self setupCoordinateCross ];

	return self;
}

- (void) dealloc
{
    [ coordinateCross release ];
    [ roesslerAttractor release ];
    [ lorentzAttractor release ];

	[ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary
{
    return YES;
}

- (void) reset
{

}

- (NpState) mode
{
    return mode;
}

- (void) setMode:(NpState)newMode
{
    mode = newMode;
}

- (void) setupCoordinateCross
{
    TEST_RELEASE(coordinateCross);

    coordinateCross = [[ NPVertexBuffer alloc ] initWithName:@"CoordCross" parent:self ];

    FVector3 * positions = ALLOC_ARRAY(FVector3, 6);
    FVector3 * colors    = ALLOC_ARRAY(FVector3, 6);

    positions[0] = (FVector3){-10.0f, 0.0f, 0.0f };
    positions[1] = (FVector3){ 10.0f, 0.0f, 0.0f };
    positions[2] = (FVector3){0.0f, -10.0f, 0.0f };
    positions[3] = (FVector3){0.0f,  10.0f, 0.0f };
    positions[4] = (FVector3){0.0f, 0.0f, -10.0f };
    positions[5] = (FVector3){0.0f, 0.0f,  10.0f };

    colors[0] = (FVector3){1.0f, 0.0f, 0.0f };
    colors[1] = (FVector3){1.0f, 0.0f, 0.0f };
    colors[2] = (FVector3){0.0f, 1.0f, 0.0f };
    colors[3] = (FVector3){0.0f, 1.0f, 0.0f };
    colors[4] = (FVector3){0.0f, 0.0f, 1.0f };
    colors[5] = (FVector3){0.0f, 0.0f, 1.0f };

    Int32 * indices = ALLOC_ARRAY(Int32, 6);

    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 3;
    indices[4] = 4;
    indices[5] = 5;

    [ coordinateCross setPositions:(Float *)positions 
               elementsForPosition:3 
                        dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT
                       vertexCount:6 ];

    [ coordinateCross setColors:(Float *)colors 
               elementsForColor:3 
                     dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT ];

    [ coordinateCross setIndices:indices
                      indexCount:6 ];
}

- (FVector3) generateLorentzDerivativeWithParametersSigma:(Float)sigma
                                                        B:(Float)b
                                                        R:(Float)r
                                             currentPoint:(FVector3)currentPoint
{
    FVector3 result;
    result.x = sigma * ( currentPoint.y - currentPoint.x );
    result.y = r * currentPoint.x - currentPoint.y - currentPoint.x * currentPoint.z;
    result.z = currentPoint.x * currentPoint.y - b * currentPoint.z;

    return result;
}

- (void) generateLorentzAttractorWithParametersSigma:(Float)sigma
                                                   B:(Float)b
                                                   R:(Float)r
                                  numberOfIterations:(UInt32)numberOfIterations
                                       startingPoint:(FVector3)startingPoint
{
    TEST_RELEASE(lorentzAttractor);
    lorentzAttractor  = [[ NPVertexBuffer alloc ] initWithName:@"Lorentz"  parent:self ];

    FVector3 * positions = ALLOC_ARRAY(FVector3, numberOfIterations);
    Int32 * indices = ALLOC_ARRAY(Int32, numberOfIterations);

    float factor = 0.01f;

    FVector3 currentPosition = startingPoint;
    FVector3 currentDerivative = [ self generateLorentzDerivativeWithParametersSigma:sigma B:b R:r currentPoint:currentPosition ];

    for ( UInt32 i = 0; i < numberOfIterations; i++ )
    {
        positions[i] = currentPosition;
        indices[i] = i;

        currentDerivative = [ self generateLorentzDerivativeWithParametersSigma:sigma B:b R:r currentPoint:currentPosition ];
        currentPosition.x = currentPosition.x + factor * currentDerivative.x;
        currentPosition.y = currentPosition.y + factor * currentDerivative.y;
        currentPosition.z = currentPosition.z + factor * currentDerivative.z;        
    }

    [ lorentzAttractor setPositions:(Float *)positions
                elementsForPosition:3
                         dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT
                        vertexCount:numberOfIterations ];

    [ lorentzAttractor setIndices:indices indexCount:numberOfIterations ];
}

- (FVector3) generateRoesslerDerivativeWithParametersA:(Float)a
                                                     B:(Float)b
                                                     C:(Float)c
                                          currentPoint:(FVector3)currentPoint
{
    FVector3 result;
    result.x = -currentPoint.y - currentPoint.z;
    result.y = currentPoint.x + a * currentPoint.y;
    result.z = b + currentPoint.z * ( currentPoint.x - c );

    return result;
}

- (void) generateRoesslerAttractorWithParametersA:(Float)a
                                                B:(Float)b
                                                C:(Float)c
                               numberOfIterations:(UInt32)numberOfIterations
                                    startingPoint:(FVector3)startingPoint
{
    // starting point 0.5 0.5 0.5 gives good results

    TEST_RELEASE(roesslerAttractor);
    roesslerAttractor = [[ NPVertexBuffer alloc ] initWithName:@"Roessler" parent:self ];

    FVector3 * positions = ALLOC_ARRAY(FVector3, numberOfIterations);
    Int32 * indices = ALLOC_ARRAY(Int32, numberOfIterations);

    float factor = 0.01f;

    FVector3 currentPosition = startingPoint;
    FVector3 currentDerivative = [ self generateRoesslerDerivativeWithParametersA:a B:b C:c currentPoint:currentPosition ];

    for ( UInt32 i = 0; i < numberOfIterations; i++ )
    {
        positions[i] = currentPosition;
        indices[i] = i;

        currentDerivative = [ self generateRoesslerDerivativeWithParametersA:a B:b C:c currentPoint:currentPosition ];
        currentPosition.x = currentPosition.x + factor * currentDerivative.x;
        currentPosition.y = currentPosition.y + factor * currentDerivative.y;
        currentPosition.z = currentPosition.z + factor * currentDerivative.z;        
    }

    [ roesslerAttractor setPositions:(Float *)positions
                elementsForPosition:3
                         dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT
                        vertexCount:numberOfIterations ];

    [ roesslerAttractor setIndices:indices indexCount:numberOfIterations ];
}

- (void) generateAttractorOfType:(NpState)Type
                 withParametersA:(Float)a
                               B:(Float)b
                               C:(Float)c
                               R:(Float)r
                           Sigma:(Float)sigma
              numberOfIterations:(UInt32)numberOfIterations
                   startingPoint:(FVector3)startingPoint
{
    switch ( Type )
    {
        case ATTRACTOR_LORENTZ:
        {
            [ self generateLorentzAttractorWithParametersSigma:sigma
                                                             B:b
                                                             R:r
                                            numberOfIterations:numberOfIterations
                                                 startingPoint:startingPoint ];

            mode = ATTRACTOR_LORENTZ;

            break;
        }

        case ATTRACTOR_ROESSLER:
        {
            [ self generateRoesslerAttractorWithParametersA:a
                                                          B:b
                                                          C:c
                                         numberOfIterations:numberOfIterations
                                              startingPoint:startingPoint ];

            mode = ATTRACTOR_ROESSLER;
            break;
        }

        default:
        {
            NSLog(@"Unknown attractor type %d", Type);
        }

    }
}


- (void) update:(Float)frameTime
{

}

- (void) render:(BOOL)drawCoordinateCross
{
    [[[ NP Core ] transformationState ] resetModelMatrix ];

    if ( drawCoordinateCross == YES )
    {
        [ effect activateTechniqueWithName:@"coordinate_cross" ];
        [ coordinateCross renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_LINES ];
        [ effect deactivate ];
    }

    FMatrix4 scale;

    if ( (mode == ATTRACTOR_LORENTZ) && (lorentzAttractor != nil) )
    {
        fm4_msss_scale_matrix_xyz(&scale, 0.1f, 0.1f, 0.1f);
        [[[ NP Core ] transformationState ] setModelMatrix:&scale ];

        [ effect activateTechniqueWithName:@"attractor" ];
        [ lorentzAttractor renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_LINE_STRIP ];
        [ effect deactivate ];
    }

    if ( (mode == ATTRACTOR_ROESSLER) && (roesslerAttractor != nil) )
    {
        fm4_msss_scale_matrix_xyz(&scale, 0.5f, 0.5f, 0.5f);
        [[[ NP Core ] transformationState ] setModelMatrix:&scale ];

        [ effect activateTechniqueWithName:@"attractor" ];
        [ roesslerAttractor renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_LINE_STRIP ];
        [ effect deactivate ];
    }
}

@end
