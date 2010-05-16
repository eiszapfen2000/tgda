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

    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    attractorRTC = [[ NPRenderTargetConfiguration alloc ] initWithName:@"AttractorRT" parent:self ];

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
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [ attractorRTC resetColorTargetsArray ];
    [ attractorRTC bindFBO ];
    [ attractorRTC activateViewport ];

    [[ attractorRTC colorTargets ] replaceObjectAtIndex:0 withObject:colorTargetOne   ];
    [ colorTargetOne attachToColorBufferIndex:0 ];
    [ depthBuffer attach ];
    [ attractorRTC activateDrawBuffers ];
    [ attractorRTC checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setCullFace:NP_BACK_FACE ];
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:NO ];
    [[[ NP Graphics ] stateConfiguration ] activate ];

    [ camera render ];
    [ attractor render ];

    [ colorTargetOne detach ];
    [ depthBuffer detach ];
    [ attractorRTC unbindFBO ];
    [ attractorRTC deactivateDrawBuffers ];
    [ attractorRTC deactivateViewport ];

    [[[ NP Core ] transformationState ] reset ];
    [[ colorTargetOne texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"fullscreen" ];

        glBegin(GL_QUADS);
            glTexCoord2f(0.0f,1.0f);            
            glVertex4f(-1.0f,1.0f,0.0f,1.0f);

            glTexCoord2f(0.0f,0.0f);
            glVertex4f(-1.0f,-1.0,0.0f,1.0f);

            glTexCoord2f(1.0f,0.0f);
            glVertex4f(1.0f,-1.0f,0.0f,1.0f);

            glTexCoord2f(1.0f,1.0f);
            glVertex4f(1.0f,1.0f,0.0f,1.0f);
        glEnd();

    [ fullscreenEffect deactivate ];
}

@end
