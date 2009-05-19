#import "NP.h"
#import "RTVCore.h"
#import "RTVSceneManager.h"
#import "RTVAdvection.h"
#import "RTVDiffusion.h"
#import "RTVInputForce.h"
#import "RTVScene.h"

@implementation RTVScene

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

    IVector2 * v = [[[[ NP Graphics ] viewportManager ] currentViewport ] viewportSize ];

    id componentOne = [ NPRenderTexture renderTextureWithName:@"ComponentOne"
                                                        type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                       width:v->x
                                                      height:v->y
                                                  dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                 pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                            textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                            textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id componentTwo = [ NPRenderTexture renderTextureWithName:@"ComponentTwo"
                                                         type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                        width:v->x
                                                       height:v->y
                                                   dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                  pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                             textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                             textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                 textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                 textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    componentSource = [ componentOne retain ];
    componentTarget = [ componentTwo retain ];

    return self;
}

- (void) dealloc
{
    [ componentSource release ];
    [ componentTarget release ];

    [ super dealloc ];
}

- (id) advection
{
    return advection;
}

- (id) inputForce
{
    return inputForce;
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * sceneConfig = [ NSDictionary dictionaryWithContentsOfFile:path ];

    return YES;
}

- (void) activate
{
    [[[ NP applicationController ] sceneManager ] setCurrentScene:self ];

    advection  = [[ RTVAdvection  alloc ] initWithName:@"Advection"  parent:self ];
    diffusion  = [[ RTVDiffusion  alloc ] initWithName:@"Diffusion"  parent:self ];
    inputForce = [[ RTVInputForce alloc ] initWithName:@"InputForce" parent:self ];
}

- (void) deactivate
{
    DESTROY(inputForce);
    DESTROY(diffusion);
    DESTROY(advection);

    [[[ NP applicationController ] sceneManager ] setCurrentScene:nil ];
}

- (void) update:(Float)frameTime
{
    [ advection advectQuantityFrom :componentSource to:componentTarget ];
    [ diffusion diffuseQuantityFrom:componentTarget to:componentSource ];
    //[ advection  update:frameTime ];
    //[ inputForce update:frameTime ];
}

- (void) render
{
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];
    [[[ NP Graphics ] stateConfiguration ] activate ];

    [[ componentSource texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activate ];

    glBegin(GL_QUADS);
        glTexCoord2f(0.0f,1.0f);            
        glVertex4f(-1.0f,1.0f,0.0f,1.0f);

        glTexCoord2f(0.0f,0.0f);
        glVertex4f(-1.0f,-1.0f,0.0f,1.0f);

        glTexCoord2f(1.0f,0.0f);
        glVertex4f(1.0f,-1.0f,0.0f,1.0f);

        glTexCoord2f(1.0f,1.0f);
        glVertex4f(1.0f,1.0f,0.0f,1.0f);
    glEnd();

    [ fullscreenEffect deactivate ];

    [[[ NP Graphics ] stateConfiguration ] deactivate ];

    NSLog(@"%d",[[[ NP Core ] timer ] fps ]);
}

@end
