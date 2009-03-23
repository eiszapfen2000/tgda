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

- (id) attributesWindowController;
- (id) sceneManager;

- (void) update;
- (void) render;

@end
