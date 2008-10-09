#import <AppKit/AppKit.h>

@class NPOpenGLRenderContext;

@interface ODOpenGLView : NSView
{
  NPOpenGLRenderContext * renderContext;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void) dealloc;

- (void) setup;
- (void) shutdown;
- (void) update;

@end
