#import <AppKit/NSCursor.h>
#import "FApplicationController.h"
#import "FWindowController.h"
#import "FScene.h"
#import "FSceneManager.h"
#import "NP.h"

@implementation FApplicationController

- (void) configureResourcePaths
{
    NSString * path         = [[ NSBundle mainBundle ] bundlePath];
    NSString * contentPath  = [ path stringByAppendingPathComponent:@"Resources/Content" ];

    [[[ NP Core ] pathManager ] addLookUpPath:contentPath ];
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [ self createRenderWindow ];

    [ self configureResourcePaths ];

    attributesWindowController = [[ FWindowController alloc ] init ];
    [ attributesWindowController showWindow:nil ];

    glClearColor(0.0f,0.0f,0.0f,1.0f);
    glClearDepth(1);

    sceneManager = [[ FSceneManager alloc ] init ];
    FScene * scene = [ sceneManager loadSceneFromPath:@"Test.scene" ];
    [ scene activate ];

    //[ NSCursor hide ];
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
    // Delete resources here....

    FScene * currentScene = [ sceneManager currentScene ];
    if ( currentScene != nil )
    {
        [ currentScene deactivate ];
    }

    return NSTerminateNow;
}

- (void) applicationWillTerminate:(NSNotification *)aNotification
{
    // .... or here

    TEST_RELEASE(sceneManager);

    [ NSApp setDelegate:nil ];
}

- (void) dealloc
{
    [ attributesWindowController autorelease ];

    [ super dealloc ];
}

- (void) reloadScene
{
    [ attributesWindowController initPopUpButtons ];

    [ sceneManager clear ];
    FScene * scene = [ sceneManager loadSceneFromPath:@"Test.scene" ];
    [ scene activate ];
}

- (id) attributesWindowController
{
    return attributesWindowController;
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

    renderWindowActiveLastFrame = renderWindowActive;
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
