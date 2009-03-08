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

    H = 0.5f;
    iterations = 1;
    lightPosition = fv3_alloc_init();

    return self;
}

- (void) dealloc
{
    lightPosition = fv3_free(lightPosition);
    TEST_RELEASE(image);
    //TEST_RELEASE(effect);
    TEST_RELEASE(geometry);

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
    if ( imagePath == nil )
    {
        NPLOG_ERROR(@"%@: Image missing", path);
        return NO;
    }

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

    NSString * HString = [ sceneConfig objectForKey:@"H" ];
    if ( HString == nil )
    {
        NPLOG_WARNING(@"%@: H missing, using default", path);
    }

    NSString * iterationsString = [ sceneConfig objectForKey:@"Iterations" ];
    if ( iterationsString == nil )
    {
        NPLOG_WARNING(@"%@: Iterations missing, using default", path);
    }

    Int width = [ image width ];
    Int height = [ image height ];
    Byte * heights = [ image imageData ];

    Int numberOfVertices = width * height;
    Float * vertexPositions = ALLOC_ARRAY(Float, numberOfVertices * 3);
    Float * normals = ALLOC_ARRAY(Float, numberOfVertices * 3);

    Float deltaX = 10.0f / (Float)(width  -1);
    Float deltaY = 10.0f / (Float)(height -1);

    for ( Int i = 0; i < height; i++ )
    {
        for ( Int j = 0; j < width; j++ )
        {
            Int index = (i * width + j) * 3;
            vertexPositions[index]   = -5.0f + (Float)j * deltaX;            
            vertexPositions[index+1] =  (Float)heights[i * width + j]/255.0f;
            vertexPositions[index+2] =  5.0f - (Float)i * deltaY;
        }
    }

    //Corners
    normals[0] = normals[2] = 0.0f;
    normals[1] = 1.0f;

    normals[(width-1)*3] = normals[(width-1)*3+2] = 0.0f;
    normals[(width-1)*3+1] = 1.0f;

    normals[width*(height-1)*3] = normals[width*(height-1)*3+2] = 0.0f;
    normals[width*(height-1)*3+1] = 1.0f;

    normals[(width*(height-1)+width-1)*3] = normals[(width*(height-1)+width-1)*3+2] = 0.0f;
    normals[(width*(height-1)+width-1)*3+1] = 1.0f;

    // Upper Border
    for ( Int j = 1; j < width - 1; j++ )
    {
        FVector3 south, west, east;
        Int index = j * 3;
        Int indexSouth = (width + j) * 3;
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
    for ( Int j = 1; j < width - 1; j++ )
    {
        FVector3 north, west, east;
        Int index = ((height - 1) * width + j) * 3;
        Int indexNorth = ((height - 2) * width + j) * 3;
        Int indexWest  = ((height - 1) * width + j - 1) * 3;
        Int indexEast  = ((height - 1) * width + j + 1) * 3;

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
    for ( Int i = 1; i < height -1; i++ )
    {
        FVector3 north, south, east;
        Int index = (i * width) * 3;
        Int indexNorth = ((i - 1) * width) * 3;
        Int indexSouth = ((i + 1) * width) * 3;
        Int indexEast  = (i * width + 1) * 3;

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
    for ( Int i = 1; i < height -1; i++ )
    {
        FVector3 north, south, west;
        Int index = (i * width + width - 1) * 3;
        Int indexNorth = ((i - 1) * width + width - 1) * 3;
        Int indexSouth = ((i + 1) * width + width - 1) * 3;
        Int indexWest  = (i * width + width - 2) * 3;

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

    for ( Int i = 1; i < height -1; i++ )
    {
        for ( Int j = 1; j < width - 1; j++ )
        {
            FVector3 north, south, west, east;
            Int index = (i * width + j) * 3;
            Int indexNorth = ((i - 1) * width + j) * 3;
            Int indexSouth = ((i + 1) * width + j) * 3;
            Int indexWest  = (i * width + j - 1) * 3;
            Int indexEast  = (i * width + j + 1) * 3;

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

            FVector3 tmp, sum;
            fv3_vv_add_v(&northWestNormal, &northEastNormal, &sum);
            fv3_vv_add_v(&sum, &southWestNormal, &tmp);
            fv3_vv_add_v(&tmp, &southEastNormal, &sum);

            fv3_v_normalise(&sum);

            normals[index] = sum.x;
            normals[index+1] = sum.y;
            normals[index+2] = sum.z;

            /*NSLog(@"%s",fv3_v_to_string(&northWestNormal));
            NSLog(@"%s",fv3_v_to_string(&northEastNormal));
            NSLog(@"%s",fv3_v_to_string(&southWestNormal));
            NSLog(@"%s",fv3_v_to_string(&southEastNormal));*/
        }
    }

    Int numberOfIndices = ( width -1 ) * ( height - 1 ) * 6;
    Int32 * indices = ALLOC_ARRAY(Int, numberOfIndices);

    for ( Int i = 0; i < height - 1; i++ )
    {
        for ( Int j = 0; j < width - 1; j++ )
        {
            Int index = (i * ( width - 1) + j) * 6;

            indices[index] = i * width + j;
            indices[index+1] = (i + 1) * width + j;
            indices[index+2] = i * width + j + 1;

            indices[index+3] = (i + 1) * width + j;
            indices[index+4] = (i + 1) * width + j + 1;
            indices[index+5] = i * width + j + 1;
        }
    }

    geometry = [[ NPVertexBuffer alloc ] initWithName:@"Terrain" parent:self ];
    [ geometry setPositions:vertexPositions elementsForPosition:3 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT vertexCount:numberOfVertices ];
    [ geometry setNormals:normals elementsForNormal:3 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT ];
    [ geometry setIndices:indices indexCount:numberOfIndices ];

    lightPosition->x = 0.0f;
    lightPosition->z = 0.0f;
    lightPosition->y = 10.0f;

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"terrain.cgfx" ];
    lightPositionParameter = [ effect parameterWithName:@"lightPosition" ];
    if ( lightPositionParameter == NULL )
    {
        NPLOG_ERROR(@"Light position paramter not found");
        return NO;
    }


    return YES;
}

- (void) update:(Float)frameTime
{
}

- (void) render
{
    [ effect activate ];
    [ effect uploadFVector3Parameter:lightPositionParameter andValue:lightPosition ];

    CGpass pass = [[ effect defaultTechnique ] firstPass ];

    while ( pass )
    {
        cgSetPassState(pass);

        [ geometry renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];

        cgResetPassState(pass);
        pass = cgGetNextPass(pass);
    }

    [ effect deactivate ];
}

@end
