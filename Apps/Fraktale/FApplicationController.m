#import <AppKit/NSCursor.h>
#import "FApplicationController.h"
#import "FWindowController.h"
#import "FScene.h"
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

    glClearColor(0.2f, 0.4f, 1.0f, 0.0f);
    glClearDepth(1);
    glLineWidth(2.0f);

    NSString * pathToDictionary = [[[ NP Core ] pathManager ] getAbsoluteFilePath:@"Test.scene" ];
    scene = [[ FScene alloc ] init ];
    NSAssert([ scene loadFromPath:pathToDictionary ] == YES, @"Unable to load scene");
    [ scene activate ];

    NSDictionary * sceneConfig = [ NSDictionary dictionaryWithContentsOfFile:pathToDictionary ];
    [ attributesWindowController initialiseSettingsUsingDictionary:sceneConfig ];

    //[ NSCursor hide ];
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
    // Delete resources here....

    [ scene deactivate ];

    return NSTerminateNow;
}

- (void) applicationWillTerminate:(NSNotification *)aNotification
{
    // .... or here

    TEST_RELEASE(scene);

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

    DESTROY(scene);

    NSString * pathToDictionary = [[[ NP Core ] pathManager ] getAbsoluteFilePath:@"Test.scene" ];
    scene = [[ FScene alloc ] init ];
    [ scene loadFromPath:pathToDictionary ];
    [ scene activate ];    
}

- (id) attributesWindowController
{
    return attributesWindowController;
}

- (FScene *) scene
{
    return scene;
}

- (void) update
{
    [[ NP Core  ] update ];
    [[ NP Input ] update ];

    Float frameTime = (Float)[[[ NP Core ] timer ] frameTime ];

    [ scene update:frameTime ];

    renderWindowActiveLastFrame = renderWindowActive;
}

- (void) render
{
    [ scene render ];

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
