#import <AppKit/AppKit.h>

@interface ODApplicationController : NSObject
{
    id window;
    id windowController;
}

- (id) init;
- (void) dealloc;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
- (void) applicationWillTerminate:(NSNotification *)aNotification;

@end
