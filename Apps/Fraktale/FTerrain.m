#import "FTerrain.h"
#import "FPGMImage.h"
#import "NP.h"
#import "FCore.h"

@implementation FTerrain

- (id) init
{
    return [ self initWithName:@"Terrain" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    rngs = [[ NSMutableDictionary alloc ] init ];

    NPRandomNumberGenerator * g;
    g = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_TT800 ];
    [ rngs setObject:g forKey:NP_RNG_TT800 ];

    g = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_CTG ];
    [ rngs setObject:g forKey:NP_RNG_CTG ];

    g = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_MRG ];
    [ rngs setObject:g forKey:NP_RNG_MRG ];

    g = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_CMRG ];
    [ rngs setObject:g forKey:NP_RNG_CMRG ];

    g = [[[ NP Core ] randomNumberGeneratorManager ] mersenneTwisterWithSeed:0L ];
    [ rngs setObject:g forKey:NP_RNG_MERSENNE ];

    size = iv2_alloc_init();
    size->x = size->y = -1;

    currentResolution = iv2_alloc_init();
    lastResolution = iv2_alloc_init();
    baseResolution = iv2_alloc_init();

    currentResolution->x = currentResolution->y = -1;   
    lastResolution->x = lastResolution->y = -1;    
    baseResolution->x = baseResolution->y = -1;

    H = 0.5f;
    sigma = 1.0f;
    variance = 1.0f;
    minimumHeight = 0.0f;
    maximumHeight = 1.0f;

    iterations = 0;
    baseIterations = 0;
    currentIteration = 0;
    iterationsToDo = 0;
    currentLod = 0;

    gaussKernelSigma = 0.75f;
    gaussKernel = NULL;

    [ self setupGaussianKernelForAO ];

    lightPosition = fv3_alloc_init();
    lightPosition->x = 0.0f;
    lightPosition->z = 5.0f;
    lightPosition->y = 10.0f;

    lods = [[ NSMutableArray alloc ] init ];

    gaussianRng = [[[ NP Core ] randomNumberGeneratorManager ] gaussianGeneratorWithName:@"Gaussian"
                                                    firstFixedParameterGenerator:NP_RNG_TT800
                                                   secondFixedParameterGenerator:NP_RNG_TT800 ];

    return self;
}

- (void) dealloc
{
    [ rngs removeAllObjects ];
    [ rngs release ];

    size = iv2_free(size);
    baseResolution = iv2_free(baseResolution);
    currentResolution = iv2_free(currentResolution);
    lastResolution = iv2_free(lastResolution);
    lightPosition = fv3_free(lightPosition);

    [ lods removeAllObjects ];
    [ lods release ];

    [ super dealloc ];
}

- (Int) width
{
    return size->x;
}

- (Int) length
{
    return size->y;
}

- (Float) H
{
    return H;
}

- (Float) sigma
{
    return sigma;
}

- (Float) minimumHeight
{
    return minimumHeight;
}

- (Float) maximumHeight
{
    return maximumHeight;
}

- (Int32) currentLod
{
    return currentLod;
}

- (void) setCurrentLod:(Int32)newCurrentLod
{
    currentLod = newCurrentLod;
    currentIteration = newCurrentLod;

    currentResolution->x = (Int)(pow(2.0,(Double)currentLod)) + 1;
    currentResolution->y = (Int)(pow(2.0,(Double)currentLod)) + 1;

    lastResolution->x = (currentResolution->x - 1) / 2;
    lastResolution->y = (currentResolution->y - 1) / 2;
}

- (void) setWidth:(Int32)newWidth
{
    size->x = newWidth;
}

- (void) setLength:(Int32)newLength
{
    size->y = newLength;
}

- (void) setMinimumHeight:(Float)newMinimumHeight
{
    minimumHeight = newMinimumHeight;
}

- (void) setMaximumHeight:(Float)newMaximumHeight
{
    maximumHeight = newMaximumHeight;
}

- (void) setRngOneUsingName:(NSString *)newRngOneName
{
    [ gaussianRng setFirstGenerator:[rngs objectForKey:newRngOneName]];
}

- (void) setRngTwoUsingName:(NSString *)newRngTwoName
{
    [ gaussianRng setSecondGenerator:[rngs objectForKey:newRngTwoName]];
}

- (void) setRngOneSeed:(ULong)newSeed
{
    [[ gaussianRng firstGenerator ] reseed:newSeed ];
}

- (void) setRngTwoSeed:(ULong)newSeed
{
    [[ gaussianRng secondGenerator ] reseed:newSeed ];
}

- (void) setH:(Float)newH
{
    H = newH;
}

- (void) setSigma:(Float)newSigma
{
    sigma = newSigma;
    variance = sigma * sigma;
}

- (void) setIterationsToDo:(Int32)newIterationsToDo
{
    iterationsToDo = newIterationsToDo;
}

- (void) setupGaussianKernelForAO
{
    [ self setupGaussianKernelForAOWithSigma:gaussKernelSigma ];
}

- (void) setupGaussianKernelForAOWithSigma:(Float)kernelSigma
{
    SAFE_FREE(gaussKernel);

    Double gaussianDieOff = 0.0001f;
	Double sigmaSquare = kernelSigma * kernelSigma;
	Int width = 1;

	for ( Int i = 0; i < 32; i++ )
	{
		Double isquare = (Double)(i * i);
		Double tmp = exp(-(isquare) / (2.0 * sigmaSquare));

		if ( tmp > gaussianDieOff )
		{
			width = i;
		}
	}

    gaussKernelWidth = 2 * width + 1;
    gaussKernel = ALLOC_ARRAY(Float, gaussKernelWidth * gaussKernelWidth);

	for ( Int i = 0; i < gaussKernelWidth; i++ )
	{
		for ( Int j = 0; j < gaussKernelWidth; j++ )
		{
			Double x = (Double)(j - width);
			Double y = (Double)(i - width);
			
			Int index = i * (2 * width + 1) + j;

			gaussKernel[index] = (Float)exp(-(x * x + y * y)/(2.0 * sigmaSquare))/(2.0 * MATH_PI * sigmaSquare);
		}
	}
}

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary
{
    // Base LOD, 2x2 vertices
    baseResolution->x = baseResolution->y = 2;
    baseIterations = 0;

    currentResolution->x = baseResolution->x;
    currentResolution->y = baseResolution->y;

    currentIteration = baseIterations;
    currentLod = currentIteration - baseIterations;

    NSArray * terrainSizeStrings = [ dictionary objectForKey:@"Size" ];
    size->x = [[ terrainSizeStrings objectAtIndex:0 ] intValue ];
    size->y = [[ terrainSizeStrings objectAtIndex:1 ] intValue ];

    minimumHeight = [[ dictionary objectForKey:@"MinimumHeight" ] floatValue ];
    maximumHeight = [[ dictionary objectForKey:@"MaximumHeight" ] floatValue ];
    iterationsToDo = [[ dictionary objectForKey:@"Iterations" ] intValue ];
    sigma = [[ dictionary objectForKey:@"Sigma" ] floatValue ];
    H = [[ dictionary objectForKey:@"H" ] floatValue ];

    [ self updateGeometry ];

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"terrain.cgfx" ];
    lightPositionParameter = [ effect parameterWithName:@"lightPosition" ];
    NSAssert(lightPositionParameter != NULL, @"Light position parameter not found");

    return YES;
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * sceneConfig = [ NSDictionary dictionaryWithContentsOfFile:path ];

    return [ self loadFromDictionary:sceneConfig ];
}

- (void) reset
{
}

// initialise base lod without heightmap
- (void) initialiseEmptyBaseLodPositions
{
    Int numberOfVertices = 4;
    Float * vertexPositions = ALLOC_ARRAY(Float, numberOfVertices * 3);

    Float deltaX = (Float)size->x / (Float)(baseResolution->x - 1);
    Float deltaY = (Float)size->y / (Float)(baseResolution->y - 1);

    for ( Int i = 0; i < baseResolution->y; i++ )
    {
        for ( Int j = 0; j < baseResolution->x; j++ )
        {
            Int index = (i * baseResolution->x + j) * 3;
            vertexPositions[index]   = (Float)(-size->x)/2.0f + (Float)j * deltaX;            
            vertexPositions[index+2] = (Float)(-size->y)/2.0f + (Float)i * deltaY;
            vertexPositions[index+1] = 0.0f;
        }
    }

    NPVertexBuffer * base = [ lods objectAtIndex:0 ];

    [ base setPositions:vertexPositions 
        elementsForPosition:3 
                 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT
                vertexCount:numberOfVertices ];
}

- (void) updateTextureCoordinates
{
    Int numberOfVertices = currentResolution->x * currentResolution->y;
    FTexCoord2 * texCoords = ALLOC_ARRAY(FTexCoord2, numberOfVertices);

    Float texDeltaX = 1.0f / (Float)(currentResolution->x - 1);
    Float texDeltaY = 1.0f / (Float)(currentResolution->y - 1);

    for ( Int i = 0; i < currentResolution->y; i++ )
    {
        for ( Int j = 0; j < currentResolution->x; j++ )
        {
            Int index = i * currentResolution->x + j;
            texCoords[index].u = 0.0f + (Float)j * texDeltaX;
            texCoords[index].v = 0.0f + (Float)i * texDeltaY;
        }
    }

    [[ lods objectAtIndex:currentLod ] setTextureCoordinates:(Float *)texCoords 
                             elementsForTextureCoordinates:2
                                                dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                    forSet:0 ];
}

- (void) updateNormals
{
    FVector3 * vertexPositions = (FVector3 *)[[ lods objectAtIndex:currentLod ] positions ];

    Int numberOfVertices = currentResolution->x * currentResolution->y;
    FNormal * normals = ALLOC_ARRAY(FNormal, numberOfVertices);

    FNormal cornerNormal = {0.0f, 1.0f, 0.0f};

    for ( Int i = 0; i < numberOfVertices; i++ )
    {
        normals[i] = cornerNormal;
    }

    // inner faces
    for ( Int i = 1; i < currentResolution->y - 1; i++ )
    {
        for ( Int j = 1; j < currentResolution->x - 1; j++ )
        {
            FVector3 north, south, west, east;
            Int index = i * currentResolution->x + j;
            Int indexNorth = (i - 1) * currentResolution->x + j;
            Int indexSouth = (i + 1) * currentResolution->x + j;
            Int indexWest  = i * currentResolution->x + j - 1;
            Int indexEast  = i * currentResolution->x + j + 1;

            fv3_vv_sub_v(&(vertexPositions[indexNorth]), &(vertexPositions[index]), &north);
            fv3_vv_sub_v(&(vertexPositions[indexSouth]), &(vertexPositions[index]), &south);
            fv3_vv_sub_v(&(vertexPositions[indexWest ]), &(vertexPositions[index]), &west);
            fv3_vv_sub_v(&(vertexPositions[indexEast ]), &(vertexPositions[index]), &east);

            FVector3 northWestNormal, northEastNormal, southWestNormal, southEastNormal;
            fv3_vv_cross_product_v(&north, &west,  &northWestNormal);
            fv3_vv_cross_product_v(&east,  &north, &northEastNormal);
            fv3_vv_cross_product_v(&west,  &south, &southWestNormal);
            fv3_vv_cross_product_v(&south, &east,  &southEastNormal);

            FVector3 tmp, sum;
            fv3_vv_add_v(&northWestNormal, &northEastNormal, &sum);
            fv3_vv_add_v(&sum, &southWestNormal, &tmp);
            fv3_vv_add_v(&tmp, &southEastNormal, &sum);

            fv3_v_normalise(&sum);

            normals[index] = sum;
        }
    }

    [[ lods objectAtIndex:currentLod ] setNormals:(Float *)normals 
                                elementsForNormal:3
                                       dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT ];
}

- (void) updateAO
{
    Int numberOfVertices = currentResolution->x * currentResolution->y;
    Float * colors = ALLOC_ARRAY(Float, numberOfVertices*3);
    Float * vertexPositions = [[ lods objectAtIndex:currentLod ] positions ];

    for ( Int i = 0; i < numberOfVertices * 3; i++ )
    {
        colors[i] = 0.1f;
    }

    div_t d = div(gaussKernelWidth, 2);

    if ( currentResolution->y - d.quot > d.quot )
    {
        for ( Int i = d.quot; i < currentResolution->y - d.quot; i++ )
        {
            for ( Int j = d.quot; j < currentResolution->x - d.quot; j++ )
            {
                Int vertexOfInterestIndex = (i * currentResolution->x + j) * 3;
                Float average = 0.0f;

                for ( Int k = 0; k < gaussKernelWidth; k++ )
                {
                    for ( Int l = 0; l < gaussKernelWidth; l++ )
                    {
                        Int kernelElementIndex = k * gaussKernelWidth + l;
                        Int offsetK = k - d.quot;
                        Int offsetL = l - d.quot;
                        Int vertexIndexOffset = (offsetK * currentResolution->x + offsetL) * 3;
                        Int vertexIndexForKernelElement = vertexOfInterestIndex + vertexIndexOffset;

                        average = average + (vertexPositions[vertexIndexForKernelElement + 1] * gaussKernel[kernelElementIndex]); 
                    }
                }

                colors[vertexOfInterestIndex] = MAX(0.1f, average);
            }
        }

        for ( Int i = 0; i < d.quot; i ++ )
        {
            for ( Int j = 0; j < currentResolution->x; j++ )
            {
                colors[(i * currentResolution->x + j) * 3] = 1.0f;
                colors[((currentResolution->y - 1 - i) * (currentResolution->x) + j) * 3] = 1.0f;
            }
        }

        for ( Int i = 0; i < d.quot; i ++ )
        {
            for ( Int j = 0; j < currentResolution->y; j++ )
            {
                colors[(j * currentResolution->x + i) * 3] = 1.0f;
                colors[(j * currentResolution->x + currentResolution->x - 1 - i) * 3] = 1.0f;
            }
        }
    }

    [[ lods objectAtIndex:currentLod ] setColors:colors elementsForColor:3 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT ];
}

- (void) updateIndices
{
    Int numberOfIndices = ( currentResolution->x -1 ) * ( currentResolution->y - 1 ) * 6;
    Int32 * indices = ALLOC_ARRAY(Int, numberOfIndices);

    for ( Int i = 0; i < currentResolution->y - 1; i++ )
    {
        for ( Int j = 0; j < currentResolution->x - 1; j++ )
        {
            Int index = (i * ( currentResolution->x - 1) + j) * 6;

            indices[index] = i * currentResolution->x + j;
            indices[index+1] = (i + 1) * currentResolution->x + j;
            indices[index+2] = i * currentResolution->x + j + 1;

            indices[index+3] = (i + 1) * currentResolution->x + j;
            indices[index+4] = (i + 1) * currentResolution->x + j + 1;
            indices[index+5] = i * currentResolution->x + j + 1;
        }
    }

    [[ lods objectAtIndex:currentLod ] setIndices:indices indexCount:numberOfIndices ];
}

- (void) subdivide
{
    currentIteration = currentIteration + 1;
    currentLod = currentIteration - baseIterations;

    lastResolution->x = currentResolution->x;
    lastResolution->y = currentResolution->y;

    currentResolution->x = (lastResolution->x - 1) * 2 + 1;
    currentResolution->y = (lastResolution->y - 1) * 2 + 1;

    Int numberOfVertices = currentResolution->x * currentResolution->y;
    Float * positions = ALLOC_ARRAY(Float, numberOfVertices * 3);

    Float * currentPositions = [[ lods objectAtIndex:currentLod-1 ] positions ];

    Float rngVariance = variance / (Float)pow(2.0, (Double)(currentIteration - 1) * (Double)H);

    // diamond step

    Int numberOfDiamondPositions = (lastResolution->x - 1) * (lastResolution->y - 1);
    Float * diamondPositions = ALLOC_ARRAY(Float, numberOfDiamondPositions);

    for ( Int i = 0; i < lastResolution->y - 1; i++ )
    {
        for ( Int j = 0; j < lastResolution->x - 1; j++ )
        {
            Int index0 = (i * lastResolution->x + j) * 3 + 1;
            Int index3 = (i * lastResolution->x + j + 1) * 3 + 1;
            Int index1 = ((i + 1) * lastResolution->x + j) * 3 + 1;
            Int index2 = ((i + 1) * lastResolution->x + j + 1) * 3 + 1;

            Int index = i * (lastResolution->x -1) + j;

            diamondPositions[index] = (currentPositions[index0] + currentPositions[index1] +
                                      currentPositions[index2] + currentPositions[index3]) / 4.0f +
                                      [ gaussianRng nextGaussianFPRandomNumberWithMean:0.0f andVariance:rngVariance ];
                                      
        }
    }

    // square step

    Float deltaX = (Float)size->x / (Float)(currentResolution->x - 1);
    Float deltaY = (Float)size->y / (Float)(currentResolution->y - 1);

    for ( Int i = 0; i < currentResolution->y; i++ )
    {
        for ( Int j = 0; j < currentResolution->x; j++ )
        {
            Int index = (i * currentResolution->x + j) * 3;
            positions[index]   = (Float)(-size->x)/2.0f + (Float)j * deltaX;            
            positions[index+2] = (Float)(-size->y)/2.0f + (Float)i * deltaY;

            if ( (j % 2 == 0) && (i % 2 == 0) )
            {
                Float tmp = currentPositions[((i/2)*lastResolution->x+(j/2))*3+1];
                positions[index+1] = tmp;
            }
            else if ( (j % 2 == 1) && (i % 2 == 1) )
            {
                Float tmp = diamondPositions[(i/2)*(lastResolution->x-1)+(j/2)];
                positions[index+1] = tmp;
            }
            else
            {
                if ( (i % 2 == 0) && (j % 2 == 1) )
                {
                    Float west = currentPositions[((i/2)*lastResolution->x+(j/2)  )*3+1];
                    Float east = currentPositions[((i/2)*lastResolution->x+(j/2)+1)*3+1];

                    Float north, south;
                    if ( i == 0 )
                    {
                        north = diamondPositions[(lastResolution->y-2)*(lastResolution->x-1)+(j/2)];
                        south = diamondPositions[(j/2)];
                    }
                    else if ( i == currentResolution->y - 1)
                    {
                        north = diamondPositions[(lastResolution->y-2)*(lastResolution->x-1)+(j/2)];
                        south = diamondPositions[(j/2)];
                    }
                    else
                    {
                        north = diamondPositions[(i/2 -1)*(lastResolution->x-1)+(j/2)];
                        south = diamondPositions[(i/2   )*(lastResolution->x-1)+(j/2)];
                    }

                    positions[index+1] = ( west + east + north + south ) / 4.0f +
                                         [ gaussianRng nextGaussianFPRandomNumberWithMean:0.0f andVariance:rngVariance ];
                }
                else if ( (j % 2 == 0) && (i % 2 == 1) )
                {
                    Float north = currentPositions[((i/2  )*lastResolution->x+(j/2))*3+1];
                    Float south = currentPositions[((i/2+1)*lastResolution->x+(j/2))*3+1];

                    Float west, east;
                    if ( j == 0 )
                    {
                        west = diamondPositions[(i/2)*(lastResolution->x-1)+(lastResolution->x-2)];
                        east = diamondPositions[(i/2)*(lastResolution->x-1)+(j/2  )];
                    }
                    else if ( j == currentResolution->x - 1 )
                    {
                        west = diamondPositions[(i/2)*(lastResolution->x-1)+(j/2-1)];
                        east = diamondPositions[(i/2)*(lastResolution->x-1)];
                    }
                    else
                    {
                        west = diamondPositions[(i/2)*(lastResolution->x-1)+(j/2-1)];
                        east = diamondPositions[(i/2)*(lastResolution->x-1)+(j/2  )];
                    }

                    positions[index+1] = ( west + east + north + south ) / 4.0f +
                                         [ gaussianRng nextGaussianFPRandomNumberWithMean:0.0f andVariance:rngVariance ];

                }
                else
                {
                    NSLog(@"KABUMM");
                }
            }
        }
    }

    FREE(diamondPositions);

    NPVertexBuffer * buffer = [[ NPVertexBuffer alloc ] initWithName:[ NSString stringWithFormat:@"Iteration%d",currentIteration ] parent:self ];
    [ buffer setPositions:positions 
      elementsForPosition:3 
               dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT
              vertexCount:numberOfVertices ];

    [ lods addObject:buffer ];
    [ buffer release ];

    //iterationsDone = iterationsDone + 1;
}

- (void) updateGeometryUsingSize:(IVector2)size
                     heightRange:(FVector2)heightRange
              numberOfIterations:(UInt32)numberOfIterations
                           sigma:(Float)sigma
                               H:(Float)H
{
}

- (void) updateGeometry
{
    if ( [ lods count ] == 0 )
    {
        NPVertexBuffer * base = [[ NPVertexBuffer alloc ] initWithName:@"Base" parent:self ];
        [ lods addObject:base ];
        [ base release ];

        [ self initialiseEmptyBaseLodPositions ];
        [ self updateTextureCoordinates ];
        [ self updateNormals ];
        [ self updateAO ];
        [ self updateIndices ];

        [[ NP attributesWindowController ] addLodPopUpItemWithNumber:0 ];
    }

    for ( Int i = currentLod + 1; i < (Int)[ lods count ]; i++ )
    {
        [ lods removeObjectAtIndex:i ];
        [[ NP attributesWindowController ] removeLodPopUpItemWithNumber:i ];
    }

    Int iterationsDone = 0;
    while ( iterationsToDo > iterationsDone )
    {
        [ self subdivide ];
        [ self updateTextureCoordinates ];
        [ self updateNormals ];
        [ self updateAO ];
        [ self updateIndices ];

        [[ NP attributesWindowController ] addLodPopUpItemWithNumber  :currentLod ];
        [[ NP attributesWindowController ] selectLodPopUpItemWithIndex:currentLod ];

        iterationsDone = iterationsDone + 1;
    }
}

- (void) update:(Float)frameTime
{

}

- (void) render
{
    [ texture activateAtColorMapIndex:0 ];
    [ effect uploadFVector3Parameter:lightPositionParameter andValue:lightPosition ];
    [ effect activate ];
    [[ lods objectAtIndex:currentLod ] renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];
    [ effect deactivate ];
}

@end
