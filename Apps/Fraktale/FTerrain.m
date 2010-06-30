#include <float.h>
#import "NP.h"
#import "FCore.h"
#import "FTerrain.h"
#import "FPGMImage.h"
#import "FScene.h"
#import "FPreethamSkylight.h"
#import "FCamera.h"

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

    lods = [[ NSMutableArray alloc ] init ];
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

    gaussianRng = [[[ NP Core ] randomNumberGeneratorManager ] gaussianGeneratorWithName:@"Gaussian"
                                                    firstFixedParameterGenerator:NP_RNG_TT800
                                                   secondFixedParameterGenerator:NP_RNG_TT800 ];

    baseResolution = iv2_alloc_init_with_components(2, 2);
    size = iv2_alloc_init_with_components(10, 10);
    heightRange = fv2_alloc_init();
    lightDirection = fv3_alloc_init();
    texCoordTiling = fv2_alloc_init();

    H = 0.5f;
    sigma = 1.0f;
    variance = 1.0f;

    gaussKernelSigma = 0.75f;
    gaussKernel = NULL;

    [ self setupGaussianKernelForAOWithSigma:gaussKernelSigma ];

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"terrain.cgfx" ];
    lightDirectionParameter = [ effect parameterWithName:@"lightDirection" ];
    cameraPositionParameter = [ effect parameterWithName:@"cameraPosition" ];
    texCoordTilingParameter = [ effect parameterWithName:@"texCoordTiling" ];
    heightRangeParameter = [ effect parameterWithName:@"heightRange" ];
    NSAssert(lightDirectionParameter != NULL, @"\"lightDirection\" parameter not found");
    NSAssert(cameraPositionParameter != NULL, @"\"cameraPosition\" parameter not found");
    NSAssert(texCoordTilingParameter != NULL, @"\"texCoordTiling\" parameter not found");
    NSAssert(heightRangeParameter != NULL, @"\"heightRange\" parameter not found");

    sandDiffuseTexture  = [[[ NP Graphics ] textureManager ] loadTextureFromPath:@"ground17.jpg" sRGB:YES ];
    sandSpecularTexture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:@"ground17s.jpg" ];
    grassDiffuseTexture  = [[[ NP Graphics ] textureManager ] loadTextureFromPath:@"ground14.jpg" sRGB:YES ];
    grassSpecularTexture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:@"ground14s.jpg" ];
    stoneDiffuseTexture  = [[[ NP Graphics ] textureManager ] loadTextureFromPath:@"stone17.jpg" sRGB:YES ];
    stoneSpecularTexture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:@"stone17s.jpg" ];

    [ grassDiffuseTexture  setTextureAnisotropyFilter:NP_GRAPHICS_TEXTURE_FILTER_ANISOTROPY_8X ];
    [ grassSpecularTexture setTextureAnisotropyFilter:NP_GRAPHICS_TEXTURE_FILTER_ANISOTROPY_8X ];
    [ stoneDiffuseTexture  setTextureAnisotropyFilter:NP_GRAPHICS_TEXTURE_FILTER_ANISOTROPY_8X ];
    [ stoneSpecularTexture setTextureAnisotropyFilter:NP_GRAPHICS_TEXTURE_FILTER_ANISOTROPY_8X ];
    [ sandDiffuseTexture  setTextureAnisotropyFilter:NP_GRAPHICS_TEXTURE_FILTER_ANISOTROPY_8X ];
    [ sandSpecularTexture setTextureAnisotropyFilter:NP_GRAPHICS_TEXTURE_FILTER_ANISOTROPY_8X ];

    useAO = YES;
    useSpecular = YES;
    lodToRender = 0;

    return self;
}

- (void) dealloc
{
    SAFE_FREE(gaussKernel);

    [ lods removeAllObjects ];
    [ rngs removeAllObjects ];
    [ lods release ];
    [ rngs release ];

    texCoordTiling = fv2_free(texCoordTiling);
    lightDirection = fv3_free(lightDirection);
    heightRange = fv2_free(heightRange);
    baseResolution = iv2_free(baseResolution);    
    size = iv2_free(baseResolution);

    [ super dealloc ];
}

- (Float) H
{
    return H;
}

- (Float) sigma
{
    return sigma;
}

- (void) setLODToRender:(UInt32)newLODToRender
{
    lodToRender = newLODToRender;
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
    IVector2 newSize;
    FVector2 newHeightRange;
    Int numberOfIterations;
    Float newSigma;
    Float newH;

    NSArray * terrainSizeStrings = [ dictionary objectForKey:@"Size" ];
    newSize.x = [[ terrainSizeStrings objectAtIndex:0 ] intValue ];
    newSize.y = [[ terrainSizeStrings objectAtIndex:1 ] intValue ];
    newHeightRange.x = [[ dictionary objectForKey:@"MinimumHeight" ] floatValue ];
    newHeightRange.y = [[ dictionary objectForKey:@"MaximumHeight" ] floatValue ];
    numberOfIterations = [[ dictionary objectForKey:@"Iterations" ] intValue ];
    newSigma = [[ dictionary objectForKey:@"Sigma" ] floatValue ];
    newH = [[ dictionary objectForKey:@"H" ] floatValue ];

    [ self updateGeometryUsingSize:newSize
                       heightRange:newHeightRange
                             sigma:newSigma
                                 H:newH
                numberOfIterations:(UInt32)numberOfIterations
                        rngOneName:NP_RNG_TT800
                        rngOneSeed:0
                        rngTwoName:NP_RNG_TT800
                        rngTwoSeed:0 ];

    return YES;
}

- (void) reset
{
}

// initialise base lod without heightmap
- (void) initialiseEmptyBaseLodPositions
{
    Int numberOfVertices = 4;
    FVertex3 * vertices = ALLOC_ARRAY(FVertex3, numberOfVertices);

    Float deltaX = (Float)size->x;
    Float deltaY = (Float)size->y;

    for ( Int i = 0; i < 2; i++ )
    {
        for ( Int j = 0; j < 2; j++ )
        {
            Int index = i * 2 + j;
            vertices[index].x = (Float)(-size->x)/2.0f + (Float)j * deltaX;
            vertices[index].y = 0.0f;
            vertices[index].z = (Float)(-size->y)/2.0f + (Float)i * deltaY;
        }
    }

    NPVertexBuffer * base = [ lods objectAtIndex:0 ];

    [ base setPositions:(Float*)vertices
        elementsForPosition:3 
                 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT
                vertexCount:numberOfVertices ];
}

- (void) updateTextureCoordinatesForLOD:(UInt32)lodIndex
                           atResolution:(IVector2)lodResolution
{
    Int numberOfVertices = lodResolution.x * lodResolution.y;
    FTexCoord2 * texCoords = ALLOC_ARRAY(FTexCoord2, numberOfVertices);

    Float texDeltaX = 1.0f / (Float)(lodResolution.x - 1);
    Float texDeltaY = 1.0f / (Float)(lodResolution.y - 1);

    for ( Int i = 0; i < lodResolution.y; i++ )
    {
        for ( Int j = 0; j < lodResolution.x; j++ )
        {
            Int index = i * lodResolution.x + j;
            texCoords[index].u = 0.0f + (Float)j * texDeltaX;
            texCoords[index].v = 0.0f + (Float)i * texDeltaY;
        }
    }

    [[ lods objectAtIndex:lodIndex ] setTextureCoordinates:(Float *)texCoords 
                             elementsForTextureCoordinates:2
                                                dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                    forSet:0 ];
}

- (void) updateNormalsForLOD:(UInt32)lodIndex
                atResolution:(IVector2)lodResolution
{
    FVector3 * vertexPositions = (FVector3 *)[[ lods objectAtIndex:lodIndex ] positions ];

    Int numberOfVertices = lodResolution.x * lodResolution.y;
    FNormal * normals = ALLOC_ARRAY(FNormal, numberOfVertices);

    FNormal cornerNormal = {0.0f, 1.0f, 0.0f};
    for ( Int i = 0; i < numberOfVertices; i++ )
    {
        normals[i] = cornerNormal;
    }

    // inner faces
    FVector3 north, south, west, east;
    FVector3 northWestNormal, northEastNormal, southWestNormal, southEastNormal;

    for ( Int i = 1; i < lodResolution.y - 1; i++ )
    {
        for ( Int j = 1; j < lodResolution.x - 1; j++ )
        {
            Int index = i * lodResolution.x + j;
            Int indexNorth = (i - 1) * lodResolution.x + j;
            Int indexSouth = (i + 1) * lodResolution.x + j;
            Int indexWest  = i * lodResolution.x + j - 1;
            Int indexEast  = i * lodResolution.x + j + 1;

            north = fv3_vv_sub(&(vertexPositions[indexNorth]), &(vertexPositions[index]));
            south = fv3_vv_sub(&(vertexPositions[indexSouth]), &(vertexPositions[index]));
            west = fv3_vv_sub(&(vertexPositions[indexWest ]), &(vertexPositions[index]));
            east = fv3_vv_sub(&(vertexPositions[indexEast ]), &(vertexPositions[index]));

            northWestNormal = fv3_vv_cross_product(&north, &west);
            northEastNormal = fv3_vv_cross_product(&east,  &north);
            southWestNormal = fv3_vv_cross_product(&west,  &south);
            southEastNormal = fv3_vv_cross_product(&south, &east);

            FVector3 sum = fv3_vv_add(&northWestNormal, &northEastNormal);
            sum = fv3_vv_add(&sum, &southWestNormal);
            sum = fv3_vv_add(&sum, &southEastNormal);
            fv3_v_normalise(&sum);

            normals[index] = sum;
        }
    }

    [[ lods objectAtIndex:lodIndex ] setNormals:(Float *)normals 
                              elementsForNormal:3
                                     dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT ];
}

- (void) updateAOForLOD:(UInt32)lodIndex
           atResolution:(IVector2)lodResolution
{
    Int numberOfVertices = lodResolution.x * lodResolution.y;
    Float * colors = ALLOC_ARRAY(Float, numberOfVertices*3);
    Float * vertexPositions = [[ lods objectAtIndex:lodIndex ] positions ];

    for ( Int i = 0; i < numberOfVertices * 3; i++ )
    {
        colors[i] = 0.1f;
    }

    float heightRangeInterval = fabs(heightRange->y - heightRange->x);
    div_t d = div(gaussKernelWidth, 2);

    if ( lodResolution.y - d.quot > d.quot )
    {
        for ( Int i = d.quot; i < lodResolution.y - d.quot; i++ )
        {
            for ( Int j = d.quot; j < lodResolution.x - d.quot; j++ )
            {
                Int vertexOfInterestIndex = (i * lodResolution.x + j) * 3;
                Float average = 0.0f;

                for ( Int k = 0; k < gaussKernelWidth; k++ )
                {
                    for ( Int l = 0; l < gaussKernelWidth; l++ )
                    {
                        Int kernelElementIndex = k * gaussKernelWidth + l;
                        Int offsetK = k - d.quot;
                        Int offsetL = l - d.quot;
                        Int vertexIndexOffset = (offsetK * lodResolution.x + offsetL) * 3;
                        Int vertexIndexForKernelElement = vertexOfInterestIndex + vertexIndexOffset;

                        average = average + ((vertexPositions[vertexIndexForKernelElement + 1] * gaussKernel[kernelElementIndex]) / heightRangeInterval); 
                    }
                }

                colors[vertexOfInterestIndex] = MAX(0.1f, average);
                //NSLog(@"%f", average);
            }
        }

        for ( Int i = 0; i < d.quot; i ++ )
        {
            for ( Int j = 0; j < lodResolution.x; j++ )
            {
                colors[(i * lodResolution.x + j) * 3] = 1.0f;
                colors[((lodResolution.y - 1 - i) * (lodResolution.x) + j) * 3] = 1.0f;
            }
        }

        for ( Int i = 0; i < d.quot; i ++ )
        {
            for ( Int j = 0; j < lodResolution.y; j++ )
            {
                colors[(j * lodResolution.x + i) * 3] = 1.0f;
                colors[(j * lodResolution.x + lodResolution.x - 1 - i) * 3] = 1.0f;
            }
        }
    }

    [[ lods objectAtIndex:lodIndex ] setColors:colors
                              elementsForColor:3
                                    dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT ];
}

- (void) updateIndicesForLOD:(UInt32)lodIndex
                atResolution:(IVector2)lodResolution
{
    Int numberOfIndices = ( lodResolution.x -1 ) * ( lodResolution.y - 1 ) * 6;
    Int32 * indices = ALLOC_ARRAY(Int, numberOfIndices);

    for ( Int i = 0; i < lodResolution.y - 1; i++ )
    {
        for ( Int j = 0; j < lodResolution.x - 1; j++ )
        {
            Int index = (i * ( lodResolution.x - 1) + j) * 6;

            indices[index] = i * lodResolution.x + j;
            indices[index+1] = (i + 1) * lodResolution.x + j;
            indices[index+2] = i * lodResolution.x + j + 1;

            indices[index+3] = (i + 1) * lodResolution.x + j;
            indices[index+4] = (i + 1) * lodResolution.x + j + 1;
            indices[index+5] = i * lodResolution.x + j + 1;
        }
    }

    [[ lods objectAtIndex:lodIndex ] setIndices:indices 
                                     indexCount:numberOfIndices ];
}

- (IVector2) subdivideLOD:(UInt32)lodIndex
             atResolution:(IVector2)lodResolution
          withHeightRange:(FVector2)lodHeightRange
{
    IVector2 newLODResolution;
    newLODResolution.x = (lodResolution.x - 1) * 2 + 1;
    newLODResolution.y = (lodResolution.y - 1) * 2 + 1;

    Float rngVariance = variance / (Float)pow(2.0, (Double)(lodIndex) * (Double)H);
    FVertex3 * LODPositions = (FVertex3 *)[[ lods objectAtIndex:lodIndex ] positions ];

    Int newLODNumberOfVertices = newLODResolution.x * newLODResolution.y;
    FVertex3 * newLODPositions = ALLOC_ARRAY(FVertex3, newLODNumberOfVertices);

    // diamond step

    Int newLODNumberOfDiamondPositions = (lodResolution.x - 1) * (lodResolution.y - 1);
    Float * newLODDiamondPositions = ALLOC_ARRAY(Float, newLODNumberOfDiamondPositions);

    for ( Int i = 0; i < lodResolution.y - 1; i++ )
    {
        for ( Int j = 0; j < lodResolution.x - 1; j++ )
        {
            Int index0 = (i * lodResolution.x + j);
            Int index3 = (i * lodResolution.x + j + 1);
            Int index1 = ((i + 1) * lodResolution.x + j);
            Int index2 = ((i + 1) * lodResolution.x + j + 1);

            Int index = i * (lodResolution.x -1) + j;

            newLODDiamondPositions[index] = (LODPositions[index0].y + LODPositions[index1].y +
                                             LODPositions[index2].y + LODPositions[index3].y) / 4.0f +
                                            [ gaussianRng nextGaussianFPRandomNumberWithMean:0.0f andVariance:rngVariance ];
                                      
        }
    }

    // square step

    Float deltaX = (Float)size->x / (Float)(newLODResolution.x - 1);
    Float deltaY = (Float)size->y / (Float)(newLODResolution.y - 1);

    for ( Int i = 0; i < newLODResolution.y; i++ )
    {
        for ( Int j = 0; j < newLODResolution.x; j++ )
        {
            Int index = i * newLODResolution.x + j;
            newLODPositions[index].x = (Float)(-size->x)/2.0f + (Float)j * deltaX;
            newLODPositions[index].y = 0.0f;
            newLODPositions[index].z = (Float)(-size->y)/2.0f + (Float)i * deltaY;

            if ( (j % 2 == 0) && (i % 2 == 0) )
            {
                Float tmp = LODPositions[((i/2)*lodResolution.x+(j/2))].y;
                newLODPositions[index].y = tmp;
            }
            else if ( (j % 2 == 1) && (i % 2 == 1) )
            {
                Float tmp = newLODDiamondPositions[(i/2)*(lodResolution.x-1)+(j/2)];
                newLODPositions[index].y = tmp;
            }
            else
            {
                if ( (i % 2 == 0) && (j % 2 == 1) )
                {
                    Float west = LODPositions[((i/2)*lodResolution.x+(j/2)  )].y;
                    Float east = LODPositions[((i/2)*lodResolution.x+(j/2)+1)].y;

                    Float north, south;
                    if ( i == 0 )
                    {
                        north = newLODDiamondPositions[(lodResolution.y-2)*(lodResolution.x-1)+(j/2)];
                        south = newLODDiamondPositions[(j/2)];
                    }
                    else if ( i == newLODResolution.y - 1)
                    {
                        north = newLODDiamondPositions[(lodResolution.y-2)*(lodResolution.x-1)+(j/2)];
                        south = newLODDiamondPositions[(j/2)];
                    }
                    else
                    {
                        north = newLODDiamondPositions[(i/2 -1)*(lodResolution.x-1)+(j/2)];
                        south = newLODDiamondPositions[(i/2   )*(lodResolution.x-1)+(j/2)];
                    }

                    newLODPositions[index].y = ( west + east + north + south ) / 4.0f +
                                         [ gaussianRng nextGaussianFPRandomNumberWithMean:0.0f andVariance:rngVariance ];
                }
                else if ( (j % 2 == 0) && (i % 2 == 1) )
                {
                    Float north = LODPositions[((i/2  )*lodResolution.x+(j/2))].y;
                    Float south = LODPositions[((i/2+1)*lodResolution.x+(j/2))].y;

                    Float west, east;
                    if ( j == 0 )
                    {
                        west = newLODDiamondPositions[(i/2)*(lodResolution.x-1)+(lodResolution.x-2)];
                        east = newLODDiamondPositions[(i/2)*(lodResolution.x-1)+(j/2  )];
                    }
                    else if ( j == newLODResolution.x - 1 )
                    {
                        west = newLODDiamondPositions[(i/2)*(lodResolution.x-1)+(j/2-1)];
                        east = newLODDiamondPositions[(i/2)*(lodResolution.x-1)];
                    }
                    else
                    {
                        west = newLODDiamondPositions[(i/2)*(lodResolution.x-1)+(j/2-1)];
                        east = newLODDiamondPositions[(i/2)*(lodResolution.x-1)+(j/2  )];
                    }

                    newLODPositions[index].y = ( west + east + north + south ) / 4.0f +
                                         [ gaussianRng nextGaussianFPRandomNumberWithMean:0.0f andVariance:rngVariance ];

                }
                else
                {
                    NSLog(@"KABUMM");
                }
            }
        }
    }

    FREE(newLODDiamondPositions);

    float min = FLT_MAX;
    float max = FLT_MIN;

    for (Int32 i = 0; i < newLODNumberOfVertices; i++)
    {
        if (newLODPositions[i].y < min)
        {
            min = newLODPositions[i].y;
        }

        if (newLODPositions[i].y > max)
        {
            max = newLODPositions[i].y;
        }
    }

    Float currentRangeLength = fabs(max - min);
    Float desiredRangeLength = fabs(lodHeightRange.y - lodHeightRange.x);
    Float rangeScalingFactor = desiredRangeLength / currentRangeLength;
    Float rangeShiftFactor = -(min * rangeScalingFactor) + lodHeightRange.x;

    if ( currentRangeLength <= desiredRangeLength )
    {
        rangeScalingFactor = 1.0f;

        if ( min != lodHeightRange.x )
        {
            rangeShiftFactor = -min;
        }
    }

    for (Int32 i = 0; i < newLODNumberOfVertices; i++)
    {
        newLODPositions[i].y = newLODPositions[i].y * rangeScalingFactor + rangeShiftFactor;
    }

    heightRange->x = min * rangeScalingFactor + rangeShiftFactor;
    heightRange->y = max * rangeScalingFactor + rangeShiftFactor;

    NSString * vertexBufferName = [ NSString stringWithFormat:@"Iteration%d", lodIndex + 1 ];
    NPVertexBuffer * buffer = [[ NPVertexBuffer alloc ] initWithName:vertexBufferName
                                                              parent:self ];

    [ buffer setPositions:(Float *)newLODPositions 
      elementsForPosition:3 
               dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT
              vertexCount:newLODNumberOfVertices ];

    [ lods addObject:buffer ];
    [ buffer release ];

    return newLODResolution;
}

- (void) updateGeometryUsingSize:(IVector2)newSize
                     heightRange:(FVector2)newHeightRange
                           sigma:(Float)newSigma
                               H:(Float)newH
              numberOfIterations:(UInt32)numberOfIterations
                      rngOneName:(NSString *)rngOneName
                      rngOneSeed:(Long)rngOneSeed
                      rngTwoName:(NSString *)rngTwoName
                      rngTwoSeed:(Long)rngTwoSeed
{
    size->x = newSize.x;
    size->y = newSize.y;
    H = newH;
    sigma = newSigma;
    variance = newSigma * newSigma;

    NPRandomNumberGenerator * generatorOne = [ rngs objectForKey:rngOneName ];
    NPRandomNumberGenerator * generatorTwo = [ rngs objectForKey:rngTwoName ];

    NSAssert(generatorOne != NULL && generatorTwo != NULL, @"RNG not found");

    [ generatorOne reseed:(ULong)rngOneSeed ];
    [ generatorTwo reseed:(ULong)rngTwoSeed ];

    [ gaussianRng setFirstGenerator :generatorOne ];
    [ gaussianRng setSecondGenerator:generatorTwo ];
    
    if ( [ lods count ] == 0 )
    {
        NPVertexBuffer * base = [[ NPVertexBuffer alloc ] initWithName:@"Base" parent:self ];
        [ lods addObject:base ];
        [ base release ];

        [ self initialiseEmptyBaseLodPositions ];
        [ self updateTextureCoordinatesForLOD:0 atResolution:*baseResolution ];
        [ self updateNormalsForLOD:0 atResolution:*baseResolution ];
        [ self updateAOForLOD:0 atResolution:*baseResolution ];
        [ self updateIndicesForLOD:0 atResolution:*baseResolution ];

        [[ NP attributesWindowController ] addLodPopUpItemWithNumber:0 ];
    }
    else
    {
        NSUInteger numberOfLods = [ lods count ];
        for (NSUInteger i = 1; i < numberOfLods; i++)
        {
            [[ NP attributesWindowController ] removeLodPopUpItemWithNumber:1 ];           
        }

        [ lods removeObjectsInRange:NSMakeRange(1, [lods count]) ];
    }

    IVector2 currentLODResolution = *baseResolution;

    UInt32 iterationsDone = 0;
    while ( numberOfIterations > iterationsDone )
    {
        currentLODResolution = [ self subdivideLOD:iterationsDone 
                                      atResolution:currentLODResolution
                                   withHeightRange:newHeightRange ];

        [ self updateTextureCoordinatesForLOD:iterationsDone + 1 atResolution:currentLODResolution ];
        [ self updateNormalsForLOD:iterationsDone + 1 atResolution:currentLODResolution ];
        [ self updateAOForLOD:iterationsDone + 1 atResolution:currentLODResolution ];
        [ self updateIndicesForLOD:iterationsDone + 1 atResolution:currentLODResolution ];

        [[ NP attributesWindowController ] addLodPopUpItemWithNumber  :iterationsDone + 1 ];
        [[ NP attributesWindowController ] selectLodPopUpItemWithIndex:iterationsDone + 1 ];

        iterationsDone = iterationsDone + 1;
        lodToRender = iterationsDone;
    }
}

- (void) update:(Float)frameTime
{
    FVector3 * skylightLightDirection = [[[[ NP applicationController ] scene ] skylight ] lightDirection ];
    fv3_vv_init_with_fv3(lightDirection, skylightLightDirection);

    texCoordTiling->x = ((Float)size->x / 2.0f);
    texCoordTiling->y = ((Float)size->y / 2.0f);
}

- (void) render
{
    [[[ NP Core ] transformationState ] resetModelMatrix ];
    [ grassDiffuseTexture  activateAtColorMapIndex:0 ];
    [ grassSpecularTexture activateAtColorMapIndex:1 ];
    [ stoneDiffuseTexture  activateAtColorMapIndex:2 ];
    [ stoneSpecularTexture activateAtColorMapIndex:3 ];
    [ sandDiffuseTexture  activateAtColorMapIndex:4 ];
    [ sandSpecularTexture activateAtColorMapIndex:5 ];

    [ effect uploadFVector3Parameter:lightDirectionParameter andValue:lightDirection ];
    [ effect uploadFVector3Parameter:cameraPositionParameter andValue:[[[[ NP applicationController ] scene ] camera ] position ]];
    [ effect uploadFVector2Parameter:texCoordTilingParameter andValue:texCoordTiling ];
    [ effect uploadFVector2Parameter:heightRangeParameter andValue:heightRange ];

    if ( useAO == YES && useSpecular == YES )
    {
        [ effect activateTechniqueWithName:@"terrain" ];
    }
    else if ( useSpecular == YES )
    {
        [ effect activateTechniqueWithName:@"terrain_diffuse_and_specular" ];
    }
    else
    {
        [ effect activateTechniqueWithName:@"terrain_diffuse_only" ];
    }

    [[ lods objectAtIndex:lodToRender ] renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];
    [ effect deactivate ];
}

@end
