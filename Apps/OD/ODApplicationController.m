#import <AppKit/NSCursor.h>
#import "ODApplicationController.h"
#import "ODSceneManager.h"
#import "Entities/ODEntityManager.h"
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
    NSString * fontsPath    = [contentPath stringByAppendingPathComponent:@"Fonts"];
    NSString * menuPath     = [contentPath stringByAppendingPathComponent:@"Menu"];

    [[[ NP Core ] pathManager ] addLookUpPath:modelPath    ];
    [[[ NP Core ] pathManager ] addLookUpPath:entitiesPath ];
    [[[ NP Core ] pathManager ] addLookUpPath:scenesPath   ];
    [[[ NP Core ] pathManager ] addLookUpPath:effectPath   ];
    [[[ NP Core ] pathManager ] addLookUpPath:statesetPath ];
    [[[ NP Core ] pathManager ] addLookUpPath:fontsPath ];
    [[[ NP Core ] pathManager ] addLookUpPath:menuPath ];
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [ super createRenderWindow ];

    [ self configureResourcePaths ];

    entityManager = [[ ODEntityManager alloc ] init ];
    sceneManager  = [[ ODSceneManager  alloc ] init ];

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
    [[ NP Core  ] update ];
    [[ NP Input ] update ];

    Float frameTime = (Float)[[[ NP Core ] timer ] frameTime ];

    [ sceneManager update:frameTime ];

    /*NSRect windowRect = [ window frame ];
    if ( [[[ NP Input ] mouse ] x ] < (windowRect.size.width /4.0f) || [[[ NP Input ] mouse ] x ] > (windowRect.size.width  * 3.0/4.0f) ||
         [[[ NP Input ] mouse ] y ] < (windowRect.size.height/4.0f) || [[[ NP Input ] mouse ] y ] > (windowRect.size.height * 3.0/4.0f) )
    {
        NSPoint point = { windowRect.size.width/2.0f, windowRect.size.height/2.0f };
        [[[ NP Input ] mouse ] setPosition:point ];
    }*/
}

- (void) render
{
    [ sceneManager render ];

    GLenum error;
    error = glGetError();
    while ( error != GL_NO_ERROR )
    {
        NPLOG_ERROR(@"%s", gluErrorString(error));
        error = glGetError();
    }

    [[ NP Graphics ] swapBuffers ];
}

@end
