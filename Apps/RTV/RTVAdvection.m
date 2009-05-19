#import "NP.h"
#import "RTVCore.h"
#import "RTVAdvection.h"

@implementation RTVAdvection

- (id) init
{
    return [ self initWithName:@"Advection" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    advectionEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Advection.cgfx" ];

    IVector2 * v = [[[[ NP Graphics ] viewportManager ] currentViewport ] viewportSize ];

    id velocityOneRenderTexture = [ NPRenderTexture renderTextureWithName:@"VelocityOne"
                                                                    type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                   width:v->x
                                                                  height:v->y
                                                              dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                             pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                        textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                        textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                            textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                            textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id velocityTwoRenderTexture = [ NPRenderTexture renderTextureWithName:@"VelocityTwo"
                                                                     type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                    width:v->x
                                                                   height:v->y
                                                               dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                              pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                         textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                         textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                             textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                             textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id tempRenderTexture = [ NPRenderTexture renderTextureWithName:@"Temp"
                                                              type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                             width:v->x
                                                            height:v->y
                                                        dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                       pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                  textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                  textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                      textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                      textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    velocitySource   = [ velocityOneRenderTexture retain ];
    velocityTarget   = [ velocityTwoRenderTexture retain ];
    temporaryStorage = [ tempRenderTexture        retain ];

    advectionRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"AdvectionRT" parent:self ];
    [ advectionRenderTargetConfiguration setWidth :v->x ];
    [ advectionRenderTargetConfiguration setHeight:v->y ];

    return self;
}

- (void) dealloc
{
    DESTROY(velocityTarget);
    DESTROY(temporaryStorage);

    [ velocitySource unbindFromRenderTargetConfiguration ];
    DESTROY(velocitySource);

    [ advectionRenderTargetConfiguration clear ];
    [ advectionRenderTargetConfiguration release ];

    [ super dealloc ];
}

- (id) velocitySource
{
    return velocitySource;
}

- (id) velocityTarget
{
    return velocityTarget;
}

- (id) advectionEffect
{
    return advectionEffect;
}

- (void) swapVelocityRenderTextures
{
    id tmp = velocityTarget;
    velocityTarget = velocitySource;
    velocitySource = tmp;
}

- (void) advectQuantityFrom:(id)quantitySource to:(id)quantityTarget
{
    #warning "Timestep missing"

    IVector2 * controlSize = [[[ NP Graphics ] viewportManager ] currentControlSize ];
    
    FVector2 pixelSize;
    FVector2 innerQuadUpperLeft;
    FVector2 innerQuadLowerRight;

    pixelSize.x = 1.0f/(Float)(controlSize->x / 2);
    pixelSize.y = 1.0f/(Float)(controlSize->y / 2);

    innerQuadUpperLeft.x  = -1.0f + pixelSize.x;
    innerQuadUpperLeft.y  =  1.0f - pixelSize.y;
    innerQuadLowerRight.x =  1.0f - pixelSize.x;
    innerQuadLowerRight.y = -1.0f + pixelSize.y;

    /*[ advectionRenderTargetConfiguration clear ];
    [ advectionRenderTargetConfiguration setColorRenderTarget:temporaryStorage atIndex:0 ];
    [ advectionRenderTargetConfiguration setColorRenderTarget:quantityTarget   atIndex:1 ];
    [ advectionRenderTargetConfiguration activate ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];*/

    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:temporaryStorage ];
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:1 withObject:quantityTarget   ];
    [ advectionRenderTargetConfiguration bindFBO ];
    [ temporaryStorage attachToColorBufferIndex:0 ];
    [ quantityTarget   attachToColorBufferIndex:1 ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    //[[ velocitySource texture ] activateAtColorMapIndex:0 ];
    //[[ quantitySource texture ] activateAtColorMapIndex:1 ];

    [ advectionEffect activateTechniqueWithName:@"advect" ];

    glBegin(GL_QUADS);
        glVertex4f(innerQuadUpperLeft.x,  innerQuadUpperLeft.y,  0.0f, 1.0f);
        glVertex4f(innerQuadUpperLeft.x,  innerQuadLowerRight.y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight.x, innerQuadLowerRight.y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight.x, innerQuadUpperLeft.y,  0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:quantityTarget ];
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:1 withObject:[NSNull null]  ];
    [ quantityTarget detach ];
    [ quantityTarget attachToColorBufferIndex:0 ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];


    /*[ advectionRenderTargetConfiguration deactivate ];
    [ advectionRenderTargetConfiguration clear ];
    [ advectionRenderTargetConfiguration setColorRenderTarget:quantityTarget atIndex:0 ];
    [ advectionRenderTargetConfiguration activate ];
    //[ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];*/

    [[ temporaryStorage texture ] activateAtColorMapIndex:0 ];
    [ advectionEffect activateTechniqueWithName:@"border" ];

    glBegin(GL_LINES);
        glVertex4f(-1.0f+pixelSize.x*0.5f,  1.0f, 0.0f, 1.0f);
        glVertex4f(-1.0f+pixelSize.x*0.5f, -1.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glVertex4f(1.0f-pixelSize.x*0.5f,  1.0f, 0.0f, 1.0f);
        glVertex4f(1.0f-pixelSize.x*0.5f, -1.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glVertex4f(-1.0f, 1.0f-pixelSize.y*0.5f, 0.0f, 1.0f);
        glVertex4f( 1.0f, 1.0f-pixelSize.y*0.5f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glVertex4f(-1.0f, -1.0f+pixelSize.y*0.5f, 0.0f, 1.0f);
        glVertex4f( 1.0f, -1.0f+pixelSize.y*0.5f, 0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [ advectionRenderTargetConfiguration unbindFBO ];
    //[ advectionRenderTargetConfiguration deactivate ];
}


- (void) update:(Float)frameTime
{
    /*IVector2 * controlSize = [[[ NP Graphics ] viewportManager ] currentControlSize ];
    
    FVector2 pixelSize;
    FVector2 innerQuadUpperLeft;
    FVector2 innerQuadLowerRight;

    pixelSize.x = 1.0f/(Float)(controlSize->x / 2);
    pixelSize.y = 1.0f/(Float)(controlSize->y / 2);

    innerQuadUpperLeft.x = -1.0f + pixelSize.x;
    innerQuadUpperLeft.y =  1.0f - pixelSize.y;
    innerQuadLowerRight.x =  1.0f - pixelSize.x;
    innerQuadLowerRight.y = -1.0f + pixelSize.y;

    [ advectionRenderTargetConfiguration setColorRenderTarget:velocityTarget atIndex:0 ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];
    [ advectionRenderTargetConfiguration activate ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ velocitySource texture ] activateAtColorMapIndex:0 ];
    [ advectionEffect activate ];

    glBegin(GL_QUADS);
        glColor4f(0.0f,0.0f,1.0f,0.0f);
        glVertex4f(innerQuadUpperLeft.x, innerQuadUpperLeft.y, 0.0f, 1.0f);
        glColor4f(0.0f,0.0f,1.0f,0.0f);
        glVertex4f(innerQuadUpperLeft.x, innerQuadLowerRight.y, 0.0f, 1.0f);
        glColor4f(0.0f,0.0f,1.0f,0.0f);
        glVertex4f(innerQuadLowerRight.x, innerQuadLowerRight.y, 0.0f, 1.0f);
        glColor4f(0.0f,0.0f,1.0f,0.0f);
        glVertex4f(innerQuadLowerRight.x, innerQuadUpperLeft.y, 0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];
    [ advectionRenderTargetConfiguration deactivate ];
    [ self swapVelocityRenderTextures ];*/

    /*
    glBegin(GL_LINES);
        glColor4f(1.0f, 0.0f, 0.0f, 0.0f);
        glVertex4f(-1.0f+pixelSize.x*0.5f, 1.0f, 0.0f, 1.0f);
        glColor4f(1.0f, 0.0f, 0.0f, 0.0f);
        glVertex4f(-1.0f+pixelSize.x*0.5f, -1.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glColor4f(1.0f, 0.0f, 0.0f, 0.0f);
        glVertex4f(1.0f-pixelSize.x*0.5f, 1.0f, 0.0f, 1.0f);
        glColor4f(1.0f, 0.0f, 0.0f, 0.0f);
        glVertex4f(1.0f-pixelSize.x*0.5f, -1.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glColor4f(1.0f, 0.0f, 0.0f, 0.0f);
        glVertex4f(-1.0f, 1.0f-pixelSize.y*0.5f, 0.0f, 1.0f);
        glColor4f(1.0f, 0.0f, 0.0f, 0.0f);
        glVertex4f(1.0f, 1.0f-pixelSize.y*0.5f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glColor4f(1.0f, 0.0f, 0.0f, 0.0f);
        glVertex4f(-1.0f, -1.0f+pixelSize.y*0.5f, 0.0f, 1.0f);
        glColor4f(1.0f, 0.0f, 0.0f, 0.0f);
        glVertex4f(1.0f, -1.0f+pixelSize.y*0.5f, 0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [ advectionRenderTargetConfiguration deactivate ];

    [ self swapVelocityRenderTextures ];*/
}

- (void) render
{

}

@end
