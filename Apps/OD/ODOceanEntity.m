#import "NP.h"
#import "ODScene.h"
#import "ODSceneManager.h"
#import "ODOceanEntity.h"
#import "ODOceanTile.h"
#import "ODOceanAnimatedTile.h"
#import "ODCore.h"
#import "ODProjector.h"

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

    projectedGridResolution = iv2_alloc_init();
    projectedGridResolutionLastFrame = iv2_alloc_init();

    mode = NP_NONE;

    staticTiles = [[ NSMutableArray alloc ] init ];
    animatedTiles = [[ NSMutableArray alloc ] init ];

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"ocean.cgfx" ];
    projectorIMVP = [ effect parameterWithName:@"projectorIMVP" ];
    deltaTime     = [ effect parameterWithName:@"deltaTime" ];
    NSAssert(projectorIMVP != NULL && deltaTime != NULL, @"Parameter \"projectorIMVP\" not found");

    periodTime = 0.0f;

    renderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC" parent:self ];
    r2vbConfiguration = [[ NPR2VBConfiguration alloc ] initWithName:@"R2VB" parent:self ];

    return self;
}

- (void) dealloc
{
    [ staticTiles removeAllObjects ];
    [ staticTiles release ];

    [ animatedTiles removeAllObjects ];
    [ animatedTiles release ];

    [ r2vbConfiguration release ];

    [ renderTargetConfiguration clear ];
    [ renderTargetConfiguration release ];

    TEST_RELEASE(nearPlaneGrid);
    TEST_RELEASE(projectedGrid);

    projectedGridResolution = iv2_free(projectedGridResolution);
    projectedGridResolutionLastFrame = iv2_free(projectedGridResolutionLastFrame);

    [ super dealloc ];
}

- (NpState) mode
{
    return mode;
}

- (IVector2) projectedGridResolution
{
    return *projectedGridResolution;
}

- (id) renderTexture
{
    return [ renderTargetConfiguration renderTextureAtIndex:0 ];
}

- (void) setMode:(NpState)newMode
{
    switch ( newMode )
    {
        case ODOCEAN_STATIC :{ mode = newMode; break; }
        case ODOCEAN_DYNAMIC:{ mode = newMode; break; }

        default: {NPLOG_ERROR(@"Unknown mode %d", newMode); break;}
    }
}

- (void) setProjectedGridResolution:(IVector2)newProjectedGridResolution
{
    *projectedGridResolution = newProjectedGridResolution;
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
{
    NSString * entityName   = [ config objectForKey:@"Name" ];
    NSArray  * dataSetFiles = [ config objectForKey:@"DataSets" ];
    NSArray  * projectedGridResolutionStrings = [ config objectForKey:@"ProjectedGridResolution" ];    

    if ( entityName == nil || dataSetFiles == nil || projectedGridResolutionStrings == nil )
    {
        NPLOG_ERROR(@"Scene config is incomplete");
        return NO;
    }

    [ self setName:entityName ];

    projectedGridResolution->x = [[ projectedGridResolutionStrings objectAtIndex:0 ] intValue ];
    projectedGridResolution->y = [[ projectedGridResolutionStrings objectAtIndex:1 ] intValue ];
    NSAssert1(projectedGridResolution->x > 0 && projectedGridResolution->y > 0, @"%@: Invalid resolution", name);

    NPLOG(@"");
    NPLOG(@"Projected grid resolution: %d x %d", projectedGridResolution->x, projectedGridResolution->y);

    NSEnumerator * dataSetFilesEnumerator = [ dataSetFiles objectEnumerator ];
    id dataSetFileName;

    while ( (dataSetFileName = [ dataSetFilesEnumerator nextObject ]) )
    {
        NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:dataSetFileName ];

        if ( [ absolutePath isEqual:@"" ] == NO )
        {
            NPFile * file = [[ NPFile alloc ] initWithName:absolutePath parent:self fileName:absolutePath ];

            NSString * header = [ file readSUXString ];
            if ( [ header isEqual:@"OceanSurface" ] == YES )
            {
                BOOL animated;
                [ file readBool:&animated ];

                if ( animated == NO )
                {
                    NPLOG(@"");
                    NPLOG(@"Loading static tile %@", absolutePath);

                    ODOceanTile * staticTile = [[ ODOceanTile alloc ] initWithName:absolutePath ];
                    BOOL result = [ staticTile loadFromFile:file ];

                    if ( result == YES )
                    {
                        [ staticTiles addObject:staticTile ];
                    }

                    [ staticTile release ];
                }
                else
                {
                    NPLOG(@"");
                    NPLOG(@"Loading animated tile %@", absolutePath);

                    ODOceanAnimatedTile * animatedTile = [[ ODOceanAnimatedTile alloc ] initWithName:absolutePath ];
                    BOOL result = [ animatedTile loadFromFile:file ];

                    if ( result == YES )
                    {
                        [ animatedTiles addObject:animatedTile ];
                    }

                    [ animatedTile release ];
                }
            }

            [ file release ];
        }
    }

    if ( [ staticTiles count ] > 0 )
    {
        currentStaticTile = [ staticTiles objectAtIndex:0 ];
    }

    if ( [ animatedTiles count ] > 0 )
    {
        currentAnimatedTile = [ animatedTiles objectAtIndex:0 ];
    }

    return YES;
}

- (void) updateGeometry
{
    if ( nearPlaneGrid != nil )
    {
        DESTROY(nearPlaneGrid);
    }

    if ( projectedGrid != nil )
    {
        DESTROY(projectedGrid);
    }

    Int positionCount = projectedGridResolution->x * projectedGridResolution->y;
    Int indexCount    = (projectedGridResolution->x - 1) * (projectedGridResolution->y - 1) * 6;

    Float * positions = ALLOC_ARRAY(Float, positionCount * 2);
    Float * texCoords = ALLOC_ARRAY(Float, positionCount * 2);

    Int32 * nearPlaneGridIndices = ALLOC_ARRAY(Int32, indexCount);
    Int32 * projectedGridIndices = ALLOC_ARRAY(Int32, indexCount);

    // memory layout pbo vs vbo?

    Float deltaX = 2.0f/(Float)(projectedGridResolution->x - 1);
    Float deltaY = 2.0f/(Float)(projectedGridResolution->y - 1);

    Float tdeltaX = 1.0f/(Float)(projectedGridResolution->x - 1);
    Float tdeltaY = 1.0f/(Float)(projectedGridResolution->y - 1);

    // left to right, top to bottom
    for ( Int i = 0; i < projectedGridResolution->y; i++ )
    {
        for ( Int j = 0; j < projectedGridResolution->x; j++ )
        {
            Int index = (i * projectedGridResolution->x + j) * 2;
            positions[index]   = -1.0f + j * deltaX;
            positions[index+1] =  1.0f - i * deltaY;

            texCoords[index]   =  0.0f + j * tdeltaX;
            texCoords[index+1] =  1.0f - i * tdeltaY;
        }
    }

    for ( Int i = 0; i < projectedGridResolution->y - 1; i++ )
    {
        for ( Int j = 0; j < projectedGridResolution->x - 1; j++ )
        {
            Int index = (i * ( projectedGridResolution->x - 1) + j) * 6;

            nearPlaneGridIndices[index] = i * projectedGridResolution->x + j;
            nearPlaneGridIndices[index+1] = (i + 1) * projectedGridResolution->x + j;
            nearPlaneGridIndices[index+2] = i * projectedGridResolution->x + j + 1;

            nearPlaneGridIndices[index+3] = (i + 1) * projectedGridResolution->x + j;
            nearPlaneGridIndices[index+4] = (i + 1) * projectedGridResolution->x + j + 1;
            nearPlaneGridIndices[index+5] = i * projectedGridResolution->x + j + 1;
        }
    }

    for ( Int i = 0; i < projectedGridResolution->y - 1; i++ )
    {
        for ( Int j = 0; j < projectedGridResolution->x - 1; j++ )
        {
            Int index = (i * ( projectedGridResolution->x - 1) + j) * 6;

            projectedGridIndices[index] = i * projectedGridResolution->x + j;
            projectedGridIndices[index+1] = i * projectedGridResolution->x + j + 1;
            projectedGridIndices[index+2] = (i + 1) * projectedGridResolution->x + j;

            projectedGridIndices[index+3] = i * projectedGridResolution->x + j + 1;
            projectedGridIndices[index+4] = (i + 1) * projectedGridResolution->x + j + 1;
            projectedGridIndices[index+5] = (i + 1) * projectedGridResolution->x + j;
        }
    }

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
}

- (void) updateRenderTargets
{
    [ renderTargetConfiguration clear ];

    id tempRenderTexture = [ NPRenderTexture renderTextureWithName:@"RT"
                                                              type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                             width:projectedGridResolution->x
                                                            height:projectedGridResolution->y
                                                        dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                       pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                     textureFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                       textureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    [ renderTargetConfiguration setColorRenderTarget:tempRenderTexture atIndex:0 ];
}

- (void) updateR2VB
{
    [ r2vbConfiguration clear ];

    [ r2vbConfiguration setTarget:projectedGrid ];
    [ r2vbConfiguration setRenderTextureSource:[renderTargetConfiguration renderTextureAtIndex:0] forTargetBuffer:@"Positions" ];
}

- (void) update:(Float)frameTime
{
    if ( (projectedGridResolution->x != projectedGridResolutionLastFrame->x) ||
         (projectedGridResolution->y != projectedGridResolutionLastFrame->y) )
    {
        [ self updateGeometry ];
        [ self updateRenderTargets ];
        [ self updateR2VB ];

        iv2_v_copy_v(projectedGridResolution, projectedGridResolutionLastFrame);
    }

    periodTime += frameTime;
}

- (void) renderStatic
{
    [ renderTargetConfiguration activate ];
    [ renderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ currentStaticTile texture ] activateAtColorMapIndex:0 ];

    ODProjector * projector = [[[[ NP applicationController ] sceneManager ] currentScene ] projector ];
    [ effect uploadFMatrix4Parameter:projectorIMVP andValue:[projector inverseModelViewProjection]];
    [ effect activateTechniqueWithName:@"ocean_r2vb" ];
    [ nearPlaneGrid renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];
    [ effect deactivate ];

    [ r2vbConfiguration copyBuffers ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [ effect activateTechniqueWithName:@"ocean_simple" ];
    [ projectedGrid renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];
    [ effect deactivate ];

    [ renderTargetConfiguration deactivate ];
}

- (void) renderAnimated
{
    [ renderTargetConfiguration activate ];
    [ renderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

//    [[ currentAnimatedTile sliceAtIndex:2 ] activateAtColorMapIndex:0 ];
    [[ currentAnimatedTile texture3D ] activateAtVolumeMapIndex:0 ];

    ODProjector * projector = [[[[ NP applicationController ] sceneManager ] currentScene ] projector ];
    [ effect uploadFMatrix4Parameter:projectorIMVP andValue:[projector inverseModelViewProjection]];
    [ effect uploadFloatParameter:deltaTime andValue:periodTime];
    [ effect activateTechniqueWithName:@"ocean_r2vb_animated" ];
    [ nearPlaneGrid renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];
    [ effect deactivate ];

    [ r2vbConfiguration copyBuffers ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [ effect activateTechniqueWithName:@"ocean_simple" ];
    [ projectedGrid renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];
    [ effect deactivate ];

    [ renderTargetConfiguration deactivate ];
}

- (void) render
{
    [ self renderAnimated ];
}

@end
