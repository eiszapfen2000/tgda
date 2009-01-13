#import "NP.h"
#import "ODScene.h"
#import "ODCamera.h"
#import "ODProjector.h"
#import "ODSurface.h"
#import "ODApplicationController.h"
#import "ODEntityManager.h"
#import "ODSceneManager.h"

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

    return self;
}

- (void) dealloc
{
    [ entities removeAllObjects ];

    [ projector release ];
    [ camera    release ];
    [ skybox    release ];
    [ entities  release ];

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
        NPLOG_ERROR(([NSString stringWithFormat:@"Scene file %@ is incomplete",path]));
        return NO;
    }

    [ self setName:sceneName ];

    skybox = [[[(ODApplicationController *)[ NSApp delegate ] entityManager ] loadEntityFromPath:skyboxEntityFile ] retain ];

    NSEnumerator * entityFilesEnumerator = [ entityFiles objectEnumerator ];
    id entityFile;
    id entity;

    while (( entityFile = [ entityFilesEnumerator nextObject ] ))
    {
        entity = [[(ODApplicationController *)[ NSApp delegate ] entityManager ] loadEntityFromPath:entityFile ];
        [ entities addObject:entity ];
    }

    return YES;
}

- (void) activate
{
    [ (ODSceneManager *)parent setCurrentScene:self ];

    camera    = [[ ODCamera    alloc ] initWithName:@"RenderingCamera" parent:self ];
    projector = [[ ODProjector alloc ] initWithName:@"Projector"       parent:self ];

    FVector3 pos = { 0.0f, 2.0f, 5.0f };

    [ camera setPosition:&pos ];

    pos.y = 3.0f;
    pos.z = 0.0f;

    //[ projector setPosition:&pos ];
    [ projector cameraRotateUsingYaw:0.0f andPitch:-30.0f ];
    [ projector setRenderFrustum:YES ];

    /*NSPoint p = { 1024.0f/2.0f, 768.0f/2.0f };
    [[[ NP Input ] mouse ] setPosition:p ];*/
}

- (void) deactivate
{
}

- (id) camera
{
    return camera;
}

- (id) projector
{
    return projector;
}

- (void) update
{
    [[ NP Core  ] update ];
    [[ NP Input ] update ];

    [ camera    update ];
    [ projector update ];
    //[ skybox setPosition:[camera position] ];

    /*NSPoint p = { 1024.0f/2.0f, 768.0f/2.0f };
    [[[ NP Input ] mouse ] setPosition:p ];*/
}

- (void) render
{
    [[ NP Graphics ] render ];

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);        

    [ skybox    render ];
    [ camera    render ];
    //[ projector render ];

    [[ NP Graphics ] swapBuffers ];
}

@end
