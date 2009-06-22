#import "NP.h"
#import "RTVCore.h"
#import "RTVSceneManager.h"
#import "RTVAdvection.h"
#import "RTVDiffusion.h"
#import "RTVInputForce.h"
#import "RTVFluid.h"
#import "RTVMenu.h"
#import "RTVCheckBoxItem.h"
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

    projection = fm4_alloc_init();
    identity   = fm4_alloc_init();
    fm4_mssss_orthographic_2d_projection_matrix(projection, 0.0f, 1.0f, 0.0f, 1.0f);

    font = [[[ NP Graphics ] fontManager ] loadFontFromPath:@"tahoma.font" ];

    fullscreenEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Fullscreen.cgfx" ];

    menu = [[ RTVMenu alloc ] initWithName:@"Menu" parent:self ];
    [ menu loadFromPath:@"Menu.menu" ];

    fluid = [[ RTVFluid alloc ] initWithName:@"Fluid" parent:self ];

    return self;
}

- (void) dealloc
{
    fm4_free(projection);
    fm4_free(identity);

    DESTROY(fluid);
    DESTROY(menu);

    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    //NSDictionary * sceneConfig = [ NSDictionary dictionaryWithContentsOfFile:path ];

    return [ fluid loadFromPath:path ];

//    return YES;
}

- (void) activate
{
    [[[ NP applicationController ] sceneManager ] setCurrentScene:self ];
}

- (void) deactivate
{
    [[[ NP applicationController ] sceneManager ] setCurrentScene:nil ];
}

- (void) update:(Float)frameTime
{
    [[[ NP Graphics ] stateConfiguration ] activate ];

    NPTransformationState * trafo = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
    [ trafo setProjectionMatrix:projection ];

    [ fluid update:frameTime ];
    [ menu  update:frameTime ];

    [ trafo setProjectionMatrix:identity ];

    [[[ NP Graphics ] stateConfiguration ] deactivate ];
}

- (void) render
{
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    NPTransformationState * trafo = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
    [ trafo setProjectionMatrix:projection ];

    [[[ fluid inkSource ] texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activate ];

    glBegin(GL_QUADS);
        glTexCoord2f(0.0f,1.0f);            
        glVertex4f(0.0f,1.0f,0.0f,1.0f);

        glTexCoord2f(0.0f,0.0f);
        glVertex4f(0.0f,0.5f,0.0f,1.0f);

        glTexCoord2f(1.0f,0.0f);
        glVertex4f(0.5f,0.5f,0.0f,1.0f);

        glTexCoord2f(1.0f,1.0f);
        glVertex4f(0.5f,1.0f,0.0f,1.0f);
    glEnd();

    [ fullscreenEffect deactivate ];

    [[[ fluid velocitySource ] texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activate ];

    glBegin(GL_QUADS);
        glTexCoord2f(0.0f,1.0f);            
        glVertex4f(0.5f,1.0f,0.0f,1.0f);

        glTexCoord2f(0.0f,0.0f);
        glVertex4f(0.5f,0.5f,0.0f,1.0f);

        glTexCoord2f(1.0f,0.0f);
        glVertex4f(1.0f,0.5f,0.0f,1.0f);

        glTexCoord2f(1.0f,1.0f);
        glVertex4f(1.0f,1.0f,0.0f,1.0f);
    glEnd();

    [ fullscreenEffect deactivate ];

    [[[ fluid pressureSource ] texture ] activateAtColorMapIndex:0 ];

    [ fullscreenEffect activate ];

    glBegin(GL_QUADS);
        glTexCoord2f(0.0f,1.0f);            
        glVertex4f(0.0f,0.5f,0.0f,1.0f);

        glTexCoord2f(0.0f,0.0f);
        glVertex4f(0.0f,0.0f,0.0f,1.0f);

        glTexCoord2f(1.0f,0.0f);
        glVertex4f(0.5f,0.0f,0.0f,1.0f);

        glTexCoord2f(1.0f,1.0f);
        glVertex4f(0.5f,0.5f,0.0f,1.0f);
    glEnd();

    [ fullscreenEffect deactivate ];

    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setBlendingMode:NP_BLENDING_AVERAGE ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

    [ menu render ];

    FVector2 pos = {0.0f, 0.0f };

    [ font renderString:[NSString stringWithFormat:@"%d",[[[ NP Core ] timer ] fps ]] atPosition:&pos withSize:0.02f ];

    [ trafo setProjectionMatrix:identity ];

    [[[[ NP Graphics ] stateConfiguration ] blendingState ] deactivate ];
}

@end
