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

    fullscreenQuad = [[ NPFullscreenQuad alloc ] init ];
    fullscreenEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Fullscreen.cgfx" ];

    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    attractorRTC = [[ NPRenderTargetConfiguration alloc ] initWithName:@"AttractorRT" parent:self ];
    [ attractorRTC setWidth:resolution->x ];
    [ attractorRTC setHeight:resolution->y ];

    depthBuffer = [[ NPRenderBuffer renderBufferWithName:@"Depth"
                                                    type:NP_GRAPHICS_RENDERBUFFER_DEPTH_TYPE
                                                  format:NP_GRAPHICS_RENDERBUFFER_DEPTH24
                                                   width:resolution->x
                                                  height:resolution->y ] retain ];

    colorTargetOne = [[ NPRenderTexture renderTextureWithName:@"Color1"
                                                         type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                        width:resolution->x
                                                       height:resolution->y
                                                   dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE
                                                  pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ] retain ];

    colorTargetTwo = [[ NPRenderTexture renderTextureWithName:@"Color2"
                                                         type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                        width:resolution->x
                                                       height:resolution->y
                                                   dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE
                                                  pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ] retain ];

    return self;
}

- (void) dealloc
{
    RELEASE(colorTargetTwo);
    RELEASE(colorTargetOne);
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

    // setup fbo
    [ attractorRTC resetColorTargetsArray ];
    [ attractorRTC bindFBO ];

    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:colorTargetOne   ];
    [ colorTargetOne attachToColorBufferIndex:0 ];
    [ depthBuffer attach ];
    [ attractorRTC activateViewport ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    // clear colorTargetOne and depthBuffer
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
    [ attractor render ];

    // detach targets    
    [ colorTargetOne detach ];
    [ depthBuffer detach ];

    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] activate ];

    // prepare for horizontal filter
    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:colorTargetTwo   ];
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

    [ attractorRTC unbindFBO ];
    [ attractorRTC deactivateDrawBuffers ];
    [ attractorRTC deactivateViewport ];

    [[[ NP Core ] transformationState ] reset ];
    [[ colorTargetOne texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"fullscreen" ];

    [ fullscreenQuad render ];

    [ fullscreenEffect deactivate ];
}

@end
