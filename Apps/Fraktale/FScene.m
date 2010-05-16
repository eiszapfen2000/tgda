#import "NP.h"
#import "FCore.h"
#import "FScene.h"
#import "FSceneManager.h"
#import "FCamera.h"
#import "FAttractor.h"
#import "FTerrain.h"

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
    [ attractorRTC setWidth:resolution->x ];
    [ attractorRTC setHeight:resolution->y ];

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

    return self;
}

- (void) dealloc
{
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

- (FAttractor *) attractor
{
    return attractor;
}

- (FTerrain *) terrain
{
    return terrain;
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * sceneConfig = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSDictionary * terrainConfig   = [ sceneConfig objectForKey:@"Terrain"   ];
    NSDictionary * attractorConfig = [ sceneConfig objectForKey:@"Attractor" ];

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

    return YES;
}

- (void) activate
{
    [[[ NP applicationController ] sceneManager ] setCurrentScene:self ];

    camera = [[ FCamera alloc ] initWithName:@"Camera" parent:self ];

    FVector3 pos = { 0.0f, 0.2f, 0.0f };
    [ camera setPosition:&pos ];
    //[ camera cameraRotateUsingYaw:90.0f andPitch:0.0f ];
}

- (void) deactivate
{
    [[[ NP applicationController ] sceneManager ] setCurrentScene:nil ];

    DESTROY(camera);
}

- (void) update:(Float)frameTime
{
    [ camera update:frameTime ];

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
    [ attractor render:YES ];

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
    [ attractorRTC setWidth:resolution->x / 2 ];
    [ attractorRTC setHeight:resolution->y / 2 ];

    // prepare colorTargetOne
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:colorTargetOne ];
    [ colorTargetOne attachToColorBufferIndex:0 ];
    [ attractorRTC activateViewport ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // extract values of interest into bloom colorTargetOne
    [[ originalScene texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect uploadFloatParameter:bloomThresholdParameter andValue:0.75f ];
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

    [[ originalScene texture  ] activateAtColorMapIndex:0 ];
    [[ colorTargetOne texture ] activateAtColorMapIndex:1 ];
    [ fullscreenEffect uploadFloatParameter:bloomIntensityParameter andValue:1.25f ];
    [ fullscreenEffect uploadFloatParameter:bloomSaturationParameter andValue:1.0f ];
    [ fullscreenEffect uploadFloatParameter:sceneIntensityParameter andValue:1.0f ];
    [ fullscreenEffect uploadFloatParameter:sceneSaturationParameter andValue:1.0f ];
    [ fullscreenEffect activateTechniqueWithName:@"combine" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];


    /*
    // setup colorTargetOne, we draw the attractor to this target and blur the resulting image
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:colorTargetOne ];
    [ colorTargetOne attachToColorBufferIndex:0 ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];
    [ attractor render:NO ];
    [ colorTargetOne detach ];

    // prepare for horizontal filter
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:colorTargetTwo ];
    [ colorTargetTwo attachToColorBufferIndex:0 ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // reset  matrices, bind colorTargetOne, activate horizontalbloom
    [[[ NP Core ] transformationState ] reset ];
    [[ colorTargetOne texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"horizontalbloom" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
    [ colorTargetTwo detach ];

    // prepare for vertical filter
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:colorTargetOne   ];
    [ colorTargetOne attachToColorBufferIndex:0 ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // bind colorTargetTwo, activate horizontalbloom
    [[ colorTargetTwo texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"horizontalbloom" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
    [ colorTargetOne detach ];

    // deactivate render targets
    [ attractorRTC unbindFBO ];
    [ attractorRTC deactivateDrawBuffers ];
    [ attractorRTC deactivateViewport ];

    // draw originalScene and colorTargetOne blent on top of it
    [[[ NP Core ] transformationState ] reset ];
    [[ originalScene texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"fullscreen" ];
    [ fullscreenQuad render ];

    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setBlendingMode:NP_BLENDING_AVERAGE ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

    [[ colorTargetOne texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"fullscreen" ];
    [ fullscreenQuad render ];

    [ fullscreenEffect deactivate ];
    */
}

@end
