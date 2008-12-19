#import "NP.h"
#import "ODScene.h"
#import "ODCamera.h"
#import "ODProjector.h"
#import "ODSurface.h"
#import "ODApplicationController.h"
#import "ODEntityManager.h"

@implementation ODScene

- (id) init
{
    return [ self initWithName:@"ODScene" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    entities = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    //[ projector release ];
    //[ camera    release ];
    [ entities removeAllObjects ];
    [ entities release ];

    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * config = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSString * sceneName = [ config objectForKey:@"Name" ];
    NSArray * entityFiles = [ config objectForKey:@"Entities" ];

    if ( sceneName == nil || entityFiles == nil )
    {
        return NO;
    }

    [ self setName:sceneName ];

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

- (void) setup
{
    camera    = [[ ODCamera    alloc ] initWithName:@"RenderingCamera" parent:self ];
    projector = [[ ODProjector alloc ] initWithName:@"Projector"       parent:self ];

    FVector3 pos = { 0.0f, 2.0f, 5.0f };

    [ camera setPosition:&pos ];

    pos.y = 3.0f;
    pos.z = 0.0f;

    [ projector setPosition:&pos ];
    [ projector cameraRotateUsingYaw:0.0f andPitch:-30.0f ];
    [ projector setRenderFrustum:YES ];

    //skybox = [[[ NP Graphics ] modelManager ] loadModelFromPath:@"skybox.model" ];
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
    [ camera    update ];
    [ projector update ];
}

- (void) render
{
    [ camera    render ];
    [ projector render ];
}

@end
