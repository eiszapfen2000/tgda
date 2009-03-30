#import "NP.h"
#import "FCore.h"
#import "FScene.h"
#import "FSceneManager.h"
#import "FCamera.h"
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

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(terrain);

    [ super dealloc ];
}

- (FTerrain *) terrain
{
    return terrain;
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * sceneConfig = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSString * typeName = [ sceneConfig objectForKey:@"Type" ];
    if ( typeName == nil )
    {
        NPLOG_ERROR(@"%@: Type missing, bailing out", path);
        return NO;
    }

    if ( [ typeName isEqual:@"Terrain" ] == YES )
    {
        terrain = [[ FTerrain alloc ] init ];
        
        if ( [ terrain loadFromPath:path ] == NO )
        {
            NPLOG_ERROR(@"BRAK");
            return NO;
        }
    }

    return YES;
}

- (void) activate
{
    [[[ NP applicationController ] sceneManager ] setCurrentScene:self ];

    camera = [[ FCamera alloc ] initWithName:@"Camera" parent:self ];

    FVector3 pos = { 0.0f, 3.0f, 0.0f };
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
    //glFrontFace(GL_CCW);

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setCullFace:NP_BACK_FACE ];
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:NO ];
    [[[ NP Graphics ] stateConfiguration ] activate ];

    //glCullFace(GL_BACK);
    //glEnable(GL_CULL_FACE);


    [ camera render ];

    /*glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(45.0f,4.0f/3.0f,0.1f,50.0f);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0f,3.0f,0.0f,0.0f,3.0f,-50.0f,0.0f,1.0f,0.0f);*/

    if ( terrain != nil )
        [ terrain render ];
}

@end
