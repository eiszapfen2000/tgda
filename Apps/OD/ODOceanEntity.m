#import "ODOceanEntity.h"
#import "NP.h"

@implementation ODOceanEntity

- (id) init
{
    return [ self initWithName:@"ODOceanEntity" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    textures = [[ NSMutableArray alloc ] init ];
    numberOfSlices = 0;

    return self;
}

- (void) dealloc
{
    [ textures removeAllObjects ];
    [ textures release ];

    [ vertexBuffer release ];

    for ( UInt i = 0; i < numberOfSlices; i++ )
    {
        SAFE_FREE(heights[i]);
    }

    SAFE_FREE(heights);

    [ super dealloc ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    NSString * header = [ file readSUXString ];

    if ( [ header isEqual:@"OceanSurface" ] == NO )
    {
        NPLOG_ERROR(@"%@: invalid header", [file name]);
        return NO;
    }

    resolution = [ file readIVector2 ];
    [ file readUInt32:&numberOfSlices ];
    NPLOG(@"Resolution: %d x %d", resolution->x, resolution->y);
    NPLOG(@"Number of slices: %u", numberOfSlices);

    heights = ALLOC_ARRAY(Float *, numberOfSlices);

    for ( UInt i = 0; i < numberOfSlices; i++ )
    {
        UInt elementCount = resolution->x * resolution->y;
        heights[i] = ALLOC_ARRAY(Float, elementCount);
        UInt32 slice;
        [ file readUInt32:&slice ];
        [ file readFloats:heights[i] withLength:elementCount ];
    }

    NPLOG(@"Done reading data");
    NPLOG(@"Creating textures");

    for ( UInt i = 0; i < numberOfSlices; i++ )
    {
        id texture = [[[ NP Graphics ] textureManager ] createTextureWithName:[NSString stringWithFormat:@"Slice%d",i]
                                                                        width:resolution->x
                                                                       height:resolution->y
                                                                   dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                                  pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_R ];

        NSData * data = [ NSData dataWithBytesNoCopy:heights[i] length:sizeof(Float)*resolution->x*resolution->y freeWhenDone:NO ];
        [ texture uploadToGLWithData:data ];
        [ textures addObject:texture ];
    }

    NPLOG(@"Done creating textures");
    NPLOG(@"Loading ocean effect");

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"ocean.cgfx" ];

//--------------------------------------------//

    //IVector2 * viewportSize = [[[[ NP Graphics ] viewportManager ] currentViewport ] viewportSize ];
    IVector2 * viewportSize = iv2_alloc_init();
    viewportSize->x = viewportSize->y = 4;

    Int positionCount = viewportSize->x * viewportSize->y;
    Int indexCount = (viewportSize->x - 1) * (viewportSize->y - 1) * 6;
    Float * positions = ALLOC_ARRAY(Float, positionCount * 2);
    Float * texCoords = ALLOC_ARRAY(Float, positionCount * 2);
    Int * indices = ALLOC_ARRAY(Int, indexCount);

    // memory layout pbo vs vbo?

    Float deltaX = 2.0f/(Float)(viewportSize->x - 1);
    Float deltaY = 2.0f/(Float)(viewportSize->y - 1);

    // left to right, top to bottom
    for ( Int i = 0; i < viewportSize->y; i++ )
    {
        for ( Int j = 0; j < viewportSize->x; j++ )
        {
            Int index = (i*viewportSize->x+j)*2;
            positions[index]   = -1.0f + j * deltaX;
            positions[index+1] =  1.0f - i * deltaY;

            NSLog(@"%f %f",positions[index],positions[index+1]);

            texCoords[index]   =  0.0f + j * deltaX;
            texCoords[index+1] =  0.0f + i * deltaY;
        }
    }

    //Int triangleCount = (viewportSize->x - 1) * (viewportSize->y - 1) * 2;

    for ( Int i = 0; i < viewportSize->y - 1; i++ )
    {
        for ( Int j = 0; j < viewportSize->x - 1; j++ )
        {
            Int index = (i * ( viewportSize->x - 1) + j) * 6;
//            NSLog(@"index %d",index);

            indices[index] = i * viewportSize->x + j;
            indices[index+1] = (i + 1) * viewportSize->x + j;
            indices[index+2] = i * viewportSize->x + j + 1;

//            NSLog(@"%d %d %d",indices[index],indices[index+1],indices[index+2]);

            indices[index+3] = (i + 1) * viewportSize->x + j;
            indices[index+4] = (i + 1) * viewportSize->x + j + 1;
            indices[index+5] = i * viewportSize->x + j + 1;

//            NSLog(@"%d %d %d",indices[index+3],indices[index+4],indices[index+5]);
        }
    }

/*    for ( Int i = 0; i < indexCount; i++ )
    {
        NSLog(@"%d",indices[i]);
    }*/

    vertexBuffer = [[ NPVertexBuffer alloc ] initWithName:@"Ocean" parent:self ];
    [ vertexBuffer setPositions:positions elementsForPosition:2 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT vertexCount:positionCount ];
    [ vertexBuffer setTextureCoordinates:texCoords elementsForTextureCoordinates:2 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT forSet:0 ];
    [ vertexBuffer setIndices:indices indexCount:indexCount ];
    //[ vertexBuffer uploadVBOWithUsageHint:NP_GRAPHICS_VBO_UPLOAD_OFTEN_RENDER_OFTEN ];

    // create vbo the size of viewportSize, needs positions and texcoords
    // create corresponding pbos

    // render vbo using a shader which projects the grid on the nearplane to the y = 0 plane, then adds height from the
    // textures loaded
    // copy fbo color texture to pbo, now we have transformed the vbo positions
    // render vbo

    return YES;
}

- (BOOL) loadFromPath:(NSString *)path
{
    NPFile * file = [[ NPFile alloc ] initWithName:path parent:self fileName:path ];
    BOOL result = [ self loadFromFile:file ];
    [ file release ];

    return result;
}

- (void) update
{
}

- (void) render
{
    //glMatrixMode(GL_PROJECTION);
    //glLoadIdentity();
    //glMatrixMode(GL_MODELVIEW);
    //glLoadIdentity();

    NPTextureBindingState * t = [[[ NP Graphics ] textureBindingStateManager ] currentTextureBindingState ];
    [ t setTexture:[textures objectAtIndex:0] forKey:@"NPCOLORMAP0" ];

    //[[[ NP Graphics ] orthographicRendering ] activate ];

    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:NO ];
    [[[ NP Graphics ] stateConfiguration ] activate ];

    [ effect activate ];

    /*FMatrix4 brak;
    fm4_m_set_identity(&brak);
    [[[[ NP Core ] transformationStateManager ] currentTransformationState ] setModelMatrix:&brak ];
    [[[[ NP Core ] transformationStateManager ] currentTransformationState ] setViewMatrix:&brak ];
    [[[[ NP Core ] transformationStateManager ] currentTransformationState ] setProjectionMatrix:&brak ];*/


    CGpass pass = [[ effect defaultTechnique ] firstPass ];

    while ( pass )
    {
        cgSetPassState(pass);

        /*glBegin(GL_QUADS);
            glTexCoord2f(0.0f,0.0f);
            glVertex2f(-0.5f, 0.5f);
            glTexCoord2f(0.0f,1.0f);
            glVertex2f(-0.5f, -0.5f);
            glTexCoord2f(1.0f,1.0f);
            glVertex2f(0.5f, -0.5f);
            glTexCoord2f(1.0f,0.0f);
            glVertex2f(0.5f, 0.5);
        glEnd();*/

        //glColor3f(1.0f,1.0f,1.0f);
        [ vertexBuffer renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];

        cgResetPassState(pass);
        pass = cgGetNextPass(pass);
    }

    [ effect deactivate ];

    [[[ NP Graphics ] stateConfiguration ] deactivate ];

    //[[[ NP Graphics ] orthographicRendering ] activate ];
}

@end
