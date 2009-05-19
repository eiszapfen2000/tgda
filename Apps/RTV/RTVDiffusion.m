#import "NP.h"
#import "RTVCore.h"
#import "RTVDiffusion.h"

@implementation RTVDiffusion

- (id) init
{
    return [ self initWithName:@"Diffusion" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    IVector2 * v = [[[[ NP Graphics ] viewportManager ] currentViewport ] viewportSize ];

    diffusionEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Diffusion.cgfx" ];
    diffusionRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"DiffusionRT" parent:self ];
    [ diffusionRenderTargetConfiguration setWidth :v->x ];
    [ diffusionRenderTargetConfiguration setHeight:v->y ];

    alpha = [ diffusionEffect parameterWithName:@"alpha" ];
    rBeta = [ diffusionEffect parameterWithName:@"rBeta" ];

    numberOfIterations = 20;

    return self;
}

- (void) dealloc
{
    [ diffusionRenderTargetConfiguration clear ];
    [ diffusionRenderTargetConfiguration release ];

    [ super dealloc ];
}

- (void) diffuseQuantityFrom:(id)quantitySource to:(id)quantityTarget
{
    /*[ diffusionRenderTargetConfiguration clear ];
    [ diffusionRenderTargetConfiguration setColorRenderTarget:quantityTarget atIndex:0 ];
    [ diffusionRenderTargetConfiguration activate ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];*/

    id source = quantitySource;
    id target = quantityTarget;
    id tmp;

    [ diffusionRenderTargetConfiguration bindFBO ];
    [ diffusionEffect uploadFloatParameter:alpha andValue:1.0f ];
    [ diffusionEffect uploadFloatParameter:rBeta andValue:1.0f ];

    for ( Int i = 0; i < numberOfIterations; i++ )
    {
        [[ diffusionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:target ];
        [ target attachToColorBufferIndex:0 ];
        [ diffusionRenderTargetConfiguration activateDrawBuffers ];

        [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

        [[ source texture ] activateAtColorMapIndex:0 ];
        [ diffusionEffect activateTechniqueWithName:@"diffuse" ];

        glBegin(GL_QUADS);
            glVertex4f(-1.0f,  1.0f, 0.0f, 1.0f);
            glVertex4f(-1.0f, -1.0f, 0.0f, 1.0f);
            glVertex4f( 1.0f, -1.0f, 0.0f, 1.0f);
            glVertex4f( 1.0f,  1.0f, 0.0f, 1.0f);
        glEnd();

        [ diffusionEffect deactivate ];

        tmp = source;
        source = target;
        target = tmp;
    }

    [ diffusionRenderTargetConfiguration unbindFBO ];

/*    [[ diffusionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:quantityTarget ];
    [ diffusionRenderTargetConfiguration bindFBO ];
    [ quantityTarget attachToColorBufferIndex:0 ];
    [ diffusionRenderTargetConfiguration activateDrawBuffers ];
    [ diffusionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ quantitySource texture ] activateAtColorMapIndex:0 ];
    [ diffusionEffect activateTechniqueWithName:@"diffuse" ];
    [ diffusionEffect uploadFloatParameter:alpha andValue:1.0f ];
    [ diffusionEffect uploadFloatParameter:rBeta andValue:1.0f ];

    glBegin(GL_QUADS);
        glVertex4f(-1.0f,  1.0f, 0.0f, 1.0f);
        glVertex4f(-1.0f, -1.0f, 0.0f, 1.0f);
        glVertex4f( 1.0f, -1.0f, 0.0f, 1.0f);
        glVertex4f( 1.0f,  1.0f, 0.0f, 1.0f);
    glEnd();

    [ diffusionEffect deactivate ];

    //[ diffusionRenderTargetConfiguration deactivate ];

    [ diffusionRenderTargetConfiguration unbindFBO ];*/
}

@end
