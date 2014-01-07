#import <AppKit/NSCursor.h>
#import "RTVApplicationController.h"
#import "RTVSceneManager.h"
#import "NP.h"

@implementation RTVApplicationController

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

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClearDepth(1);

    sceneManager = [[ RTVSceneManager alloc ] init ];
    id scene = [ sceneManager loadSceneFromPath:@"Test.scene" ];
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
