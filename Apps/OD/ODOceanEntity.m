#import "NP.h"
#import "ODScene.h"
#import "ODSceneManager.h"
#import "ODOceanEntity.h"
#import "ODProjector.h"
#import "ODCore.h"


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

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"ocean.cgfx" ];
    projectorIMVP = [ effect parameterWithName:@"projectorIMVP" ];
    NSAssert(projectorIMVP != NULL, @"Parameter \"projectorIMVP\" not found");

    wtexture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:@"wasser.jpg" ];

    renderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC" parent:self ];

    id tempRenderTexture = [ NPRenderTexture renderTextureWithName:@"RT"
                                                              type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                             width:256
                                                            height:256
                                                        dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                       pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                     textureFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                       textureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    [ renderTargetConfiguration setColorRenderTarget:tempRenderTexture atIndex:0 ];

    r2vbConfiguration = [[ NPR2VBConfiguration alloc ] initWithName:@"R2VB" parent:self ];

    return self;
}

- (void) dealloc
{
    [ r2vbConfiguration release ];

    [ textures removeAllObjects ];
    [ textures release ];

    [ renderTargetConfiguration clear ];
    [ renderTargetConfiguration release ];

    TEST_RELEASE(nearPlaneGrid);
    TEST_RELEASE(projectedGrid);

    for ( UInt i = 0; i < numberOfSlices; i++ )
    {
        SAFE_FREE(heights[i]);
    }

    SAFE_FREE(heights);

    [ super dealloc ];
}

- (id) renderTexture
{
    return [ renderTargetConfiguration renderTextureAtIndex:0 ];
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

    times   = ALLOC_ARRAY(Float  , numberOfSlices);
    heights = ALLOC_ARRAY(Float *, numberOfSlices);

    for ( UInt i = 0; i < numberOfSlices; i++ )
    {
        UInt elementCount = resolution->x * resolution->y;
        heights[i] = ALLOC_ARRAY(Float, elementCount);
        UInt32 slice;
        [ file readUInt32:&slice ];
        [ file readFloat:&(times[i]) ];
        [ file readFloats:heights[i] withLength:elementCount ];
    }

    NPLOG(@"Done reading data");
    NPLOG(@"Creating textures");

    for ( UInt i = 0; i < numberOfSlices; i++ )
    {
        NPTexture * texture = [[ NPTexture alloc ] initWithName:[NSString stringWithFormat:@"Slice%d", i]
                                                         parent:self ];
        [ texture setResolution:resolution ];
        [ texture setDataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT ];
        [ texture setPixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_R ];
        [ texture setMipMapping:NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_INACTIVE ];
        [ texture setTextureFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [ texture setTextureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT ];

        NSData * data = [ NSData dataWithBytesNoCopy:heights[i] 
                                              length:sizeof(Float)*resolution->x*resolution->y
                                        freeWhenDone:NO ];

        [ texture uploadToGLWithData:data ];
        [ textures addObject:texture ];
        [ texture release ];
    }

    NPLOG(@"Done creating textures");

//--------------------------------------------//

    //IVector2 * viewportSize = [[[[ NP Graphics ] viewportManager ] currentViewport ] viewportSize ];
    IVector2 * viewportSize = iv2_alloc_init();
    viewportSize->x = 256;
    viewportSize->y = 256;

    Int positionCount = viewportSize->x * viewportSize->y;
    Int indexCount = (viewportSize->x - 1) * (viewportSize->y - 1) * 6;
    Float * positions = ALLOC_ARRAY(Float, positionCount * 2);
    Float * texCoords = ALLOC_ARRAY(Float, positionCount * 2);
    Int32 * nearPlaneGridIndices = ALLOC_ARRAY(Int32, indexCount);
    Int32 * projectedGridIndices = ALLOC_ARRAY(Int32, indexCount);

    // memory layout pbo vs vbo?

    Float deltaX = 2.0f/(Float)(viewportSize->x - 1);
    Float deltaY = 2.0f/(Float)(viewportSize->y - 1);

    Float tdeltaX = 1.0f/(Float)(viewportSize->x - 1);
    Float tdeltaY = 1.0f/(Float)(viewportSize->y - 1);

    // left to right, top to bottom
    for ( Int i = 0; i < viewportSize->y; i++ )
    {
        for ( Int j = 0; j < viewportSize->x; j++ )
        {
            Int index = (i * viewportSize->x + j) * 2;
            positions[index]   = -1.0f + j * deltaX;
            positions[index+1] =  1.0f - i * deltaY;

            texCoords[index]   =  0.0f + j * tdeltaX;
            texCoords[index+1] =  1.0f - i * tdeltaY;
        }
    }

    for ( Int i = 0; i < viewportSize->y - 1; i++ )
    {
        for ( Int j = 0; j < viewportSize->x - 1; j++ )
        {
            Int index = (i * ( viewportSize->x - 1) + j) * 6;

            nearPlaneGridIndices[index] = i * viewportSize->x + j;
            nearPlaneGridIndices[index+1] = (i + 1) * viewportSize->x + j;
            nearPlaneGridIndices[index+2] = i * viewportSize->x + j + 1;

            nearPlaneGridIndices[index+3] = (i + 1) * viewportSize->x + j;
            nearPlaneGridIndices[index+4] = (i + 1) * viewportSize->x + j + 1;
            nearPlaneGridIndices[index+5] = i * viewportSize->x + j + 1;
        }
    }

    for ( Int i = 0; i < viewportSize->y - 1; i++ )
    {
        for ( Int j = 0; j < viewportSize->x - 1; j++ )
        {
            Int index = (i * ( viewportSize->x - 1) + j) * 6;

            projectedGridIndices[index] = i * viewportSize->x + j;
            projectedGridIndices[index+2] = (i + 1) * viewportSize->x + j;
            projectedGridIndices[index+1] = i * viewportSize->x + j + 1;

            projectedGridIndices[index+3] = (i + 1) * viewportSize->x + j;
            projectedGridIndices[index+5] = (i + 1) * viewportSize->x + j + 1;
            projectedGridIndices[index+4] = i * viewportSize->x + j + 1;
        }
    }

    //COPY_ARRAY(nearPlaneGridIndices, projectedGridIndices, Int32, indexCount);

    nearPlaneGrid = [[ NPVertexBuffer alloc ] initWithName:@"Grid" parent:self ];
    [ nearPlaneGrid setPositions:positions elementsForPosition:2 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT vertexCount:positionCount ];
    [ nearPlaneGrid setTextureCoordinates:texCoords elementsForTextureCoordinates:2 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT forSet:0 ];
    [ nearPlaneGrid setIndices:nearPlaneGridIndices indexCount:indexCount ];
    [ nearPlaneGrid uploadVBOWithUsageHint:NP_GRAPHICS_VBO_UPLOAD_OFTEN_RENDER_OFTEN ];

    projectedGrid = [[ NPVertexBuffer alloc ] initWithName:@"ProjectedGrid" parent:self ];
    [ projectedGrid setPositions:NULL elementsForPosition:4 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT vertexCount:positionCount ];
    //[ projectedGrid setTextureCoordinates:NULL elementsForTextureCoordinates:2 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT forSet:0 ];
    [ projectedGrid setIndices:projectedGridIndices indexCount:indexCount ];
    [ projectedGrid uploadVBOWithUsageHint:NP_GRAPHICS_VBO_UPLOAD_OFTEN_RENDER_OFTEN ];

    [ r2vbConfiguration setTarget:projectedGrid ];
    [ r2vbConfiguration setRenderTextureSource:[renderTargetConfiguration renderTextureAtIndex:0] forTargetBuffer:@"Positions" ];

    //projectedGridPBOs = [[[[ NP Graphics ] pixelBufferManager ] createPBOsSharingDataWithVBO:projectedGrid ] retain ];
    //NSLog([projectedGridPBOs description]);

    return YES;
}

- (BOOL) loadFromPath:(NSString *)path
{
    NPFile * file = [[ NPFile alloc ] initWithName:path parent:self fileName:path ];
    BOOL result = [ self loadFromFile:file ];
    [ file release ];

    return result;
}

- (void) update:(Float)frameTime
{
}

- (void) renderWithR2VB
{
    // create vbo the size of viewportSize, needs positions and texcoords
    // create corresponding pbos

    // render vbo using a shader which projects the grid on the nearplane to the y = 0 plane, then adds height from the
    // textures loaded
    // copy fbo color texture to pbo, now we have transformed the vbo positions
    // render vbo
}

- (void) renderWithVertexTextureFetch
{

}

- (void) render
{
    [ renderTargetConfiguration activate ];
    [ renderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    //[ wtexture activateAtColorMapIndex:1 ];
    [[textures objectAtIndex:0] activateAtColorMapIndex:0 ];

    ODProjector * projector = [[[[ NP applicationController ] sceneManager ] currentScene ] projector ];
    [ effect uploadFMatrix4Parameter:projectorIMVP andValue:[projector inverseModelViewProjection]];
    [ effect activateTechniqueWithName:@"ocean_r2vb" ];

    //[ r2vbEffect uploadFMatrix4Parameter:r2vbProjectorIMVP andValue:[projector inverseModelViewProjection]];
    //[ r2vbEffect activateTechniqueWithName:@"ocean" ];

    [ nearPlaneGrid renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];

    [ effect deactivate ];

    [ r2vbConfiguration copyBuffers ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [ effect activateTechniqueWithName:@"ocean_simple" ];

    [ projectedGrid renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];

    [ effect deactivate ];

    [ renderTargetConfiguration deactivate ];    
}

@end
