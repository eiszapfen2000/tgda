#import "NPOpenGLView.h"

#import "Core/NPEngineCore.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"

@implementation NPOpenGLView

- (void)clearRenderContext
{
    if( renderContext != nil )
    {
      [ renderContext disconnectFromView ];

      //DESTROY(glcontext);
    }
}

- (void)setRenderContext:(NPOpenGLRenderContext *)newRenderContext
{
    [ self clearRenderContext ];
    renderContext = newRenderContext;
  
    attached = NO;
}

/**
   return the current gl context associated with this view
*/
- (NPOpenGLRenderContext *)renderContext;
{
    if( renderContext == nil )
    {
        renderContext = [ [ [ NPEngineCore instance ] renderContextManager ] createRenderContextWithDefaultPixelFormatAndName:@"brak" ];

        [ renderContext connectToView: self];
        attached = YES;
    }

    return renderContext;
}


-(id) initWithFrame: (NSRect)frameRect
{
  [super initWithFrame: frameRect];

  [self setPostsFrameChangedNotifications: YES];

  [[NSNotificationCenter defaultCenter] 
    addObserver: self
    selector: @selector(_frameChanged:)
    name: NSViewFrameDidChangeNotification
    object: self];

  return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    RELEASE(renderContext);
    NSDebugMLLog(@"GL", @"deallocating");
    [super dealloc];
}

- (void) reshape
{
}

- (void) update
{
    [ renderContext update ];
}

- (void) _frameChanged: (NSNotification *) aNot
{
    NSDebugMLLog(@"GL", @"our frame has changed");
    [ self update ];
    [ self reshape ];
}

- (void) lockFocusInRect: (NSRect) aRect
{
    [super lockFocusInRect: aRect];

    if( !renderContext )
    {
      [self renderContext];
      NSAssert(renderContext, NSInternalInconsistencyException);
    }

    if (attached == NO && renderContext != nil)
    {
      NSDebugMLLog(@"GL", @"Attaching context to the view");
      [renderContext connectToView: self];
      attached = YES;
    }
}

@end
