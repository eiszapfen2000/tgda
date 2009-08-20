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

    fullscreenQuad = [[ NPFullscreenQuad alloc ] initWithName:@"Quad" parent:self ];

    fullscreenEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Fullscreen.cgfx" ];
    toneMappingParameters = [ fullscreenEffect parameterWithName:@"toneMappingParameters" ];
    NSAssert1(toneMappingParameters != NULL, @"%@ missing \"toneMappingParameters\"", [ fullscreenEffect name ]);

    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];
    renderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTConfig" parent:self ];
    [ renderTargetConfiguration setWidth:resolution->x ];
    [ renderTargetConfiguration setHeight:resolution->y ];


    sceneRenderTexture = [[ NPRenderTexture renderTextureWithName:@"SceneRT"
                                                             type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                            width:resolution->x
                                                           height:resolution->y
                                                       dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                      pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                    textureFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                      textureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ] retain ];

    luminanceRenderTexture = [[ NPRenderTexture renderTextureWithName:@"LuminanceRT"
                                                                 type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                width:resolution->x
                                                               height:resolution->y
                                                           dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                          pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_R
                                                        textureFilter:NP_GRAPHICS_TEXTURE_FILTER_TRILINEAR
                                                          textureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ] retain ];

    depthRenderBuffer = [[ NPRenderBuffer renderBufferWithName:@"DepthBuffer"
                                                          type:NP_GRAPHICS_RENDERBUFFER_DEPTH_TYPE
                                                        format:NP_GRAPHICS_RENDERBUFFER_DEPTH24
                                                         width:resolution->x
                                                        height:resolution->y ] retain ];

    [ depthRenderBuffer uploadToGL ];

    defaultStateSet = [[[ NP Graphics ] stateSetManager ] loadStateSetFromPath:@"default.stateset" ];

    luminanceMaxMipMapLevel = 1 + floor(log2(MAX(resolution->x, resolution->y)));
    referenceWhite = 2.5f;
    key = 1.0f;

    return self;
}

- (void) dealloc
{
    [ fullscreenQuad release ];

    [ menu release ];

    [ depthRenderBuffer      release ];
    [ sceneRenderTexture     release ];
    [ luminanceRenderTexture release ];

    [ renderTargetConfiguration resetColorTargetsArray ];
    [ renderTargetConfiguration clear ];
    [ renderTargetConfiguration release ];

    [ entities removeAllObjects ];
    [ entities release ];

    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * config = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSString * sceneName           = [ config objectForKey:@"Name" ];
    NSString * skyboxEntityFile    = [ config objectForKey:@"Skybox" ];
    NSString * cameraEntityFile    = [ config objectForKey:@"Camera" ];
    NSString * projectorEntityFile = [ config objectForKey:@"Projector" ];
    NSArray  * entityFiles         = [ config objectForKey:@"Entities" ];

    if ( sceneName == nil || entityFiles == nil || skyboxEntityFile == nil ||
         cameraEntityFile == nil || projectorEntityFile == nil )
    {
        NPLOG_ERROR(@"Scene file %@ is incomplete", path);
        return NO;
    }

    [ self setName:sceneName ];

    skybox    = [[[ NP applicationController ] entityManager ] loadEntityFromPath:skyboxEntityFile ];
    camera    = [[[ NP applicationController ] entityManager ] loadEntityFromPath:cameraEntityFile ];
    projector = [[[ NP applicationController ] entityManager ] loadEntityFromPath:projectorEntityFile ];

    //[ projector cameraRotateUsingYaw:-0.0f andPitch:-90.0f ];
    [ projector setRenderFrustum:YES ];

    NSEnumerator * entityFilesEnumerator = [ entityFiles objectEnumerator ];
    id entityFileName;

    while ( (entityFileName = [ entityFilesEnumerator nextObject ]) )
    {
        id entity = [[[ NP applicationController ] entityManager ] loadEntityFromPath:entityFileName ];

        if ( entity != nil )
        {
            [ entities addObject:entity ];
        }
    }

    font = [[[ NP Graphics ] fontManager ] loadFontFromPath:@"tahoma.font" ];

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

- (id) camera
{
    return camera;
}

- (id) projector
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

    [ skybox update:frameTime ];

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
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // Render scene
    [[[ NP Core ] transformationStateManager ] resetCurrentTransformationState ];
    [ camera render ];

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

    // clear framebuffer/depthbuffer
    //[[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [ self renderScene ];
    [ self renderMenu  ];


    // Bind FBO, attach float color scene texture and depth renderbuffer
    /*[ renderTargetConfiguration resetColorTargetsArray ];
    [[ renderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:sceneRenderTexture ];
    [ renderTargetConfiguration bindFBO ];
    [ sceneRenderTexture attachToColorBufferIndex:0 ];
    [ depthRenderBuffer attach ];
    [ renderTargetConfiguration activateDrawBuffers ];
    [ renderTargetConfiguration activateViewport ];

    [ renderTargetConfiguration checkFrameBufferCompleteness ];*/

    // Clear rendertexture(s)
//    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    /*
    // Detach float color scene texture and depth render buffer, attach luminance float texture
    [[ renderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:luminanceRenderTexture ];
    [ depthRenderBuffer detach ];
    [ luminanceRenderTexture attachToColorBufferIndex:0 ];
    [ renderTargetConfiguration activateDrawBuffers ];
    [ renderTargetConfiguration activateViewport ];

    [ renderTargetConfiguration checkFrameBufferCompleteness ];

    // Render to luminance texture, converting the source scene color to luminance
    // during the process
    [[ sceneRenderTexture texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"luminance" ];

    [ fullscreenQuad render ];

    [ fullscreenEffect deactivate ];

    // Deactivate FBO
    [ renderTargetConfiguration unbindFBO ];
    [ renderTargetConfiguration deactivateDrawBuffers ];
    [ renderTargetConfiguration deactivateViewport ];

    // Generate mipmaps for luminance texture, since we want only the highest mipmaplevel
    // as an approximation to the average luminance of the scene
    [ luminanceRenderTexture generateMipMaps ];

    // Bind scene and luminance texture, and do tonemapping
    [[ sceneRenderTexture     texture ] activateAtColorMapIndex:0 ];
    [[ luminanceRenderTexture texture ] activateAtColorMapIndex:1 ];

    FVector3 toneMappingParameterVector = { (Float)luminanceMaxMipMapLevel, referenceWhite, key };
    [ fullscreenEffect uploadFVector3Parameter:toneMappingParameters andValue:&toneMappingParameterVector ];
    [ fullscreenEffect activateTechniqueWithName:@"tonemap" ];

    [ fullscreenQuad render ];

    [ fullscreenEffect deactivate ];*/

    // Reset states
    [[[ NP Graphics ] stateConfiguration ] deactivate ];
}

@end
