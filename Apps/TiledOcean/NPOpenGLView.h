#import <AppKit/NSView.h>

@class NPOpenGLRenderContext;

@interface NPOpenGLView : NSView
{
  NPOpenGLRenderContext * renderContext;

  BOOL			attached;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void) dealloc;

- (NPOpenGLRenderContext *)renderContext;

- (void) reshape;
- (void) update;


@end
