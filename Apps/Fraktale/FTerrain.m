#import "FTerrain.h"
#import "FPGMImage.h"
#import "NP.h"

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

    size = iv2_alloc_init();
    size->x = size->y = -1;

    currentResolution = iv2_alloc_init();
    currentResolution->x = currentResolution->y = -1;
    lastResolution = iv2_alloc_init();
    lastResolution->x = lastResolution->y = -1;
    baseResolution = iv2_alloc_init();
    baseResolution->x = baseResolution->y = -1;

    H = 0.5f;
    variance = 1.0f;
    iterations = 0;
    baseIterations = 0;
    currentIteration = 0;
    iterationsDone = 0;
    lightPosition = fv3_alloc_init();

    lods = [[ NSMutableArray alloc ] init ];

    rng = [[[ NP Core ] randomNumberGeneratorManager ] gaussianGeneratorWithName:@"Gaussian"
                                                    firstFixedParameterGenerator:NP_RNG_TT800
                                                   secondFixedParameterGenerator:NP_RNG_CTG ];

    subdivideAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"Subdivide" primaryInputAction:NP_INPUT_KEYBOARD_PLUS ];

    return self;
}

- (void) dealloc
{
    size = iv2_free(size);
    baseResolution = iv2_free(baseResolution);
    currentResolution = iv2_free(currentResolution);
    lastResolution = iv2_free(lastResolution);
    lightPosition = fv3_free(lightPosition);

    TEST_RELEASE(image);

    [ lods removeAllObjects ];
    [ lods release ];

    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * sceneConfig = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSString * sceneName = [ sceneConfig objectForKey:@"Name" ];
    if ( sceneName == nil )
    {
        NPLOG_ERROR(@"%@: Name missing", path);
        return NO;
    }

    [ self setName:sceneName ];

    NSString * imagePath = [ sceneConfig objectForKey:@"Image" ];
    if ( imagePath != nil )
    {
        NSString * imageAbsolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:imagePath ];
        if ( [ imageAbsolutePath isEqual:@"" ] == YES )
        {
            NPLOG_ERROR(@"Could not find image file %@", imagePath);
            return NO;
        }    

        image = [[ FPGMImage alloc ] init ];
        if ( [ image loadFromPath:imageAbsolutePath ] == NO )
        {
            NPLOG_ERROR(@"%@: failed to load", imageAbsolutePath);
            return NO;
        }

        div_t w = div([image width]  - 1, 2);
        div_t h = div([image height] - 1, 2);

        if ( w.rem != 0 || h.rem != 0 )
        {
            NPLOG_ERROR(@"Image needs dimensions in the form of 2^n + 1");
            return NO;
        }

        baseResolution->x = [ image width  ];
        baseResolution->y = [ image height ];

        Int tmp = 1;
        Int cTmp = 0;
        while ( tmp + 1 != [ image width ] )
        {
            tmp = tmp * 2;
            cTmp = cTmp + 1;
        }

        baseIterations = cTmp;

        NSLog(@"levels: %d",cTmp);
    }
    else
    {
        baseResolution->x = baseResolution->y = 2;
        baseIterations = 0;
    }

    currentResolution->x = baseResolution->x;
    currentResolution->y = baseResolution->y;

    iterationsDone = baseIterations;
    currentIteration = baseIterations;

    NSString * texturePath = [ sceneConfig objectForKey:@"Texture" ];
    if ( texturePath == nil )
    {
        NPLOG_ERROR(@"%@: Texture missing", path);
        return NO;
    }    

    texture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:texturePath ];
    if ( texture == nil )
    {
        NPLOG_ERROR(@"Failed to load texture");
        return NO;
    }

    NSArray * terrainSizeStrings = [ sceneConfig objectForKey:@"Size" ];
    if ( terrainSizeStrings == nil )
    {
        NPLOG_WARNING(@"%@: Size missing, using default", path);
        size->x = size->y = 10;
    }

    size->x = [[ terrainSizeStrings objectAtIndex:0 ] intValue ];
    size->y = [[ terrainSizeStrings objectAtIndex:1 ] intValue ];

    NSString * HString = [ sceneConfig objectForKey:@"H" ];
    if ( HString == nil )
    {
        NPLOG_WARNING(@"%@: H missing, using default", path);
    }
    else
    {
        H = [ HString floatValue ];
    }

    NSString * iterationsString = [ sceneConfig objectForKey:@"Iterations" ];
    if ( iterationsString == nil )
    {
        NPLOG_WARNING(@"%@: Iterations missing, using default", path);
    }
    else
    {
        iterations = [ iterationsString intValue ];
    }

    [ self updateGeometry ];

    lightPosition->x = 0.0f;
    lightPosition->z = 0.0f;
    lightPosition->y = 10.0f;

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"terrain.cgfx" ];
    lightPositionParameter = [ effect parameterWithName:@"lightPosition" ];
    if ( lightPositionParameter == NULL )
    {
        NPLOG_ERROR(@"Light position parameter not found");
        return NO;
    }

    return YES;
}

// creates base LOD which uses the heightmap as basis for its geometry
- (void) initialiseBaseLodPositions
{
    Int numberOfVertices = baseResolution->x * baseResolution->y;
    Float * vertexPositions = ALLOC_ARRAY(Float, numberOfVertices * 3);
    Byte * heights = [ image imageData ];

    Float deltaX = (Float)size->x / (Float)(baseResolution->x - 1);
    Float deltaY = (Float)size->y / (Float)(baseResolution->y - 1);

    for ( Int i = 0; i < baseResolution->y; i++ )
    {
        for ( Int j = 0; j < baseResolution->x; j++ )
        {
            Int index = (i * baseResolution->x + j) * 3;
            vertexPositions[index]   = (Float)(-size->x)/2.0f + (Float)j * deltaX;            
            vertexPositions[index+2] = (Float)( size->y)/2.0f - (Float)i * deltaY;
            vertexPositions[index+1] = (Float)heights[i * baseResolution->x + j]/255.0f;
        }
    }

    NPVertexBuffer * base = [ lods objectAtIndex:0 ];

    [ base setPositions:vertexPositions 
        elementsForPosition:3 
                 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT
                vertexCount:numberOfVertices ];
}

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
            vertexPositions[index+2] = (Float)( size->y)/2.0f - (Float)i * deltaY;
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
    Float * texCoords = ALLOC_ARRAY(Float, numberOfVertices * 2);

    Float texDeltaX = 1.0f / (Float)(currentResolution->x - 1);
    Float texDeltaY = 1.0f / (Float)(currentResolution->y - 1);

    for ( Int i = 0; i < currentResolution->y; i++ )
    {
        for ( Int j = 0; j < currentResolution->x; j++ )
        {
            Int index = (i * currentResolution->x + j) * 2;
            texCoords[index]   = 0.0f + (Float)j * texDeltaX;
            texCoords[index+1] = 0.0f + (Float)i * texDeltaY;
        }
    }

    Int lodIndex = currentIteration - baseIterations;
    [[ lods objectAtIndex:lodIndex ] setTextureCoordinates:texCoords 
                             elementsForTextureCoordinates:2
                                                dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                    forSet:0 ]; 
}

- (void) updateNormals
{
    Int numberOfVertices = currentResolution->x * currentResolution->y;
    Float * normals = ALLOC_ARRAY(Float, numberOfVertices * 3);

    Int lodIndex = currentIteration - baseIterations;
    Float * vertexPositions = [[ lods objectAtIndex:lodIndex ] positions ];

    //Corners
    normals[0] = normals[2] = 0.0f;
    normals[1] = 1.0f;

    normals[(currentResolution->x-1)*3] = normals[(currentResolution->x-1)*3+2] = 0.0f;
    normals[(currentResolution->x-1)*3+1] = 1.0f;

    normals[currentResolution->x*(currentResolution->y-1)*3] = 
    normals[currentResolution->x*(currentResolution->y-1)*3+2] = 0.0f;
    normals[currentResolution->x*(currentResolution->y-1)*3+1] = 1.0f;

    normals[(currentResolution->x*(currentResolution->y-1)+currentResolution->x-1)*3] = 
    normals[(currentResolution->x*(currentResolution->y-1)+currentResolution->x-1)*3+2] = 0.0f;
    normals[(currentResolution->x*(currentResolution->y-1)+currentResolution->x-1)*3+1] = 1.0f;

    // Upper Border
    for ( Int j = 1; j < currentResolution->x - 1; j++ )
    {
        FVector3 south, west, east;
        Int index = j * 3;
        Int indexSouth = (currentResolution->x + j) * 3;
        Int indexWest  = (j - 1) * 3;
        Int indexEast  = (j + 1) * 3;

        south.x = vertexPositions[indexSouth]   - vertexPositions[index];
        south.y = vertexPositions[indexSouth+1] - vertexPositions[index+1];
        south.z = vertexPositions[indexSouth+2] - vertexPositions[index+2];

        west.x = vertexPositions[indexWest]   - vertexPositions[index];
        west.y = vertexPositions[indexWest+1] - vertexPositions[index+1];
        west.z = vertexPositions[indexWest+2] - vertexPositions[index+2];

        east.x = vertexPositions[indexEast]   - vertexPositions[index];
        east.y = vertexPositions[indexEast+1] - vertexPositions[index+1];
        east.z = vertexPositions[indexEast+2] - vertexPositions[index+2];

        FVector3 southWestNormal, southEastNormal;
        fv3_vv_cross_product_v(&south, &west, &southWestNormal);
        fv3_vv_cross_product_v(&east, &south, &southEastNormal);

        FVector3 sum;
        fv3_vv_add_v(&southWestNormal, &southEastNormal, &sum);
        fv3_v_normalise(&sum);

        normals[index] = sum.x;
        normals[index+1] = sum.y;
        normals[index+2] = sum.z;
    }

    // Lower Border
    for ( Int j = 1; j < currentResolution->x - 1; j++ )
    {
        FVector3 north, west, east;
        Int index = ((currentResolution->y - 1) * currentResolution->x + j) * 3;
        Int indexNorth = ((currentResolution->y - 2) * currentResolution->x + j) * 3;
        Int indexWest  = ((currentResolution->y - 1) * currentResolution->x + j - 1) * 3;
        Int indexEast  = ((currentResolution->y - 1) * currentResolution->x + j + 1) * 3;

        north.x = vertexPositions[indexNorth]   - vertexPositions[index];
        north.y = vertexPositions[indexNorth+1] - vertexPositions[index+1];
        north.z = vertexPositions[indexNorth+2] - vertexPositions[index+2];

        west.x = vertexPositions[indexWest]   - vertexPositions[index];
        west.y = vertexPositions[indexWest+1] - vertexPositions[index+1];
        west.z = vertexPositions[indexWest+2] - vertexPositions[index+2];

        east.x = vertexPositions[indexEast]   - vertexPositions[index];
        east.y = vertexPositions[indexEast+1] - vertexPositions[index+1];
        east.z = vertexPositions[indexEast+2] - vertexPositions[index+2];

        FVector3 northWestNormal, northEastNormal;
        fv3_vv_cross_product_v(&west, &north, &northWestNormal);
        fv3_vv_cross_product_v(&north, &east, &northEastNormal);

        FVector3 sum;
        fv3_vv_add_v(&northWestNormal, &northEastNormal, &sum);
        fv3_v_normalise(&sum);

        normals[index]   = sum.x;
        normals[index+1] = sum.y;
        normals[index+2] = sum.z;
    }

    // Left Border
    for ( Int i = 1; i < currentResolution->y -1; i++ )
    {
        FVector3 north, south, east;
        Int index = (i * currentResolution->x) * 3;
        Int indexNorth = ((i - 1) * currentResolution->x) * 3;
        Int indexSouth = ((i + 1) * currentResolution->x) * 3;
        Int indexEast  = (i * currentResolution->x + 1) * 3;

        north.x = vertexPositions[indexNorth]   - vertexPositions[index];
        north.y = vertexPositions[indexNorth+1] - vertexPositions[index+1];
        north.z = vertexPositions[indexNorth+2] - vertexPositions[index+2];

        south.x = vertexPositions[indexSouth]   - vertexPositions[index];
        south.y = vertexPositions[indexSouth+1] - vertexPositions[index+1];
        south.z = vertexPositions[indexSouth+2] - vertexPositions[index+2];

        east.x = vertexPositions[indexEast]   - vertexPositions[index];
        east.y = vertexPositions[indexEast+1] - vertexPositions[index+1];
        east.z = vertexPositions[indexEast+2] - vertexPositions[index+2];

        FVector3 northEastNormal, southEastNormal;
        fv3_vv_cross_product_v(&north, &east, &northEastNormal);
        fv3_vv_cross_product_v(&east, &south, &southEastNormal);

        FVector3 sum;
        fv3_vv_add_v(&northEastNormal, &southEastNormal, &sum);
        fv3_v_normalise(&sum);

        normals[index]   = sum.x;
        normals[index+1] = sum.y;
        normals[index+2] = sum.z;
    }

    // Right border
    for ( Int i = 1; i < currentResolution->y -1; i++ )
    {
        FVector3 north, south, west;
        Int index = (i * currentResolution->x + currentResolution->x - 1) * 3;
        Int indexNorth = ((i - 1) * currentResolution->x + currentResolution->x - 1) * 3;
        Int indexSouth = ((i + 1) * currentResolution->x + currentResolution->x - 1) * 3;
        Int indexWest  = (i * currentResolution->x + currentResolution->x - 2) * 3;

        north.x = vertexPositions[indexNorth]   - vertexPositions[index];
        north.y = vertexPositions[indexNorth+1] - vertexPositions[index+1];
        north.z = vertexPositions[indexNorth+2] - vertexPositions[index+2];

        south.x = vertexPositions[indexSouth]   - vertexPositions[index];
        south.y = vertexPositions[indexSouth+1] - vertexPositions[index+1];
        south.z = vertexPositions[indexSouth+2] - vertexPositions[index+2];

        west.x = vertexPositions[indexWest]   - vertexPositions[index];
        west.y = vertexPositions[indexWest+1] - vertexPositions[index+1];
        west.z = vertexPositions[indexWest+2] - vertexPositions[index+2];

        FVector3 northWestNormal, southWestNormal;
        fv3_vv_cross_product_v(&west, &north, &northWestNormal);
        fv3_vv_cross_product_v(&south, &west, &southWestNormal);

        FVector3 sum;
        fv3_vv_add_v(&northWestNormal, &southWestNormal, &sum);
        fv3_v_normalise(&sum);

        normals[index]   = sum.x;
        normals[index+1] = sum.y;
        normals[index+2] = sum.z;
    }

    // inner faces

    for ( Int i = 1; i < currentResolution->y -1; i++ )
    {
        for ( Int j = 1; j < currentResolution->x - 1; j++ )
        {
            FVector3 north, south, west, east;
            Int index = (i * currentResolution->x + j) * 3;
            Int indexNorth = ((i - 1) * currentResolution->x + j) * 3;
            Int indexSouth = ((i + 1) * currentResolution->x + j) * 3;
            Int indexWest  = (i * currentResolution->x + j - 1) * 3;
            Int indexEast  = (i * currentResolution->x + j + 1) * 3;

            north.x = vertexPositions[indexNorth]   - vertexPositions[index];
            north.y = vertexPositions[indexNorth+1] - vertexPositions[index+1];
            north.z = vertexPositions[indexNorth+2] - vertexPositions[index+2];

            south.x = vertexPositions[indexSouth]   - vertexPositions[index];
            south.y = vertexPositions[indexSouth+1] - vertexPositions[index+1];
            south.z = vertexPositions[indexSouth+2] - vertexPositions[index+2];

            west.x = vertexPositions[indexWest]   - vertexPositions[index];
            west.y = vertexPositions[indexWest+1] - vertexPositions[index+1];
            west.z = vertexPositions[indexWest+2] - vertexPositions[index+2];

            east.x = vertexPositions[indexEast]   - vertexPositions[index];
            east.y = vertexPositions[indexEast+1] - vertexPositions[index+1];
            east.z = vertexPositions[indexEast+2] - vertexPositions[index+2];

            FVector3 northWestNormal, northEastNormal, southWestNormal, southEastNormal;
            fv3_vv_cross_product_v(&west, &north, &northWestNormal);
            fv3_vv_cross_product_v(&north, &east, &northEastNormal);
            fv3_vv_cross_product_v(&south, &west, &southWestNormal);
            fv3_vv_cross_product_v(&east, &south, &southEastNormal);
            fv3_v_normalise(&northWestNormal);
            fv3_v_normalise(&northEastNormal);
            fv3_v_normalise(&southWestNormal);
            fv3_v_normalise(&southEastNormal);

            FVector3 tmp, sum;
            fv3_vv_add_v(&northWestNormal, &northEastNormal, &sum);
            fv3_vv_add_v(&sum, &southWestNormal, &tmp);
            fv3_vv_add_v(&tmp, &southEastNormal, &sum);

            fv3_v_normalise(&sum);

            normals[index] = sum.x;
            normals[index+1] = sum.y;
            normals[index+2] = sum.z;
        }
    }

    [[ lods objectAtIndex:lodIndex ] setNormals:normals elementsForNormal:3 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT ];
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

    Int lodIndex = currentIteration - baseIterations;
    [[ lods objectAtIndex:lodIndex ] setIndices:indices indexCount:numberOfIndices ];
}

- (void) subdivide
{
    currentIteration = currentIteration + 1;

    lastResolution->x = currentResolution->x;
    lastResolution->y = currentResolution->y;

    currentResolution->x = (lastResolution->x - 1) * 2 + 1;
    currentResolution->y = (lastResolution->y - 1) * 2 + 1;
    //NSLog(@"res %d %d",currentResolution->x,currentResolution->y);

    Int numberOfVertices = currentResolution->x * currentResolution->y;
    Float * positions = ALLOC_ARRAY(Float, numberOfVertices * 3);

    Int lodIndex = currentIteration - baseIterations - 1;
    Float * currentPositions = [[ lods objectAtIndex:lodIndex ] positions ];

    Float rngVariance = variance/(Float)pow(2.0,(Double)(currentIteration)*(Double)H);
    //NSLog(@"variance %f",rngVariance);

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
                                      [ rng nextGaussianFPRandomNumberWithMean:0.0f andVariance:rngVariance ];
                                      
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
            positions[index+2] = (Float)( size->y)/2.0f - (Float)i * deltaY;

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
                        //south = diamondPositions[(lastResolution->x-1)+(j/2)];
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
                                         [ rng nextGaussianFPRandomNumberWithMean:0.0f andVariance:rngVariance ];
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
                                         [ rng nextGaussianFPRandomNumberWithMean:0.0f andVariance:rngVariance ];

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

    iterationsDone = iterationsDone + 1;
}

- (void) updateGeometry
{
    if ( [ lods count ] == 0 )
    {
        NPVertexBuffer * base = [[ NPVertexBuffer alloc ] initWithName:@"Base" parent:self ];
        [ lods addObject:base ];
        [ base release ];

        if ( image != nil )
        {
            [ self initialiseBaseLodPositions ];
        }
        else
        {
            [ self initialiseEmptyBaseLodPositions ];
        }

        [ self updateTextureCoordinates ];
        [ self updateNormals ];
        [ self updateIndices ];
    }

    /*while ( iterations > iterationsDone )
    {
        [ self subdivide ];
        [ self updateTextureCoordinates ];
        [ self updateNormals ];
        [ self updateIndices ];
    }*/
    

    /*if ( currentIteration > iterationsDone )
    {
        //subdivide
    }

    if ( currentIteration < iterationsDone )
    {
        // make lesser lod current
    }*/
}

- (void) update:(Float)frameTime
{
    if ( [ subdivideAction activated ] == YES )
    {
        [ self subdivide ];
        [ self updateTextureCoordinates ];
        [ self updateNormals ];
        [ self updateIndices ];
    }
}

- (void) render
{
    NPTextureBindingState * t = [[[ NP Graphics ] textureBindingStateManager ] currentTextureBindingState ];
    [ t setTexture:texture forKey:@"NPCOLORMAP0" ];

    [ effect activate ];
    [ effect uploadFVector3Parameter:lightPositionParameter andValue:lightPosition ];

    CGpass pass = [[ effect defaultTechnique ] firstPass ];

    while ( pass )
    {
        cgSetPassState(pass);

        Int lodIndex = currentIteration - baseIterations;
        [[ lods objectAtIndex:lodIndex ] renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];

        cgResetPassState(pass);
        pass = cgGetNextPass(pass);
    }

    [ effect deactivate ];
}

@end
