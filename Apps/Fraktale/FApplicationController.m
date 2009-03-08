#import <AppKit/NSCursor.h>
#import "FApplicationController.h"
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
    [ super createRenderWindow ];

    [ self configureResourcePaths ];

    glClearColor(0.0f,0.0f,0.0f,1.0f);
    glClearDepth(1);

    sceneManager = [[ FSceneManager alloc ] init ];
    FScene * scene = [ sceneManager loadSceneFromPath:@"Test.scene" ];
    [ scene activate ];

    [ NSCursor hide ];

    // scene alloc init
    //[ scene activate ];
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
    [ super dealloc ];
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

    NSRect windowRect = [ window frame ];
    if ( [[[ NP Input ] mouse ] x ] < (windowRect.size.width /4.0f) || [[[ NP Input ] mouse ] x ] > (windowRect.size.width  * 3.0/4.0f) ||
         [[[ NP Input ] mouse ] y ] < (windowRect.size.height/4.0f) || [[[ NP Input ] mouse ] y ] > (windowRect.size.height * 3.0/4.0f) )
    {
        NSPoint point = { windowRect.size.width/2.0f, windowRect.size.height/2.0f };
        [[[ NP Input ] mouse ] setPosition:point ];
    }
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
