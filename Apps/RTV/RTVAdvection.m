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

    currentResolution = iv2_alloc_init();
    resolutionLastFrame = iv2_alloc_init();
    offsetVector = fv2_alloc_init();

    advectionEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Advection.cgfx" ];
    timestep = [ advectionEffect parameterWithName:@"timestep" ];

    advectionRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"AdvectionRT" parent:self ];

    return self;
}

- (void) dealloc
{
    iv2_free(currentResolution);
    iv2_free(resolutionLastFrame);
    fv2_free(offsetVector);

    DESTROY(temporaryStorage);

    [ advectionRenderTargetConfiguration clear ];
    [ advectionRenderTargetConfiguration release ];

    [ super dealloc ];
}

- (IVector2) resolution
{
    return *currentResolution;
}

- (void) setResolution:(IVector2)newResolution
{
    currentResolution->x = newResolution.x;
    currentResolution->y = newResolution.y;
}

- (void) advectQuantityFrom:(id)quantitySource
                         to:(id)quantityTarget
              usingVelocity:(id)velocity
{
    #warning "Timestep missing"

    FVector2 pixelSize;
    FVector2 innerQuadUpperLeft;
    FVector2 innerQuadLowerRight;

    pixelSize.x = 1.0f/(Float)(currentResolution->x / 2);
    pixelSize.y = 1.0f/(Float)(currentResolution->y / 2);

    innerQuadUpperLeft.x  = -1.0f + pixelSize.x;
    innerQuadUpperLeft.y  =  1.0f - pixelSize.y;
    innerQuadLowerRight.x =  1.0f - pixelSize.x;
    innerQuadLowerRight.y = -1.0f + pixelSize.y;

    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:temporaryStorage ];
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:1 withObject:quantityTarget   ];
    [ advectionRenderTargetConfiguration bindFBO ];
    [ quantityTarget   attachToColorBufferIndex:0 ];
    [ temporaryStorage attachToColorBufferIndex:1 ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration activateViewport ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ velocity       texture ] activateAtColorMapIndex:0 ];
    [[ quantitySource texture ] activateAtColorMapIndex:1 ];

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
    [ temporaryStorage detach ];
    //[ quantityTarget attachToColorBufferIndex:0 ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ temporaryStorage texture ] activateAtColorMapIndex:0 ];

    [ advectionEffect activateTechniqueWithName:@"border" ];

    glBegin(GL_LINES);
        glTexCoord2f(1.0f/(Float)currentResolution->x, 0.0f);
        glVertex4f(-1.0f+pixelSize.x*0.5f,  1.0f, 0.0f, 1.0f);
        glTexCoord2f(1.0f/(Float)currentResolution->x, 0.0f);
        glVertex4f(-1.0f+pixelSize.x*0.5f, -1.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(-1.0f/(Float)currentResolution->x, 0.0f);
        glVertex4f(1.0f-pixelSize.x*0.5f,  1.0f, 0.0f, 1.0f);
        glTexCoord2f(-1.0f/(Float)currentResolution->x, 0.0f);
        glVertex4f(1.0f-pixelSize.x*0.5f, -1.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(0.0f, -1.0f/(Float)currentResolution->y);
        glVertex4f(-1.0f, 1.0f-pixelSize.y*0.5f, 0.0f, 1.0f);
        glTexCoord2f(0.0f, -1.0f/(Float)currentResolution->y);
        glVertex4f( 1.0f, 1.0f-pixelSize.y*0.5f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(0.0f, 1.0f/(Float)currentResolution->y);
        glVertex4f(-1.0f, -1.0f+pixelSize.y*0.5f, 0.0f, 1.0f);
        glTexCoord2f(0.0f, 1.0f/(Float)currentResolution->y);
        glVertex4f( 1.0f, -1.0f+pixelSize.y*0.5f, 0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [ advectionRenderTargetConfiguration unbindFBO ];
    [ advectionRenderTargetConfiguration deactivateDrawBuffers ];
    [ advectionRenderTargetConfiguration deactivateViewport ];
}

- (void) updateRenderTextures
{
    if ( temporaryStorage != nil )
    {
        DESTROY(temporaryStorage);
    }

    id tempRenderTexture = [ NPRenderTexture renderTextureWithName:@"Temp"
                                                              type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                             width:currentResolution->x
                                                            height:currentResolution->y
                                                        dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                       pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                  textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                  textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                      textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                      textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    temporaryStorage = [ tempRenderTexture retain ];
}

- (void) update:(Float)frameTime
{
    if ( (currentResolution->x != resolutionLastFrame->x) || (currentResolution->y != resolutionLastFrame->y) )
    {
        [ self updateRenderTextures ];

        [ advectionRenderTargetConfiguration setWidth :currentResolution->x ];
        [ advectionRenderTargetConfiguration setHeight:currentResolution->y ];

        resolutionLastFrame->x = currentResolution->x;
        resolutionLastFrame->y = currentResolution->y;
    }
}

- (void) render
{

}

@end
