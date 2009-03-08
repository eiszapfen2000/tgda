#import "Application/NPApplicationController.h"

@interface FApplicationController : NPApplicationController
{
    id sceneManager;
}

- (void) configureResourcePaths;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
- (void) applicationWillTerminate:(NSNotification *)aNotification;

- (void) dealloc;

- (id) sceneManager;

- (void) update;
- (void) render;

@end
