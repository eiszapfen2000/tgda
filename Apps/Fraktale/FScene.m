#import "NP.h"
#import "Core/Utilities/NPStringList.h"
#import "Core/Utilities/NPParser.h"
#import "FCore.h"
#import "FScene.h"
#import "FCamera.h"
#import "FAttractor.h"
#import "FTerrain.h"
#import "FPreethamSkylight.h"

void fbloomsettings_init(FBloomSettings * bloomSettings)
{
    bloomSettings->bloomThreshold  = 0.75f;
    bloomSettings->bloomIntensity  = 1.25f;
    bloomSettings->bloomSaturation = 2.00f;
    bloomSettings->sceneIntensity  = 1.00f;
    bloomSettings->sceneSaturation = 1.00f;    
}

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

    fbloomsettings_init(&bloomSettings);

    activeScene = NP_NONE;

    fullscreenEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Fullscreen.cgfx" ];
    bloomThresholdParameter  = [ fullscreenEffect parameterWithName:@"bloomThreshold"  ];
    bloomIntensityParameter  = [ fullscreenEffect parameterWithName:@"bloomIntensity"  ];
    bloomSaturationParameter = [ fullscreenEffect parameterWithName:@"bloomSaturation" ];
    sceneIntensityParameter  = [ fullscreenEffect parameterWithName:@"sceneIntensity"  ];
    sceneSaturationParameter = [ fullscreenEffect parameterWithName:@"sceneSaturation" ];

    NSAssert(bloomThresholdParameter  != NULL && bloomIntensityParameter != NULL &&
             bloomSaturationParameter != NULL && sceneIntensityParameter != NULL &&
             sceneSaturationParameter != NULL, @"Parameters not found");


    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    attractorRTC = [[ NPRenderTargetConfiguration alloc ] initWithName:@"AttractorRT" parent:self ];

    depthBuffer = [[ NPRenderBuffer renderBufferWithName:@"Depth"
                                                    type:NP_GRAPHICS_RENDERBUFFER_DEPTH_TYPE
                                                  format:NP_GRAPHICS_RENDERBUFFER_DEPTH24
                                                   width:resolution->x
                                                  height:resolution->y ] retain ];

    originalScene = [[ NPRenderTexture renderTextureWithName:@"Original"
                                                        type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                       width:resolution->x
                                                      height:resolution->y
                                                  dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE
                                                 pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ] retain ];


    colorTargetOne = [[ NPRenderTexture renderTextureWithName:@"Color1"
                                                         type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                        width:resolution->x / 2
                                                       height:resolution->y / 2
                                                   dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE
                                                  pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ] retain ];

    colorTargetTwo = [[ NPRenderTexture renderTextureWithName:@"Color2"
                                                         type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                        width:resolution->x / 2
                                                       height:resolution->y / 2
                                                   dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE
                                                  pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ] retain ];

    fullscreenQuad = [[ NPFullscreenQuad alloc ] init ];

    model = [[[ NP Graphics ] modelManager ] loadModelFromPath:@"camera.model" ];
    [ model uploadToGL ];

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(skylight);
    TEST_RELEASE(camera);

    RELEASE(colorTargetTwo);
    RELEASE(colorTargetOne);
    RELEASE(originalScene);
    RELEASE(depthBuffer);

    [ attractorRTC clear ];
    RELEASE(attractorRTC);

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

    bloomSettings.bloomThreshold  = [[ bloomConfig objectForKey:@"BloomThreshold"  ] floatValue ];
    bloomSettings.bloomIntensity  = [[ bloomConfig objectForKey:@"BloomIntensity"  ] floatValue ];
    bloomSettings.bloomSaturation = [[ bloomConfig objectForKey:@"BloomSaturation" ] floatValue ];
    bloomSettings.sceneIntensity  = [[ bloomConfig objectForKey:@"SceneIntensity"  ] floatValue ];
    bloomSettings.sceneSaturation = [[ bloomConfig objectForKey:@"SceneSaturation" ] floatValue ];

    return YES;
}

- (void) activate
{
    FVector3 pos = { 0.0f, 0.2f, 0.0f };
    [ camera setPosition:&pos ];
    //[ camera cameraRotateUsingYaw:90.0f andPitch:0.0f ];
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
}

- (void) render
{
    // Clear back buffer and depth buffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    // setup fbo
    [ attractorRTC setWidth:resolution->x ];
    [ attractorRTC setHeight:resolution->y ];
    [ attractorRTC resetColorTargetsArray ];
    [ attractorRTC bindFBO ];

    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:originalScene   ];
    [ originalScene attachToColorBufferIndex:0 ];
    [ depthBuffer attach ];
    [ attractorRTC activateViewport ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // clear originalScene and depthBuffer
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

    if ( activeScene == FSCENE_DRAW_ATTRACTOR )
    {
        [ attractor render:YES ];
        [ model render ];
    }

    if ( activeScene == FSCENE_DRAW_TERRAIN )
    {
        [ skylight render ];
        [ terrain render ];
        //[ model render ];
    }

    // detach targets    
    [ originalScene detach ];
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

    // prepare colorTargetOne
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:colorTargetOne ];
    [ colorTargetOne attachToColorBufferIndex:0 ];
    [ attractorRTC activateViewport ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // extract values of interest into bloom colorTargetOne
    [[ originalScene texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect uploadFloatParameter:bloomThresholdParameter andValue:bloomSettings.bloomThreshold ];
    [ fullscreenEffect activateTechniqueWithName:@"bloomextract" ];
    [ fullscreenQuad render ];
    [ colorTargetOne detach ];

    // prepare colorTargetTwo
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:colorTargetTwo ];
    [ colorTargetTwo attachToColorBufferIndex:0 ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // horizontal filter
    [[ colorTargetOne texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"horizontalbloom" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
    [ colorTargetTwo detach ];

    // prepare colorTargetOne
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:colorTargetOne ];
    [ colorTargetOne attachToColorBufferIndex:0 ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // vertical filter
    [[ colorTargetTwo texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"verticalbloom" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
    [ colorTargetOne detach ];

    // deactivate render targets
    [ attractorRTC unbindFBO ];
    [ attractorRTC deactivateDrawBuffers ];
    [ attractorRTC deactivateViewport ];

    // render combined scene
    [[ originalScene texture  ] activateAtColorMapIndex:0 ];
    [[ colorTargetOne texture ] activateAtColorMapIndex:1 ];
    [ fullscreenEffect uploadFloatParameter:bloomIntensityParameter  andValue:bloomSettings.bloomIntensity  ];
    [ fullscreenEffect uploadFloatParameter:bloomSaturationParameter andValue:bloomSettings.bloomSaturation ];
    [ fullscreenEffect uploadFloatParameter:sceneIntensityParameter  andValue:bloomSettings.sceneIntensity  ];
    [ fullscreenEffect uploadFloatParameter:sceneSaturationParameter andValue:bloomSettings.sceneSaturation ];
    [ fullscreenEffect activateTechniqueWithName:@"combine" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
}

@end
