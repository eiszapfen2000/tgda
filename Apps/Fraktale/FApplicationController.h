#import "Application/NPApplicationController.h"

@class FScene;

@interface FApplicationController : NPApplicationController
{
    id attributesWindowController;
    FScene * scene;
}

- (void) configureResourcePaths;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
- (void) applicationWillTerminate:(NSNotification *)aNotification;

- (void) dealloc;

- (void) reloadScene;

- (id) attributesWindowController;
- (FScene *) scene;

- (void) update;
- (void) render;

@end
