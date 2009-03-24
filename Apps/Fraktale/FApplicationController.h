#import "Application/NPApplicationController.h"

@interface FApplicationController : NPApplicationController
{
    id attributesWindowController;
    id sceneManager;
}

- (void) configureResourcePaths;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
- (void) applicationWillTerminate:(NSNotification *)aNotification;

- (void) dealloc;

- (void) reloadScene;

- (id) attributesWindowController;
- (id) sceneManager;

- (void) update;
- (void) render;

@end
