#import "Application/NPApplicationController.h"

@interface ODApplicationController : NPApplicationController
{
    id entityManager;
    id sceneManager;
}

- (void) configureResourcePaths;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
- (void) applicationWillTerminate:(NSNotification *)aNotification;

- (void) dealloc;

- (id) entityManager;
- (id) sceneManager;

- (void) update;
- (void) render;

@end
