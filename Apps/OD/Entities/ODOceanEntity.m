#import "NP.h"

#import "ODCore.h"
#import "ODScene.h"
#import "ODSceneManager.h"

#import "Ocean/ODOceanTile.h"
#import "Ocean/ODOceanAnimatedTile.h"
#import "Ocean/ODProjectedGridCPU.h"
#import "Ocean/ODProjectedGridR2VB.h"
#import "Entities/ODProjector.h"

#import "ODOceanEntity.h"

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

    projectedGridResolution          = iv2_alloc_init();
    projectedGridResolutionLastFrame = iv2_alloc_init();

    mode = NP_NONE;

    basePlaneHeight = 0.0f;
    upperSurfaceBound = 1.0f;
    lowerSurfaceBound = -1.0f;
    basePlane = fplane_alloc_init_with_components(0.0f, 1.0f, 0.0f, basePlaneHeight);

    projectedGridCPU = [[ ODProjectedGridCPU alloc ] initWithName:@"CPU" parent:self ];
    [ projectedGridCPU setMode:OD_PROJECT_ENTIRE_MESH_ON_CPU ];

    projectedGridR2VB = [[ ODProjectedGridR2VB alloc ] initWithName:@"R2VB" parent:self ];

    staticTiles   = [[ NSMutableArray alloc ] init ];
    animatedTiles = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ projectedGridCPU release ];
    [ projectedGridR2VB release ];

    [ staticTiles removeAllObjects ];
    [ staticTiles release ];

    [ animatedTiles removeAllObjects ];
    [ animatedTiles release ];

    projectedGridResolution = iv2_free(projectedGridResolution);
    projectedGridResolutionLastFrame = iv2_free(projectedGridResolutionLastFrame);

    fplane_free(basePlane);

    [ super dealloc ];
}

- (NpState) mode
{
    return mode;
}

- (Float) basePlaneHeight
{
    return basePlaneHeight;
}

- (Float) upperSurfaceBound
{
    return upperSurfaceBound;
}

- (Float) lowerSurfaceBound
{
    return lowerSurfaceBound;
}

- (FPlane *) basePlane
{
    return basePlane;
}

- (IVector2) projectedGridResolution
{
    return *projectedGridResolution;
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

    IVector2 hack = { 4, 4 };
//    [ projectedGridCPU setProjectedGridResolution:hack ];

    *projectedGridResolution = hack;
    [ projectedGridCPU  setProjectedGridResolution:hack ];
    [ projectedGridR2VB setProjectedGridResolution:hack ];

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

- (void) update:(Float)frameTime
{
    if ( (projectedGridResolution->x != projectedGridResolutionLastFrame->x) ||
         (projectedGridResolution->y != projectedGridResolutionLastFrame->y) )
    {
        [ projectedGridCPU  setProjectedGridResolution:*projectedGridResolution ];
        [ projectedGridR2VB setProjectedGridResolution:*projectedGridResolution ];

        iv2_v_copy_v(projectedGridResolution, projectedGridResolutionLastFrame);
    }

    [ projectedGridCPU  update ];
    [ projectedGridR2VB update ];
}

/*- (void) renderStatic
{
    [ renderTargetConfiguration activate ];
    [ renderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ currentStaticTile texture ] activateAtColorMapIndex:0 ];

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

- (void) renderAnimated
{
    [ renderTargetConfiguration activate ];
    [ renderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

//    [[ currentAnimatedTile sliceAtIndex:2 ] activateAtColorMapIndex:0 ];
    [[ currentAnimatedTile texture3D ] activateAtVolumeMapIndex:0 ];

    ODProjector * projector = [[[[ NP applicationController ] sceneManager ] currentScene ] projector ];
    [ effect uploadFMatrix4Parameter:projectorIMVP andValue:[projector inverseViewProjection]];
    [ effect uploadFloatParameter:deltaTime andValue:periodTime/11.0f];
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

- (void) renderCPU
{
    [ renderTargetConfiguration activate ];
    [ renderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    //[ effect activateTechniqueWithName:@"ocean_cpu" ];
    [ projectedGridCPU render ];
    //[ effect deactivate ];

    [ renderTargetConfiguration deactivate ];
}*/

- (void) render
{
    //[[[[ NP Graphics ] stateConfiguration ] polygonFillState ] setFrontFaceFill:NP_POLYGON_FILL_LINE];
    //[[[[ NP Graphics ] stateConfiguration ] polygonFillState ] setBackFaceFill:NP_POLYGON_FILL_LINE];
    //[[[[ NP Graphics ] stateConfiguration ] polygonFillState ] activate ];

    [ projectedGridCPU render ];

    //[[[[ NP Graphics ] stateConfiguration ] polygonFillState ] setFrontFaceFill:NP_POLYGON_FILL_FACE];
    //[[[[ NP Graphics ] stateConfiguration ] polygonFillState ] setBackFaceFill:NP_POLYGON_FILL_FACE];
    //[[[[ NP Graphics ] stateConfiguration ] polygonFillState ] activate ];
}

@end
