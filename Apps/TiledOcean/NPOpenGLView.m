#import "NPOpenGLView.h"

#import "Core/NPEngineCore.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"

@implementation NPOpenGLView

- (NPOpenGLRenderContext *)renderContext;
{
    if( renderContext == nil )
    {
        renderContext = [ [ [ NPEngineCore instance ] renderContextManager ] createRenderContextWithDefaultPixelFormatAndName:@"brak" ];
        [ renderContext connectToView: self];
        [ renderContext activate ];
        [ renderContext setupGLEW ];
        //[ renderContext deactivate ];
        attached = YES;
    }

    return renderContext;
}

-(id) initWithFrame: (NSRect)frameRect
{
    [super initWithFrame: frameRect];

    [self setPostsFrameChangedNotifications: YES];

    [ [ NSNotificationCenter defaultCenter ] addObserver:self
                                                selector:@selector(frameChanged:)
                                                    name:NSViewFrameDidChangeNotification
                                                  object:self ];

    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    //RELEASE(renderContext);
    NSDebugMLLog(@"GL", @"deallocating");
    [super dealloc];
}

- (void) reshape
{
}

- (void) update
{
    if( [ renderContext context ] != [NSOpenGLContext currentContext] )
    {
        NSLog(@"update: BRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAK");
    }
    
    [ renderContext update ];
}

- (void) frameChanged:(NSNotification *)aNot
{
    if( [ renderContext context ] != [NSOpenGLContext currentContext] )
    {
        NS_DURING
            [ renderContext activate ];
            ///NSLog(@"framechanged context fuck");
            [ self update ];
            [ self reshape ];
        NS_HANDLER
            NSLog(@"Exception");
            NS_VOIDRETURN;
        NS_ENDHANDLER
    }
    else
    {
        NSLog(@"laalalaalalaalal");
        [ self update ];
        [ self reshape ];
    }
}

- (void) lockFocusInRect: (NSRect) aRect
{
    if( [ renderContext context ] != [NSOpenGLContext currentContext] )
    {
        NSLog(@"lock: BRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAK");
    }

    [super lockFocusInRect: aRect];

    if( !renderContext )
    {
      NSLog(@"rendercontext erstellen");
      renderContext = [self renderContext];
      NSAssert(renderContext, NSInternalInconsistencyException);
    }

    if (attached == NO && renderContext != nil)
    {
      NSLog(@"rendercontext connect view");
      NSDebugMLLog(@"GL", @"Attaching context to the view");
      [renderContext connectToView: self];
      attached = YES;
    }
}

@end
