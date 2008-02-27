#import <AppKit/AppKit.h>
#import "NPOpenGLView.h"

@interface TOOGLWindowController : NSWindowController
{
    NPOpenGLView * openglView;
    NSTimer * timer;
}

- init;

- (NPOpenGLView *) openglView;

- (void) windowDidLoad;
- (void) doDrawingStuff;

@end
