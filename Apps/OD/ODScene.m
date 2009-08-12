#import "NP.h"
#import "ODCore.h"
#import "ODScene.h"
#import "ODCamera.h"
#import "ODProjector.h"
#import "ODSurface.h"
#import "ODEntity.h"
#import "ODOceanEntity.h"
#import "ODPreethamSkylight.h"
#import "ODEntityManager.h"
#import "ODSceneManager.h"
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

    camera    = [[ ODCamera    alloc ] initWithName:@"RenderingCamera" parent:self ];
    projector = [[ ODProjector alloc ] initWithName:@"Projector"       parent:self ];

    FVector3 pos = { 0.0f, 2.0f, 5.0f };

    [ camera setPosition:&pos ];

    pos.y = 5.0f;
    pos.z = 0.0f;

    [ projector setPosition:&pos ];
    [ projector cameraRotateUsingYaw:-0.0f andPitch:-90.0f ];
    //[ projector setRenderFrustum:YES ];

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

    luminanceMaxMipMapLevel = 1 + floor(log2(MAX(resolution->x, resolution->y)));
    referenceWhite = 2.5f;
    key = 1.0f;

    return self;
}

- (void) dealloc
{
    [ fullscreenQuad release ];

    [ menu      release ];
    [ projector release ];
    [ camera    release ];

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

    NSString * sceneName        = [ config objectForKey:@"Name"     ];
    NSArray  * entityFiles      = [ config objectForKey:@"Entities" ];
    NSString * skyboxEntityFile = [ config objectForKey:@"Skybox"   ];

    if ( sceneName == nil || entityFiles == nil || skyboxEntityFile == nil )
    {
        NPLOG_ERROR(@"Scene file %@ is incomplete", path);
        return NO;
    }

    [ self setName:sceneName ];

    skybox = [[[ NP applicationController ] entityManager ] loadEntityFromPath:skyboxEntityFile ];

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

- (void) update:(Float)frameTime
{
    [ camera update:frameTime ];
    [ projector update ];

    [ skybox update:frameTime ];

    NSEnumerator * entityEnumerator = [ entities objectEnumerator ];
    id entity;

    while ( (entity = [ entityEnumerator nextObject ]) )
    {
        [ entity update:frameTime ];
    }

    [ menu update:frameTime ];
}

- (void) render
{
    // clear framebuffer/depthbuffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // Set initial states
    [[[ NP Graphics ] stateConfiguration ] activate ];

    // Bind FBO and attach float color scene texture
    [ renderTargetConfiguration resetColorTargetsArray ];
    [[ renderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:sceneRenderTexture ];
    [ renderTargetConfiguration bindFBO ];
    [ sceneRenderTexture attachToColorBufferIndex:0 ];
    [ renderTargetConfiguration activateDrawBuffers ];
    [ renderTargetConfiguration activateViewport ];

    // Clear rendertexture(s)
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    // Render scene
    [ camera render ];
    [ projector render ];

    [ skybox render ];

    // Reset matrices (model, view, projection) to identity
    [[[[ NP Core ] transformationStateManager ] currentTransformationState ] reset ];

    // Detach float color scene texture, attach luminance float texture
    [[ renderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:luminanceRenderTexture ];
    [ luminanceRenderTexture attachToColorBufferIndex:0 ];
    [ renderTargetConfiguration activateDrawBuffers ];
    [ renderTargetConfiguration activateViewport ];

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

    [ fullscreenEffect deactivate ];

    // Activate blending for menu rendering
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setBlendingMode:NP_BLENDING_AVERAGE ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

    [[[ NP Graphics ] orthographicRendering ] activate ];
    [ menu render ];
    [[[ NP Graphics ] orthographicRendering ] deactivate ];

    // Reset states
    [[[ NP Graphics ] stateConfiguration ] deactivate ];
}

@end
