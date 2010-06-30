#import "NP.h"
#import "Core/Utilities/NPStringList.h"
#import "Core/Utilities/NPParser.h"
#import "FCore.h"
#import "FScene.h"
#import "FCamera.h"
#import "FAttractor.h"
#import "FTerrain.h"
#import "FPreethamSkylight.h"

@implementation FScene

- (id) init
{
    return [ self initWithName:@"Scene" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    activeScene = NP_NONE;
    fullscreenQuad = [[ NPFullscreenQuad alloc ] init ];

    fullscreenEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Fullscreen.cgfx" ];
    bloomThresholdParameter  = [ fullscreenEffect parameterWithName:@"bloomThreshold"  ];
    bloomIntensityParameter  = [ fullscreenEffect parameterWithName:@"bloomIntensity"  ];
    bloomSaturationParameter = [ fullscreenEffect parameterWithName:@"bloomSaturation" ];
    sceneIntensityParameter  = [ fullscreenEffect parameterWithName:@"sceneIntensity"  ];
    sceneSaturationParameter = [ fullscreenEffect parameterWithName:@"sceneSaturation" ];
    toneMappingParameters    = [ fullscreenEffect parameterWithName:@"toneMappingParameters" ];

    NSAssert(bloomThresholdParameter  != NULL && bloomIntensityParameter != NULL &&
             bloomSaturationParameter != NULL && sceneIntensityParameter != NULL &&
             sceneSaturationParameter != NULL && toneMappingParameters != NULL,
             @"Parameters not found");


    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    // Initialise bloom parameters
    bloomThreshold  = 0.75f;
    bloomIntensity  = 1.25f;
    bloomSaturation = 2.00f;
    sceneIntensity  = 1.00f;
    sceneSaturation = 1.00f;

    // Initialise tonemapping parameters
    luminanceMaxMipMapLevel = floor(logb(MAX(resolution->x, resolution->y)));
    referenceWhite = 0.85f;
    key = 0.38f;
    adaptationTimeScale = 30.0f;
    lastFrameLuminance = currentFrameLuminance = 1.0f;

    // render target configurations
    attractorRTC = [[ NPRenderTargetConfiguration alloc ] initWithName:@"AttractorRT" parent:self ];
    terrainRTC = [[ NPRenderTargetConfiguration alloc ] initWithName:@"TerrainRT" parent:self ];

    depthBuffer = [[ NPRenderBuffer renderBufferWithName:@"Depth"
                                                    type:NP_GRAPHICS_RENDERBUFFER_DEPTH_TYPE
                                                  format:NP_GRAPHICS_RENDERBUFFER_DEPTH24
                                                   width:resolution->x
                                                  height:resolution->y ] retain ];

    attractorScene = [[ NPRenderTexture renderTextureWithName:@"AttractorScene"
                                                        type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                       width:resolution->x
                                                      height:resolution->y
                                                  dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE
                                                 pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ] retain ];


    bloomTargetOne = [[ NPRenderTexture renderTextureWithName:@"Bloom1"
                                                         type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                        width:resolution->x / 2
                                                       height:resolution->y / 2
                                                   dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE
                                                  pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ] retain ];

    bloomTargetTwo = [[ NPRenderTexture renderTextureWithName:@"Bloom2"
                                                         type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                        width:resolution->x / 2
                                                       height:resolution->y / 2
                                                   dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE
                                                  pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ] retain ];

    terrainScene = [[ NPRenderTexture renderTextureWithName:@"TerrainScene"
                                                        type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                       width:resolution->x
                                                      height:resolution->y
                                                  dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_HALF
                                                 pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ] retain ];

    luminanceTarget = [[ NPRenderTexture renderTextureWithName:@"LuminanceRT"
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
    TEST_RELEASE(attractorMenu);
    TEST_RELEASE(terrainMenu);

    TEST_RELEASE(skylight);
    TEST_RELEASE(camera);

    RELEASE(luminanceTarget);
    RELEASE(bloomTargetTwo);
    RELEASE(bloomTargetOne);
    RELEASE(attractorScene);
    RELEASE(terrainScene);
    RELEASE(depthBuffer);

    [ attractorRTC clear ];
    [ terrainRTC clear ];
    RELEASE(attractorRTC);
    RELEASE(terrainRTC);

    RELEASE(fullscreenQuad);

    TEST_RELEASE(attractor);
    TEST_RELEASE(terrain);

    [ super dealloc ];
}

- (FCamera *) camera
{
    return camera;
}

- (FAttractor *) attractor
{
    return attractor;
}

- (FTerrain *) terrain
{
    return terrain;
}

- (FPreethamSkylight *) skylight
{
    return skylight;
}

- (NpState) activeScene
{
    return activeScene;
}

- (void) setActiveScene:(NpState)newActiveScene
{
    activeScene = newActiveScene;
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * sceneConfig = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSDictionary * terrainConfig   = [ sceneConfig objectForKey:@"Terrain"   ];
    NSDictionary * attractorConfig = [ sceneConfig objectForKey:@"Attractor" ];
    NSDictionary * bloomConfig     = [ sceneConfig objectForKey:@"Bloom"     ];

    camera = [[ FCamera alloc ] initWithName:@"Camera" parent:self ];
    skylight = [[ FPreethamSkylight alloc ] initWithName:@"Skylight" parent:self ];

    terrain   = [[ FTerrain   alloc ] init ];
    attractor = [[ FAttractor alloc ] init ];

    if ( [ terrain loadFromDictionary:terrainConfig ] == NO )
    {
        NPLOG_ERROR(@"Failed to load Terrain");
        return NO;
    }

    if ( [ attractor loadFromDictionary:attractorConfig ] == NO )
    {
        NPLOG_ERROR(@"Failed to load Attractor");
        return NO;
    }

    // Load bloom settings
    bloomThreshold  = [[ bloomConfig objectForKey:@"BloomThreshold"  ] floatValue ];
    bloomIntensity  = [[ bloomConfig objectForKey:@"BloomIntensity"  ] floatValue ];
    bloomSaturation = [[ bloomConfig objectForKey:@"BloomSaturation" ] floatValue ];
    sceneIntensity  = [[ bloomConfig objectForKey:@"SceneIntensity"  ] floatValue ];
    sceneSaturation = [[ bloomConfig objectForKey:@"SceneSaturation" ] floatValue ];

    // Load tonemapping settings
    // TODO

    attractorMenu = [[ FMenu alloc ] initWithName:@"Attractor Menu" parent:self ];
    terrainMenu = [[ FMenu alloc ] initWithName:@"Terrain Menu" parent:self ];

    if (([ attractorMenu loadFromPath:@"AttractorMenu.menu" ] == NO)
        || ([ terrainMenu loadFromPath:@"TerrainMenu.menu" ] == NO))
    {
        return NO;
    }

    return YES;
}

- (void) activate
{
    FVector3 pos = { 0.0f, 10.0f, 0.0f };
    [ camera setPosition:&pos ];
    [ camera cameraRotateUsingYaw:30.0f andPitch:0.0f ];
}

- (void) deactivate
{

}

- (void) update:(Float)frameTime
{
    [ camera update:frameTime ];
    [ skylight update:frameTime ];

    if ( terrain != nil )
    {
        [ terrain update:frameTime ];
    }

    if ( activeScene == FSCENE_DRAW_ATTRACTOR )
    {
        [ attractorMenu update:frameTime ];
    }

    if ( activeScene == FSCENE_DRAW_TERRAIN )
    {
        [ terrainMenu update:frameTime ];
    }
}

- (void) renderAttractorScene
{
    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    // setup fbo
    [ attractorRTC setWidth:resolution->x ];
    [ attractorRTC setHeight:resolution->y ];
    [ attractorRTC resetColorTargetsArray ];
    [ attractorRTC bindFBO ];

    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:attractorScene   ];
    [ attractorScene attachToColorBufferIndex:0 ];
    [ depthBuffer attach ];
    [ attractorRTC activateViewport ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // clear attractorScene and depthBuffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // initialise state
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setCullFace:NP_BACK_FACE ];
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:NO ];
    [[[ NP Graphics ] stateConfiguration ] activate ];

    // render scene
    [ camera render ];
    [ attractor render:YES ];

    // detach targets    
    [ attractorScene detach ];
    [ depthBuffer detach ];

    // deactivate depth test
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] activate ];

    // reset matrices
    [[[ NP Core ] transformationState ] reset ];

    // set reolution to actual renderexture size
    [ attractorRTC setWidth :resolution->x / 2 ];
    [ attractorRTC setHeight:resolution->y / 2 ];

    // prepare bloomTargetOne
    [[ bloomTargetOne texture ] setTextureFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:bloomTargetOne ];
    [ bloomTargetOne attachToColorBufferIndex:0 ];
    [ attractorRTC activateViewport ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // extract values of interest into bloom bloomTargetOne
    [[ attractorScene texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect uploadFloatParameter:bloomThresholdParameter andValue:bloomThreshold ];
    [ fullscreenEffect activateTechniqueWithName:@"bloomextract" ];
    [ fullscreenQuad render ];
    [ bloomTargetOne detach ];

    // prepare bloomTargetTwo
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:bloomTargetTwo ];
    [ bloomTargetTwo attachToColorBufferIndex:0 ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // horizontal filter
    [[ bloomTargetOne texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"horizontalbloom" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
    [ bloomTargetTwo detach ];

    // prepare bloomTargetOne
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:bloomTargetOne ];
    [ bloomTargetOne attachToColorBufferIndex:0 ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // vertical filter
    [[ bloomTargetTwo texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"verticalbloom" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
    [ bloomTargetOne detach ];

    // deactivate render targets
    [ attractorRTC unbindFBO ];
    [ attractorRTC deactivateDrawBuffers ];
    [ attractorRTC deactivateViewport ];

    // render combined scene
    [[ attractorScene texture  ] activateAtColorMapIndex:0 ];
    [[ bloomTargetOne texture ] setTextureFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
    [[ bloomTargetOne texture ] activateAtColorMapIndex:1 ];
    [ fullscreenEffect uploadFloatParameter:bloomIntensityParameter  andValue:bloomIntensity  ];
    [ fullscreenEffect uploadFloatParameter:bloomSaturationParameter andValue:bloomSaturation ];
    [ fullscreenEffect uploadFloatParameter:sceneIntensityParameter  andValue:sceneIntensity  ];
    [ fullscreenEffect uploadFloatParameter:sceneSaturationParameter andValue:sceneSaturation ];
    [ fullscreenEffect activateTechniqueWithName:@"combine" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
}

- (void) renderTerrainScene
{
    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    // setup fbo
    [ terrainRTC setWidth:resolution->x ];
    [ terrainRTC setHeight:resolution->y ];
    [ terrainRTC resetColorTargetsArray ];
    [ terrainRTC bindFBO ];

    // setup terrainScene as target
    [[ terrainRTC colorTargets ] replaceObjectAtIndex:0 withObject:terrainScene ];
    [ terrainScene attachToColorBufferIndex:0 ];
    [ depthBuffer attach ];
    [ terrainRTC activateViewport ];
    [ terrainRTC activateDrawBuffers ];
    [ terrainRTC checkFrameBufferCompleteness ];

    // clear terrainScene and depthBuffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [ camera render ];
    [ skylight render ];

    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setCullFace:NP_BACK_FACE ];
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:NO ];
    [[[ NP Graphics ] stateConfiguration ] activate ];

    [ terrain render ];

    // detach targets    
    [ terrainScene detach ];
    [ depthBuffer detach ];

    // deactivate depth test
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] activate ];

    // reset matrices
    [[[ NP Core ] transformationState ] reset ];

    // prepare luminanceTarget
    [[ terrainRTC colorTargets ] replaceObjectAtIndex:0 withObject:luminanceTarget ];
    [ luminanceTarget attachToColorBufferIndex:0 ];
    [ terrainRTC activateViewport ];
    [ terrainRTC activateDrawBuffers ];
    [ terrainRTC checkFrameBufferCompleteness ];

    // compute terrainScene's luminance into luminanceTarget
    [[ terrainScene texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"luminance" ];
    [ fullscreenQuad render ];
    [ luminanceTarget detach ];

    // deactivate render targets
    [ terrainRTC unbindFBO ];
    [ terrainRTC deactivateDrawBuffers ];
    [ terrainRTC deactivateViewport ];

    // Generate mipmaps for luminance texture, since we want only the highest mipmaplevel
    // as an approximation to the average luminance of the scene
    [ luminanceTarget generateMipMaps ];

    Half * averageLuminance;
    Int32 numberOfElements = [[ luminanceTarget texture ] downloadMaxMipmapLevelIntoHalfs:&averageLuminance ];
    NSAssert(averageLuminance != NULL && numberOfElements != 0, @"Failed to read average luminance back to memory.");

    lastFrameLuminance = currentFrameLuminance;
    Float currentFrameAverageLuminance = exp(half_to_float(averageLuminance[0]));
    Double frameTime = [[[ NP Core ] timer ] frameTime ];

    currentFrameLuminance = lastFrameLuminance + (currentFrameAverageLuminance - lastFrameLuminance)
         * (Float)(1.0 - pow(0.9, adaptationTimeScale * frameTime));

    FREE(averageLuminance);

    // Bind scene and luminance texture, and do tonemapping
    [[ terrainScene texture ] activateAtColorMapIndex:0 ];

    FVector3 toneMappingParameterVector = { (Float)currentFrameLuminance, referenceWhite, key };
    [ fullscreenEffect uploadFVector3Parameter:toneMappingParameters andValue:&toneMappingParameterVector ];
    [ fullscreenEffect activateTechniqueWithName:@"tonemap" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
}

- (void) renderMenu:(FMenu *)menu
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
    // Clear back buffer and depth buffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    if ( activeScene == FSCENE_DRAW_ATTRACTOR )
    {
        [ self renderAttractorScene ];
        [ self renderMenu:attractorMenu ];
    }

    if ( activeScene == FSCENE_DRAW_TERRAIN )
    {
        [ self renderTerrainScene ];
        [ self renderMenu:terrainMenu ];
    }
}

@end
