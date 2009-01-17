#import "ODSceneManager.h"
#import "ODScene.h"
#import "NP.h"

@implementation ODSceneManager

- (id) init
{
    return [ self initWithName:@"ODSceneManager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    scenes = [[ NSMutableDictionary alloc ] init ];
    currentScene = nil;

    [ self createRenderTargets ];

    return self;
}

- (void) dealloc
{
    [ renderTargetConfiguration clear ];
    [ renderTargetConfiguration release ];

    TEST_RELEASE(currentScene);
    [ scenes removeAllObjects ];
    [ scenes release ];

    [ super dealloc ];
}

- (void) createRenderTargets
{
    IVector2 v = [[[[ NP Graphics ] viewportManager ] nativeViewport ] viewportSize ];

    NPRenderTexture * color = [ NPRenderTexture renderTextureWithName:@"Color"
                                                                 type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                           dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE
                                                          pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                                width:v.x
                                                               height:v.y ];

    NPRenderBuffer * depth = [ NPRenderBuffer renderBufferWithName:@"Depth"
                                                              type:NP_GRAPHICS_RENDERBUFFER_DEPTH_TYPE
                                                            format:NP_GRAPHICS_RENDERBUFFER_DEPTH24
                                                             width:v.x
                                                            height:v.y ];

    renderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC" parent:self ];
    [ renderTargetConfiguration setDepthRenderTarget:depth ];
    [ renderTargetConfiguration setColorRenderTarget:color atIndex:0 ];

    if ( [ renderTargetConfiguration checkFrameBufferCompleteness ] == NO )
    {
        NPLOG_ERROR(@"KABUMM");
    }

    pbo = [[[ NP Graphics ] pixelBufferManager ] createPBOCompatibleWithRenderTexture:color ];
    [ pbo uploadToGLWithoutData ];

}

- (id) loadSceneFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadSceneFromAbsolutePath:absolutePath ];   
}

- (id) loadSceneFromAbsolutePath:(NSString *)path
{
    NPLOG(([NSString stringWithFormat:@"%@: loading %@", name, path]));

    if ( [ path isEqual:@"" ] == NO )
    {
        id scene = [ scenes objectForKey:path ];

        if ( scene == nil )
        {
            scene = [[ ODScene alloc ] initWithName:@"" parent:self ];

            if ( [ scene loadFromPath:path ] == YES )
            {
                [ scenes setObject:scene forKey:path ];
                [ scene release ];

                return scene;
            }
            else
            {
                [ scene release ];

                return nil;
            }
        }

        return scene;
    }

    return nil;
}

- (id) currentScene
{
    return currentScene;
}

- (id) renderTargetConfiguration
{
    return renderTargetConfiguration;
}

- (id) pbo
{
    return pbo;
}

- (void) setCurrentScene:(id)newCurrentScene
{
    ASSIGN(currentScene,newCurrentScene);
}

- (void) update
{
    [ currentScene update ];
}

- (void) render
{
    [ currentScene render ];
}

@end
