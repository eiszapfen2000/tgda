#import <AppKit/AppKit.h>
//#import "NPOpenGLView.h"
#import "TOOpenGLView.h"

@interface TOOGLWindowController : NSWindowController
{
    //NPOpenGLView * openglView;
    TOOpenGLView * openglView;
}

- init;

- (TOOpenGLView *) openglView;
- (void) windowDidLoad;

@end
