#import <AppKit/AppKit.h>

@class NPOpenGLRenderContext;

@interface NPOpenGLView : NSView
{
  NPOpenGLRenderContext * renderContext;

  BOOL			attached;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void) dealloc;

- (void)clearRenderContext;
- (NPOpenGLRenderContext *)renderContext;
- (void)setRenderContext:(NPOpenGLRenderContext*)newRenderContext;

- (void) reshape;
- (void) update;


@end
