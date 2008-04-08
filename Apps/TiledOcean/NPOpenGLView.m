#import "NPOpenGLView.h"

#import "Core/NPEngineCore.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"

@implementation NPOpenGLView

- (NPOpenGLRenderContext *)renderContext;
{
    if ( renderContext == nil )
    {
        NSLog(@"create damn fucking render context");

        renderContext = [[[[ NPEngineCore instance ] renderContextManager ] createRenderContextWithDefaultPixelFormatAndName:@"brak" ] retain ];
        [ renderContext connectToView: self];
        [ renderContext activate ];
        [ renderContext setupGLEW ];

        attached = YES;
    }

    return renderContext;
}

-(id) initWithFrame:(NSRect)frameRect
{
    [ super initWithFrame: frameRect ];

    [ self setPostsFrameChangedNotifications: YES ];

    [[ NSNotificationCenter defaultCenter ] addObserver:self
                                               selector:@selector(frameChanged:)
                                                   name:NSViewFrameDidChangeNotification
                                                 object:self ];

    return self;
}

- (void) dealloc
{
    [[ NSNotificationCenter defaultCenter ] removeObserver: self];

    [ renderContext release ];

    [super dealloc];
}

- (void) reshape
{
}

- (void) update
{
    [ renderContext update ];
}

- (void) frameChanged:(NSNotification *)aNot
{
    NSLog(@"framchanged");
    if( [ renderContext context ] != [NSOpenGLContext currentContext] )
    {
        [ renderContext activate ];
        [ self reshape ];
        [ self update ];
    }
    else
    {
        [ self reshape ];
        [ self update ];
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

    NSLog(@"lock done");
}

@end
