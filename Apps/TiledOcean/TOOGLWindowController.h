#import <AppKit/AppKit.h>

@interface TOOGLWindowController : NSWindowController
{
    id openglView;
    NSTimer * timer;
}

- init;

- (void) windowDidLoad;

- (void) doDrawingStuff;

@end
