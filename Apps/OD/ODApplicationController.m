#import <AppKit/NSCursor.h>
#import "ODApplicationController.h"
#import "ODSceneManager.h"
#import "ODEntityManager.h"
#import "NP.h"

@implementation ODApplicationController

- (void) configureResourcePaths
{
    NSString * path         = [[ NSBundle mainBundle ] bundlePath];
    NSString * contentPath  = [path stringByAppendingPathComponent:@"Resources/Content" ];
    NSString * modelPath    = [contentPath stringByAppendingPathComponent:@"Models"   ];
    NSString * entitiesPath = [contentPath stringByAppendingPathComponent:@"Entities" ];
    NSString * scenesPath   = [contentPath stringByAppendingPathComponent:@"Scenes"   ];
    NSString * effectPath   = [contentPath stringByAppendingPathComponent:@"Effects"  ];
    NSString * statesetPath = [contentPath stringByAppendingPathComponent:@"Statesets"];

    [[[ NP Core ] pathManager ] addLookUpPath:modelPath    ];
    [[[ NP Core ] pathManager ] addLookUpPath:entitiesPath ];
    [[[ NP Core ] pathManager ] addLookUpPath:scenesPath   ];
    [[[ NP Core ] pathManager ] addLookUpPath:effectPath   ];
    [[[ NP Core ] pathManager ] addLookUpPath:statesetPath ];
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [ super createRenderWindow ];

    [ self configureResourcePaths ];

    entityManager = [[ ODEntityManager alloc ] init ];
    sceneManager  = [[ ODSceneManager  alloc ] init ];

    [ NSCursor hide ];

    id scene = [ sceneManager loadSceneFromPath:@"test.scene" ];
    [ scene activate ];
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
    // Delete resources here....

    return NSTerminateNow;
}

- (void) applicationWillTerminate:(NSNotification *)aNotification
{
    // .... or here

    [ sceneManager  release ];
    [ entityManager release ];

    [ NSApp setDelegate:nil ];
}

- (void) dealloc
{
    [ super dealloc ];
}

- (id) entityManager
{
    return entityManager;
}

- (id) sceneManager
{
    return sceneManager;
}

- (void) update
{
    [ sceneManager update ];
}

- (void) render
{
    [ sceneManager render ];
}

@end
