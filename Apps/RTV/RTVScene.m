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

- (id) fluid
{
    return fluid;
}

- (id) menu
{
    return menu;
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

    [ menu update:frameTime ];

    //RTVSelectionGroup * inkColors = [ menu menuItemWithName:@"InkColors" ];
    //Int32 activeItem = [ inkColors activeItem ];
    

    [ fluid update:frameTime ];

    [ trafo setProjectionMatrix:identity ];

    [[[ NP Graphics ] stateConfiguration ] deactivate ];
}

- (void) render
{
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    NPTransformationState * trafo = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
    [ trafo setProjectionMatrix:projection ];

    if ( [[ menu menuItemWithName:@"DataArrays" ] checked ] == NO )
    {
        [[[ fluid inkSource ] texture ] setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [[[ fluid inkSource ] texture ] setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [[[ fluid inkSource ] texture ] activateAtColorMapIndex:0 ];
        [ fullscreenEffect activateTechniqueWithName:@"fullscreen" ];

        glBegin(GL_QUADS);
            glTexCoord2f(0.0f,1.0f);            
            glVertex4f(0.0f,1.0f,0.0f,1.0f);

            glTexCoord2f(0.0f,0.0f);
            glVertex4f(0.0f,0.0,0.0f,1.0f);

            glTexCoord2f(1.0f,0.0f);
            glVertex4f(1.0f,0.0f,0.0f,1.0f);

            glTexCoord2f(1.0f,1.0f);
            glVertex4f(1.0f,1.0f,0.0f,1.0f);
        glEnd();

        [ fullscreenEffect deactivate ];

        [[[ fluid inkSource ] texture ] setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
        [[[ fluid inkSource ] texture ] setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];

        if ( [ fluid useArbitraryBoundaries ] == YES )
        {
            [[[[ NP Graphics ] stateConfiguration ] blendingState ] setBlendingMode:NP_BLENDING_ADDITIVE ];
            [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:YES ];
            [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

            [[[ fluid arbitraryBoundariesPaint ] texture ] activateAtColorMapIndex:0 ];
            [ fullscreenEffect activate ];//TechniqueWithName:@"boundaries" ];

            glBegin(GL_QUADS);
                glTexCoord2f(0.0f,1.0f);            
                glVertex4f(0.0f,1.0f,0.0f,1.0f);

                glTexCoord2f(0.0f,0.0f);
                glVertex4f(0.0f,0.0,0.0f,1.0f);

                glTexCoord2f(1.0f,0.0f);
                glVertex4f(1.0f,0.0f,0.0f,1.0f);

                glTexCoord2f(1.0f,1.0f);
                glVertex4f(1.0f,1.0f,0.0f,1.0f);
            glEnd();

            [ fullscreenEffect deactivate ];

            [[[[ NP Graphics ] stateConfiguration ] blendingState ] deactivate ];
        }        
    }
    else
    {
        [[[ fluid inkSource ] texture ] setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [[[ fluid inkSource ] texture ] setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [[[ fluid inkSource ] texture ] activateAtColorMapIndex:0 ];
        [ fullscreenEffect activateTechniqueWithName:@"fullscreen" ];

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

        [[[ fluid inkSource ] texture ] setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
        [[[ fluid inkSource ] texture ] setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];

        [[[ fluid velocitySource ] texture ] setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [[[ fluid velocitySource ] texture ] setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [[[ fluid velocitySource ] texture ] activateAtColorMapIndex:0 ];
        [ fullscreenEffect activateTechniqueWithName:@"fullscreen" ];

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

        [[[ fluid velocitySource ] texture ] setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
        [[[ fluid velocitySource ] texture ] setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];

        [[[ fluid pressureSource ] texture ] setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [[[ fluid pressureSource ] texture ] setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [[[ fluid pressureSource ] texture ] activateAtColorMapIndex:0 ];
        [ fullscreenEffect activateTechniqueWithName:@"fullscreen" ];

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

        [[[ fluid pressureSource ] texture ] setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
        [[[ fluid pressureSource ] texture ] setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];

        [[[ fluid arbitraryBoundariesPaint ] texture ] setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [[[ fluid arbitraryBoundariesPaint ] texture ] setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [[[ fluid arbitraryBoundariesPaint ] texture ] activateAtColorMapIndex:0 ];
        [ fullscreenEffect activateTechniqueWithName:@"fullscreen" ];

        glBegin(GL_QUADS);
            glTexCoord2f(0.0f,1.0f);            
            glVertex4f(0.5f,0.5f,0.0f,1.0f);

            glTexCoord2f(0.0f,0.0f);
            glVertex4f(0.5f,0.0f,0.0f,1.0f);

            glTexCoord2f(1.0f,0.0f);
            glVertex4f(1.0f,0.0f,0.0f,1.0f);

            glTexCoord2f(1.0f,1.0f);
            glVertex4f(1.0f,0.5f,0.0f,1.0f);
        glEnd();

        [ fullscreenEffect deactivate ];

        [[[ fluid arbitraryBoundariesPaint ] texture ] setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
        [[[ fluid arbitraryBoundariesPaint ] texture ] setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    }

    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setBlendingMode:NP_BLENDING_AVERAGE ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

    [ menu render ];

    [ trafo setProjectionMatrix:identity ];

    [[[[ NP Graphics ] stateConfiguration ] blendingState ] deactivate ];
}

@end
