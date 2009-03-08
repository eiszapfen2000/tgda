#import "NP.h"
#import "ODCore.h"
#import "ODScene.h"
#import "ODCamera.h"
#import "ODProjector.h"
#import "ODSurface.h"
#import "ODApplicationController.h"
#import "ODEntity.h"
#import "ODOceanEntity.h"
#import "ODEntityManager.h"
#import "ODSceneManager.h"
#import "ODPerlinNoise.h"

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

//    [ pbos removeAllObjects ];
//    [ pbos release ];
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
        NPLOG_ERROR(([NSString stringWithFormat:@"Scene file %@ is incomplete", path]));
        return NO;
    }

    [ self setName:sceneName ];

    skybox = [[[[ NP applicationController ] entityManager ] loadEntityFromPath:skyboxEntityFile ] retain ];

    /*NSEnumerator * entityFilesEnumerator = [ entityFiles objectEnumerator ];
    id entityFile;
    id entity;

    while (( entityFile = [ entityFilesEnumerator nextObject ] ))
    {
        entity = [[(ODApplicationController *)[ NSApp delegate ] entityManager ] loadEntityFromPath:entityFile ];
        [ entities addObject:entity ];
    }*/

    ocean = [[[ NP applicationController ] entityManager ] loadEntityFromPath:@"test.odata" ];

    font = [[[ NP Graphics ] fontManager ] loadFontFromPath:@"tahoma.font" ];

    return YES;
}

- (void) activate
{
    [ (ODSceneManager *)parent setCurrentScene:self ];

    camera    = [[ ODCamera    alloc ] initWithName:@"RenderingCamera" parent:self ];
    projector = [[ ODProjector alloc ] initWithName:@"Projector"       parent:self ];

    FVector3 pos = { 0.0f, 0.0f, 5.0f };

    [ camera setPosition:&pos ];

    pos.y = 5.0f;
    pos.z = 0.0f;

    [ projector setPosition:&pos ];
    [ projector cameraRotateUsingYaw:-0.0f andPitch:-90.0f ];
    [ projector setRenderFrustum:YES ];

    [[ skybox model ] uploadToGL ];
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
    [ camera    update:frameTime ];
    [ projector update ];
    //[ skybox setPosition:[camera position] ];
}

- (void) render
{
    // clear framebuffer/depthbuffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setComparisonFunction:NP_COMPARISON_LESS_EQUAL ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] polygonFillState ] setFrontFaceFill:NP_POLYGON_FILL_LINE ];
    [[[[ NP Graphics ] stateConfiguration ] polygonFillState ] setBackFaceFill:NP_POLYGON_FILL_LINE ];
     [[[ NP Graphics ] stateConfiguration ] activate ];
     [[[ NP Graphics ] stateConfiguration ] setLocked:YES ];

    [ camera render ];
    [ skybox render ];

    [ projector render ];
    [ ocean     render ];

    FMatrix4 matrix;
    fm4_m_set_identity(&matrix);
    NPTransformationState * t = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
    [ t setModelMatrix:&matrix ];
    [ t setViewMatrix:&matrix ];
    [ t setProjectionMatrix:&matrix ];

    FVector2 pos = {-1.0f, 1.0f };
    [ font renderString:[NSString stringWithFormat:@"%d",[[[ NP Core ] timer ] fps ]] atPosition:&pos withSize:0.05f ];

    [[[ NP Graphics ] stateConfiguration ] deactivate ];
}

@end
