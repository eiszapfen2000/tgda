#import <AppKit/AppKit.h>

@interface ODWindowController : NSObject
{
    NSTimer * timer;
}

- (void) setupRenderLoopInView:(id)view;

- (void) windowWillClose:(NSNotification *)aNotification;

@end
