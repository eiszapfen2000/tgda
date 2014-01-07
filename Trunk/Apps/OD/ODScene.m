#import "NP.h"
#import "ODCore.h"
#import "ODScene.h"
#import "ODSceneManager.h"

#import "Entities/ODCamera.h"
#import "Entities/ODProjector.h"
#import "Entities/ODEntity.h"
#import "Entities/ODPreethamSkylight.h"
#import "Entities/ODEntityManager.h"
#import "Menu/ODMenu.h"

@implementation ODScene

- (id) init
{
    return [ self initWithName:@"ODScene" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    entities = [[ NSMutableArray alloc ] init ];
    fullscreenQuad = [[ NPFullscreenQuad alloc ] init ];
    fullscreenEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Fullscreen.cgfx" ];

    toneMappingParameters = [ fullscreenEffect parameterWithName:@"toneMappingParameters" ];
    NSAssert(toneMappingParameters != NULL, @"Parameter \"toneMappingParameters\" not found");

    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    // Initialise tonemapping parameters
    luminanceMaxMipMapLevel = floor(logb(MAX(resolution->x, resolution->y)));
    referenceWhite = 0.85f;
    key = 0.38f;
    adaptationTimeScale = 30.0f;
    lastFrameLuminance = currentFrameLuminance = 1.0f;

    // render target configurations
    sceneRTC = [[ NPRenderTargetConfiguration alloc ] initWithName:@"SceneRTC" parent:self ];

    depthRB = [[ NPRenderBuffer renderBufferWithName:@"DepthRB"
                                                type:NP_GRAPHICS_RENDERBUFFER_DEPTH_TYPE
                                              format:NP_GRAPHICS_RENDERBUFFER_DEPTH24
                                               width:resolution->x
                                              height:resolution->y ] retain ];

    sceneRT = [[ NPRenderTexture renderTextureWithName:@"SceneRT"
                                                  type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                 width:resolution->x
                                                height:resolution->y
                                            dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_HALF
                                           pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ] retain ];

    luminanceRT = [[ NPRenderTexture renderTextureWithName:@"LuminanceRT"
                                                      type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                     width:resolution->x
                                                    height:resolution->y
                                                dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_HALF
                                               pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_R
                                             textureFilter:NP_GRAPHICS_TEXTURE_FILTER_TRILINEAR
                                               textureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ] retain ];

    return self;
}

- (void) dealloc
{
    RELEASE(menu);

    [ entities removeAllObjects ];
    RELEASE(entities);

    RELEASE(luminanceRT);
    RELEASE(sceneRT);
    RELEASE(depthRB);

    [ sceneRTC clear ];
    RELEASE(sceneRTC);

    RELEASE(fullscreenQuad);

    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * config = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSString * sceneName           = [ config objectForKey:@"Name" ];
    NSString * skylightEntityFile  = [ config objectForKey:@"Skylight" ];
    NSString * cameraEntityFile    = [ config objectForKey:@"Camera" ];
    NSString * projectorEntityFile = [ config objectForKey:@"Projector" ];
    NSArray  * entityFiles         = [ config objectForKey:@"Entities" ];

    if ( sceneName == nil || entityFiles == nil || skylightEntityFile == nil ||
         cameraEntityFile == nil || projectorEntityFile == nil )
    {
        NPLOG_ERROR(@"Scene file %@ is incomplete", path);
        return NO;
    }

    [ self setName:sceneName ];

    skylight  = [[[ NP applicationController ] entityManager ] loadEntityFromPath:skylightEntityFile ];
    camera    = [[[ NP applicationController ] entityManager ] loadEntityFromPath:cameraEntityFile ];
    projector = [[[ NP applicationController ] entityManager ] loadEntityFromPath:projectorEntityFile ];

    menu = [[ ODMenu alloc ] initWithName:@"Menu" parent:self ];
    if ( [ menu loadFromPath:@"Menu.menu" ] == NO )
    {
        return NO;
    }

    return YES;
}

- (void) activate
{
    [ (ODSceneManager *)parent setCurrentScene:self ];
}

- (void) deactivate
{
    [ (ODSceneManager *)parent setCurrentScene:nil ];
}

- (ODCamera *) camera
{
    return camera;
}

- (ODProjector *) projector
{
    return projector;
}

- (id) entityWithName:(NSString *)entityName
{
    NSEnumerator * entitiesEnumerator = [ entities objectEnumerator ];
    id entity;

    while ( (entity = [ entitiesEnumerator nextObject ]) )
    {
        if ( [[ entity name ] isEqual:entityName ] == YES )
        {
            return entity;
        }
    }

    return nil;
}

- (void) update:(Float)frameTime
{
    [ camera    update:frameTime ];
    [ projector update:frameTime ];
    [ skylight  update:frameTime ];

    NSEnumerator * entityEnumerator = [ entities objectEnumerator ];
    id <ODPEntity> entity;

    while ( (entity = [ entityEnumerator nextObject ]) )
    {
        [ entity update:frameTime ];
    }

    [ menu update:frameTime ];
}

- (void) renderScene
{
    // clear terrainScene and depthBuffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // Render scene
    [[[ NP Core ] transformationState ] reset ];
    [ camera render ];
    [ skylight render ];

    NSEnumerator * entityEnumerator = [ entities objectEnumerator ];
    id <ODPEntity> entity;

    while ( (entity = [ entityEnumerator nextObject ]) )
    {
        [ entity render ];
    }

    [ projector render ];
}

- (void) renderMenu
{
    // Activate blending for menu rendering
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setBlendingMode:NP_BLENDING_AVERAGE ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] activate ];

    // Render menu
    [[[ NP Graphics ] orthographicRendering ] activate ];
    [ menu render ];
    [[[ NP Graphics ] orthographicRendering ] deactivate ];
}



- (void) render
{
    // Set initial states
    [ defaultStateSet activate ];

    // Clear back buffer and depth buffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    // setup fbo
    [ sceneRTC setWidth:resolution->x ];
    [ sceneRTC setHeight:resolution->y ];
    [ sceneRTC resetColorTargetsArray ];
    [ sceneRTC bindFBO ];

    // setup sceneRT as render target
    [[ sceneRTC colorTargets ] replaceObjectAtIndex:0 withObject:sceneRT ];
    [ sceneRT attachToColorBufferIndex:0 ];
    [ depthRB attach ];
    [ sceneRTC activateViewport ];
    [ sceneRTC activateDrawBuffers ];
    [ sceneRTC checkFrameBufferCompleteness ];

    // clears framebuffer and depthbuffer, renders camera, skylight, all entities
    // and the projector
    [ self renderScene ];

    [ sceneRT detach ];
    [ depthRB detach ];

    // deactivate depth write since we will not attach a depth target
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] activate ];

    // reset matrices
    [[[ NP Core ] transformationState ] reset ];

    // prepare luminanceRT
    [[ sceneRTC colorTargets ] replaceObjectAtIndex:0 withObject:luminanceRT ];
    [ luminanceRT attachToColorBufferIndex:0 ];
    [ sceneRTC activateViewport ];
    [ sceneRTC activateDrawBuffers ];
    [ sceneRTC checkFrameBufferCompleteness ];

    // compute sceneRT's luminance into luminanceRT
    [[ sceneRT texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"luminance" ];
    [ fullscreenQuad render ];
    [ luminanceRT detach ];

    // deactivate render targets
    [ sceneRTC unbindFBO ];
    [ sceneRTC deactivateDrawBuffers ];
    [ sceneRTC deactivateViewport ];

    // Generate mipmaps for luminance texture, since we want only the highest mipmaplevel
    // as an approximation to the average luminance of the scene
    [ luminanceRT generateMipMaps ];

    Half * averageLuminance;
    Int32 numberOfElements = [[ luminanceRT texture ] downloadMaxMipmapLevelIntoHalfs:&averageLuminance ];
    NSAssert(averageLuminance != NULL && numberOfElements != 0, @"Failed to read average luminance back to memory.");

    lastFrameLuminance = currentFrameLuminance;
    Float currentFrameAverageLuminance = exp(half_to_float(averageLuminance[0]));
    Double frameTime = [[[ NP Core ] timer ] frameTime ];

    currentFrameLuminance = lastFrameLuminance + (currentFrameAverageLuminance - lastFrameLuminance)
         * (Float)(1.0 - pow(0.9, adaptationTimeScale * frameTime));

    FREE(averageLuminance);

    // Bind scene texture, and do tonemapping
    [[ sceneRT texture ] activateAtColorMapIndex:0 ];

    FVector3 toneMappingParameterVector = { (Float)currentFrameLuminance, referenceWhite, key };
    [ fullscreenEffect uploadFVector3Parameter:toneMappingParameters andValue:&toneMappingParameterVector ];
    [ fullscreenEffect activateTechniqueWithName:@"tonemap" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];

    // render menu
    [ self renderMenu ];

    // Reset states
    [[[ NP Graphics ] stateConfiguration ] deactivate ];
}

@end
