#import "NP.h"
#import "RTVCore.h"
#import "RTVSceneManager.h"
#import "RTVAdvection.h"
#import "RTVDiffusion.h"
#import "RTVInputForce.h"
#import "RTVFluid.h"
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

    font = [[[ NP Graphics ] fontManager ] loadFontFromPath:@"tahoma.font" ];

    fullscreenEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Fullscreen.cgfx" ];

    fluid = [[ RTVFluid alloc ] initWithName:@"Fluid" parent:self ];

    return self;
}

- (void) dealloc
{
    DESTROY(fluid);

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
    //[[[ NP Graphics ] stateConfiguration ] activate ];

    [ fluid update:frameTime ];

    //[[[ NP Graphics ] stateConfiguration ] deactivate ];
}

- (void) render
{
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    ///[[[ NP Graphics ] stateConfiguration ] activate ];

//    [[[ fluid arbitraryBoundariesTarget ] texture ] activateAtColorMapIndex:0 ];
    [[[ fluid inkSource ] texture ] activateAtColorMapIndex:0 ];

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

    FVector2 pos = {-1.0f, 1.0f };
    [ font renderString:[NSString stringWithFormat:@"%d %f",[[[ NP Core ] timer ] fps ],[[[ NP Core ] timer ] frameTime ] ] atPosition:&pos withSize:0.05f ];

    //[[[ NP Graphics ] stateConfiguration ] deactivate ];
}

@end
