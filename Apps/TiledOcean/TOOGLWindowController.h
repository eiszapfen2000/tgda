#import <AppKit/AppKit.h>
#import "NPOpenGLView.h"

@interface TOOGLWindowController : NSWindowController
{
    NPOpenGLView * openglView;
}

- init;

- (NPOpenGLView *) openglView;
- (void) windowDidLoad;

@end
