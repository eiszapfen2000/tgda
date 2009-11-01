#import "NP.h"
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

    //effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"attractor.cgfx" ];
    startingPoint = fv3_alloc_init();

    [ self setupCoordinateCross ];

	return self;
}

- (void) dealloc
{
    startingPoint = fv3_free(startingPoint);
    [ coordinateCross release ];

	[ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary
{
    NSString * attractorTypeName = [ dictionary objectForKey:@"Type" ];

    if ( [ attractorTypeName isEqual:@"Lorentz" ] )
    {
        sigma = [[ dictionary objectForKey:@"Sigma" ] floatValue ];
        b = [[ dictionary objectForKey:@"B" ] floatValue ];
        r = [[ dictionary objectForKey:@"R" ] floatValue ];
        numberOfIterations = [[ dictionary objectForKey:@"Iterations" ] intValue ];

        NSArray * startingPointStrings = [ dictionary objectForKey:@"StartingPoint" ];
        startingPoint->x = [[ startingPointStrings objectAtIndex:0 ] floatValue ];
        startingPoint->y = [[ startingPointStrings objectAtIndex:1 ] floatValue ];
        startingPoint->z = [[ startingPointStrings objectAtIndex:2 ] floatValue ];

        return YES;
    }

    if ( [ attractorTypeName isEqual:@"Roessler" ] )
    {
        a = [[ dictionary objectForKey:@"A" ] floatValue ];
        b = [[ dictionary objectForKey:@"B" ] floatValue ];
        c = [[ dictionary objectForKey:@"C" ] floatValue ];
        numberOfIterations = [[ dictionary objectForKey:@"Iterations" ] intValue ];

        NSArray * startingPointStrings = [ dictionary objectForKey:@"StartingPoint" ];
        startingPoint->x = [[ startingPointStrings objectAtIndex:0 ] floatValue ];
        startingPoint->y = [[ startingPointStrings objectAtIndex:1 ] floatValue ];
        startingPoint->z = [[ startingPointStrings objectAtIndex:2 ] floatValue ];

        return YES;
    }

    return NO;
}

- (void) reset
{

}

- (void) setA:(Float)newA
{
    a = newA;
}

- (void) setB:(Float)newB
{
    b = newB;
}

- (void) setC:(Float)newC
{
    c = newC;
}

- (void) setR:(Float)newR
{
    r = newR;
}

- (void) setSigma:(Float)newSigma
{
    sigma = newSigma;
}

- (void) setNumberOfIterations:(Int32)newNumberOfIterations
{
    numberOfIterations = newNumberOfIterations;
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

/*- (FVector3) generateLorentzDerivativeWithParametersSigma:(Float)sigma
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
}

- (FVector3) generateRoesslerDerivativeWithParametersA:(Float)a
                                                     B:(Float)b
                                                     C:(Float)c
                                          currentPoint:(FVector3)currentPoint
{
    FVector3 result;
    result.x = -currentPoint.y - currentPoint.z;
    result.y = currentPoint.x + a * currentPoint.y;
    result.z = b * currentPoint.z * ( currentPoint.x - c );

    return result;
}

- (void) generateRoesslerAttractorWithParametersA:(Float)a
                                                B:(Float)b
                                                C:(Float)c
                               numberOfIterations:(UInt32)numberOfIterations
                                    startingPoint:(FVector3)startingPoint
{
}
*/

- (void) update:(Float)frameTime
{

}

- (void) render
{
    //[ coordinateCross render ];
}

@end
