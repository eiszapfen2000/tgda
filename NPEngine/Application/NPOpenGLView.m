#import "NPOpenGLView.h"
#import "NP.h"

@implementation NPOpenGLView

-(id) initWithFrame:(NSRect)frameRect
{
    [ super initWithFrame: frameRect ];

    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) setup
{
    id infoDictionary = [[ NSBundle mainBundle ] infoDictionary ];
    Int sampleCount = [[ infoDictionary objectForKey:@"FSAA" ] intValue ];

    NPOpenGLPixelFormat * pixelFormat = [[ NPOpenGLPixelFormat alloc ] init ];
    [ pixelFormat setSampleCount:sampleCount ];

    renderContext = [[[[ NP Graphics ] renderContextManager ] createRenderContextWithPixelFormat:pixelFormat andName:@"NPOpenGLViewRC" ] retain ];
    [ renderContext connectToView:self ];
    [ renderContext activate ];
    [ renderContext setupGLEW ];

    [ pixelFormat release ];

    BOOL fullscreen = [[ infoDictionary objectForKey:@"Fullscreen" ] boolValue ];

    if ( fullscreen == NO )
    {
        /*[[ NSNotificationCenter defaultCenter ] addObserver:self
                                                   selector:@selector(frameChanged:)
                                                       name:NSViewFrameDidChangeNotification
                                                     object:self ];*/
    }

    [[ NP Graphics ] setup ];
    glXSwapIntervalSGI(1);
}

- (void) shutdown
{
    [ renderContext deactivate ];
    [ renderContext disconnectFromView ];
    [ renderContext release ];
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (void) update
{
    [ renderContext update ];
}

- (void) drawRect:(NSRect)aRect
{
}

@end
