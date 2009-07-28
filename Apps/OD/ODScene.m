#import "NP.h"
#import "ODCore.h"
#import "ODScene.h"
#import "ODCamera.h"
#import "ODProjector.h"
#import "ODSurface.h"
#import "ODEntity.h"
#import "ODOceanEntity.h"
#import "ODEntityManager.h"
#import "ODSceneManager.h"
#import "Menu/ODMenu.h"

@implementation ODScene

- (id) init
{
    return [ self initWithName:@"ODScene" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    entities = [[ NSMutableArray alloc ] init ];

    camera    = [[ ODCamera    alloc ] initWithName:@"RenderingCamera" parent:self ];
    projector = [[ ODProjector alloc ] initWithName:@"Projector"       parent:self ];

    FVector3 pos = { 0.0f, 2.0f, 5.0f };

    [ camera setPosition:&pos ];

    pos.y = 5.0f;
    pos.z = 0.0f;

    [ projector setPosition:&pos ];
    [ projector cameraRotateUsingYaw:-0.0f andPitch:-90.0f ];
    //[ projector setRenderFrustum:YES ];

    fullscreenEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Fullscreen.cgfx" ];

    //ocean = [[[ NP applicationController ] entityManager ] loadEntityFromPath:@"test.odata" ];

    return self;
}

- (void) dealloc
{
    [ menu      release ];
    [ projector release ];
    [ camera    release ];

    [ entities removeAllObjects ];
    [ entities release ];

    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * config = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSString * sceneName        = [ config objectForKey:@"Name"     ];
    NSArray  * entityFiles      = [ config objectForKey:@"Entities" ];
    NSString * skyboxEntityFile = [ config objectForKey:@"Skybox"   ];

    if ( sceneName == nil || entityFiles == nil || skyboxEntityFile == nil )
    {
        NPLOG_ERROR(@"Scene file %@ is incomplete", path);
        return NO;
    }

    [ self setName:sceneName ];

    NSEnumerator * entityFilesEnumerator = [ entityFiles objectEnumerator ];
    id entityFileName;

    while ( (entityFileName = [ entityFilesEnumerator nextObject ]) )
    {
        id entity = [[[ NP applicationController ] entityManager ] loadEntityFromPath:entityFileName ];

        if ( entity != nil )
        {
            [ entities addObject:entity ];
        }
    }

    font = [[[ NP Graphics ] fontManager ] loadFontFromPath:@"tahoma.font" ];

    menu = [[ ODMenu alloc ] initWithName:@"Menu" parent:self ];
    if ( [ menu loadFromPath:@"Menu.menu" ] == NO )
    {
        return NO;
    }

    return YES;
}

- (void) activate
{
    [ (ODSceneManager *)parent setCurrentScene:self ];
}

- (void) deactivate
{
    [ (ODSceneManager *)parent setCurrentScene:nil ];
}

- (id) camera
{
    return camera;
}

- (id) projector
{
    return projector;
}

- (void) update:(Float)frameTime
{
    [ camera update:frameTime ];
    [ projector update ];

    [ menu update:frameTime ];
}

- (void) render
{
    // clear framebuffer/depthbuffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [[[ NP Graphics ] stateConfiguration ] activate ];

    [ camera render ];
    [ projector render ];

    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setCullFace:NP_BACK_FACE ];
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] activate ];

    //[ ocean render ];



    FMatrix4 identity;
    fm4_m_set_identity(&identity);

    NPTransformationState * trafo = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
    [ trafo setViewMatrix:&identity ];
    [ trafo setProjectionMatrix:&identity ];

    [[[ ocean renderTexture] texture ] activateAtColorMapIndex:0 ];

    [ fullscreenEffect activate ];

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

    /*[[[[ NP Graphics ] stateConfiguration ] blendingState ] setBlendingMode:NP_BLENDING_AVERAGE ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

    [[[ NP Graphics ] orthographicRendering ] activate ];

    //FVector2 fpsPosition = {0.0f, 0.1f };
    //[ font renderString:[ NSString stringWithFormat:@"%d", [[[ NP Core ] timer ] fps ]] atPosition:&fpsPosition withSize:0.05f ];

    [ menu render ];

    [[[ NP Graphics ] orthographicRendering ] deactivate ];*/

    [[[ NP Graphics ] stateConfiguration ] deactivate ];
}

@end
