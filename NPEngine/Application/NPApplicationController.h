#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>

@interface NPApplicationController : NSObject
{
    id window;
    BOOL renderWindowActiveLastFrame;
    BOOL renderWindowActive;
}

- (id) init;
- (void) createRenderWindow;

- (id) window;

- (BOOL) renderWindowActive;
- (BOOL) renderWindowActivated;
- (BOOL) renderWindowDeactivated;

- (void) windowWillClose:(NSNotification *)aNotification;
- (void) windowDidBecomeKey:(NSNotification *)notification;
- (void) windowDidResignKey:(NSNotification *)notification;

@end
