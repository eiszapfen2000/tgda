#import <AppKit/NSView.h>

@class NPOpenGLRenderContext;

@interface NPOpenGLView : NSView
{
    NPOpenGLRenderContext * renderContext;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void) dealloc;

- (void) setup;
- (void) shutdown;
- (void) update;

@end
