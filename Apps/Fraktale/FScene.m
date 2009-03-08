#import "NP.h"
#import "FCore.h"
#import "FScene.h"
#import "FSceneManager.h"
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

    FVector3 pos = { 0.0f, 3.0f, 3.0f };
    [ camera setPosition:&pos ];
}

- (void) deactivate
{
    [[[ NP applicationController ] sceneManager ] setCurrentScene:nil ];

    DESTROY(camera);
}

- (void) update:(Float)frameTime
{
    [ camera update:frameTime ];
}

- (void) render
{
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:NO ];
    [[[ NP Graphics ] stateConfiguration ] activate ];

    [ camera render ];

    if ( terrain != nil )
        [ terrain render ];
}

@end
