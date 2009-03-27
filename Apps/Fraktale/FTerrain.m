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
    [ rngs setObject:g forKey:@"mersenne" ];

    size = iv2_alloc_init();
    size->x = size->y = -1;

    currentResolution = iv2_alloc_init();
    currentResolution->x = currentResolution->y = -1;
    lastResolution = iv2_alloc_init();
    lastResolution->x = lastResolution->y = -1;
    baseResolution = iv2_alloc_init();
    baseResolution->x = baseResolution->y = -1;

    H = 0.5f;
    sigma = 1.0f;
    variance = 1.0f;
    minimumHeight = 0.0f;
    maximumHeight = 1.0f;

    iterations = 0;
    baseIterations = 0;
    currentIteration = 0;
//    iterationsDone = 0;
    iterationsToDo = 0;
    currentLod = 0;

    lightPosition = fv3_alloc_init();

    lods = [[ NSMutableArray alloc ] init ];

    gaussianRng = [[[ NP Core ] randomNumberGeneratorManager ] gaussianGeneratorWithName:@"Gaussian"
                                                    firstFixedParameterGenerator:NP_RNG_TT800
                                                   secondFixedParameterGenerator:NP_RNG_CTG ];

    subdivideAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"Subdivide" primaryInputAction:NP_INPUT_KEYBOARD_PLUS ];

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

    TEST_RELEASE(image);

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

//    NSLog(@"%d %d %d %d", currentResolution->x, currentResolution->y, lastResolution->x, lastResolution->y);
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

//    iterationsDone = baseIterations;
    currentIteration = baseIterations;
    currentLod = currentIteration - baseIterations;

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

    NSString * minimumHeightString = [ sceneConfig objectForKey:@"MinimumHeight" ];
    if ( minimumHeightString == nil )
    {
        NPLOG_WARNING(@"%@: MinimumHeight missing, using default", path);
        minimumHeightString = [ NSString stringWithFormat:@"%f", minimumHeight ];
    }
    else
    {
        minimumHeight = [ minimumHeightString floatValue ];
    }

    NSString * maximumHeightString = [ sceneConfig objectForKey:@"MaximumHeight" ];
    if ( maximumHeightString == nil )
    {
        NPLOG_WARNING(@"%@: MaximumHeight missing, using default", path);
        maximumHeightString = [ NSString stringWithFormat:@"%f", maximumHeight ];
    }
    else
    {
        maximumHeight = [ minimumHeightString floatValue ];
    }

    NSString * HString = [ sceneConfig objectForKey:@"H" ];
    if ( HString == nil )
    {
        NPLOG_WARNING(@"%@: H missing, using default", path);
        HString = [ NSString stringWithFormat:@"%f", H ];
    }
    else
    {
        H = [ HString floatValue ];
    }

    NSString * sigmaString = [ sceneConfig objectForKey:@"Sigma" ];
    if ( sigmaString == nil )
    {
        NPLOG_WARNING(@"%@: Sigma missing, using default", path);
        sigmaString = [ NSString stringWithFormat:@"%f", sigma ];
    }
    else
    {
        sigma = [ sigmaString floatValue ];
    }

    NSString * iterationsString = [ sceneConfig objectForKey:@"Iterations" ];
    if ( iterationsString == nil )
    {
        NPLOG_WARNING(@"%@: Iterations missing, using default", path);
        iterationsString = [ NSString stringWithFormat:@"%d", iterations ];
    }
    else
    {
        iterationsToDo = [ iterationsString intValue ];
    }

    [[ NP attributesWindowController ] setWidthTextfieldString :[ terrainSizeStrings objectAtIndex:0 ]];
    [[ NP attributesWindowController ] setLengthTextfieldString:[ terrainSizeStrings objectAtIndex:1 ]];
    [[ NP attributesWindowController ] setMinimumHeightTextfieldString:minimumHeightString ];
    [[ NP attributesWindowController ] setMaximumHeightTextfieldString:maximumHeightString ];
    [[ NP attributesWindowController ] setHTextfieldString:HString ];
    [[ NP attributesWindowController ] setSigmaTextfieldString:sigmaString ];
    [[ NP attributesWindowController ] setIterationsTextfieldString:iterationsString ];

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

- (void) reset
{
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

    //Int lodIndex = currentIteration - baseIterations;
    [[ lods objectAtIndex:currentLod ] setTextureCoordinates:texCoords 
                             elementsForTextureCoordinates:2
                                                dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                    forSet:0 ]; 
}

- (void) updateNormals
{
    Int numberOfVertices = currentResolution->x * currentResolution->y;
    Float * normals = ALLOC_ARRAY(Float, numberOfVertices * 3);

    //Int lodIndex = currentIteration - baseIterations;
    Float * vertexPositions = [[ lods objectAtIndex:currentLod ] positions ];

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

    [[ lods objectAtIndex:currentLod ] setNormals:normals elementsForNormal:3 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT ];
}

- (void) updateAO
{
    
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

    //Int lodIndex = currentIteration - baseIterations;
    [[ lods objectAtIndex:currentLod ] setIndices:indices indexCount:numberOfIndices ];
}

- (void) subdivide
{
    currentIteration = currentIteration + 1;
    currentLod = currentIteration - baseIterations;
    //NSLog(@"%d",currentLod);

    lastResolution->x = currentResolution->x;
    lastResolution->y = currentResolution->y;

    currentResolution->x = (lastResolution->x - 1) * 2 + 1;
    currentResolution->y = (lastResolution->y - 1) * 2 + 1;
    //NSLog(@"res %d %d",currentResolution->x,currentResolution->y);

    Int numberOfVertices = currentResolution->x * currentResolution->y;
    Float * positions = ALLOC_ARRAY(Float, numberOfVertices * 3);

    //Int lodIndex = currentIteration - baseIterations - 1;
    Float * currentPositions = [[ lods objectAtIndex:currentLod-1 ] positions ];

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
        [ self updateIndices ];

        [[ NP attributesWindowController ] addLodPopUpItemWithNumber  :currentLod ];
        [[ NP attributesWindowController ] selectLodPopUpItemWithIndex:currentLod ];

        iterationsDone = iterationsDone + 1;
    }

    //currentIteration = 0;
}

- (void) update:(Float)frameTime
{
    /*if ( [ subdivideAction activated ] == YES )
    {
        [ self subdivide ];
        [ self updateTextureCoordinates ];
        [ self updateNormals ];
        [ self updateIndices ];

        [[ NP attributesWindowController ] addLodPopUpItemWithNumber  :currentLod ];
        [[ NP attributesWindowController ] selectLodPopUpItemWithIndex:currentLod ];
    }*/
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

        //Int lodIndex = currentIteration - baseIterations;
        [[ lods objectAtIndex:currentLod ] renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];

        cgResetPassState(pass);
        pass = cgGetNextPass(pass);
    }

    [ effect deactivate ];
}

@end
