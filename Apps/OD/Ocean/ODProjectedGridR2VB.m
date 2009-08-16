#import "NP.h"

#import "ODProjectedGridR2VB.h"

#import "Entities/ODCamera.h"
#import "Entities/ODProjector.h"
#import "Utilities/ODFrustum.h"

#import "ODOceanTile.h"
#import "ODOceanAnimatedTile.h"

#import "ODScene.h"
#import "ODSceneManager.h"
#import "ODCore.h"

@implementation ODProjectedGridR2VB

- (id) init
{
    return [ self initWithName:@"ODProjectedGridR2VB" ];
}
- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    projectedGridResolution          = iv2_alloc_init();
    projectedGridResolutionLastFrame = iv2_alloc_init();

    mode = NP_NONE;

    basePlaneHeight   =  0.0f;
    upperSurfaceBound =  1.0f;
    lowerSurfaceBound = -1.0f;
    basePlane = fplane_alloc_init_with_components(0.0f, 1.0f, 0.0f, basePlaneHeight);

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"ocean_r2vb.cgfx" ];
    projectorIMVP = [ effect parameterWithName:@"projectorIMVP" ];
    deltaTime     = [ effect parameterWithName:@"deltaTime" ];
    NSAssert(projectorIMVP != NULL, @"Parameter \"projectorIMVP\" not found");

    renderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC" parent:self ];
    r2vbConfiguration = [[ NPR2VBConfiguration alloc ] initWithName:@"R2VB" parent:self ];

    return self;
}

- (void) dealloc
{
    [ renderTargetConfiguration clear   ];
    [ renderTargetConfiguration release ];

    [ r2vbConfiguration release ];

    [ projectedGrid release ];
    [ nearPlaneGrid release ];

    iv2_free(projectedGridResolution);
    iv2_free(projectedGridResolutionLastFrame);


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

- (void) setMode:(NpState)newMode
{
    mode = newMode;
}

- (void) setProjectedGridResolution:(IVector2)newProjectedGridResolution
{
    *projectedGridResolution = newProjectedGridResolution;
}

- (Float) basePlaneHeight
{
    return basePlaneHeight;
}

- (void) setBasePlaneHeight:(Float)newBasePlaneHeight
{
    basePlaneHeight = newBasePlaneHeight;
}

- (Float) upperSurfaceBound
{
    return upperSurfaceBound;
}

- (void)  setUpperSurfaceBound:(Float)newUpperSurfaceBound
{
    upperSurfaceBound = newUpperSurfaceBound;
}

- (Float) lowerSurfaceBound
{
    return lowerSurfaceBound;
}

- (void)  setLowerSurfaceBound:(Float)newLowerSurfaceBound
{
    lowerSurfaceBound = newLowerSurfaceBound;
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

    // Vertices start at top left
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

    // Vertices start at bottom left
    for ( Int i = 0; i < projectedGridResolution->y - 1; i++ )
    {
        for ( Int j = 0; j < projectedGridResolution->x - 1; j++ )
        {
            Int index = (i * ( projectedGridResolution->x - 1) + j) * 6;

            projectedGridIndices[index]   = i * projectedGridResolution->x + j;
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

- (void) update
{
    if ( (projectedGridResolution->x != projectedGridResolutionLastFrame->x) ||
         (projectedGridResolution->y != projectedGridResolutionLastFrame->y) )
    {
        [ self updateGeometry ];
        [ self updateRenderTargets ];
        [ self updateR2VB ];

        iv2_v_copy_v(projectedGridResolution, projectedGridResolutionLastFrame);
    }
}

- (void) renderAnimatedTile:(ODOceanAnimatedTile *)animatedTile
{
    [ renderTargetConfiguration activate ];
    [ renderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ animatedTile texture3D ] activateAtVolumeMapIndex:0 ];

    ODProjector * projector = [[[[ NP applicationController ] sceneManager ] currentScene ] projector ];
    [ effect uploadFMatrix4Parameter:projectorIMVP andValue:[projector inverseViewProjection]];
    [ effect uploadFloatParameter:deltaTime andValue:0.0f];
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

- (void) renderStaticTile:(ODOceanTile *)staticTile
{
    [ renderTargetConfiguration activate ];
    [ renderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ staticTile texture ] activateAtColorMapIndex:0 ];

    ODProjector * projector = [[[[ NP applicationController ] sceneManager ] currentScene ] projector ];

    [ effect uploadFMatrix4Parameter:projectorIMVP andValue:[projector inverseViewProjection]];
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

- (void) render
{

}

@end
