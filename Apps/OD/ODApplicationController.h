#import "Application/NPApplicationController.h"

@class ODEntityManager;
@class ODSceneManager;

@interface ODApplicationController : NPApplicationController
{
    ODEntityManager * entityManager;
    ODSceneManager * sceneManager;
}

- (void) configureResourcePaths;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
- (void) applicationWillTerminate:(NSNotification *)aNotification;

- (void) dealloc;

- (ODEntityManager *) entityManager;
- (ODSceneManager *) sceneManager;

- (void) update;
- (void) render;

@end
