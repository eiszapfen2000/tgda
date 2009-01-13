#import <AppKit/NSOpenGL.h>
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

    NPOpenGLPixelFormat * pixelFormat = [[ NPOpenGLPixelFormat alloc ] initWithName:@"Application PixelFormat" parent:nil ];
    [ pixelFormat setSampleCount:sampleCount ];

    renderContext = [[[[ NP Graphics ] renderContextManager ] createRenderContextWithPixelFormat:pixelFormat andName:@"NPOpenGLViewRC" ] retain ];
    [ renderContext connectToView:self ];
    [ renderContext activate ];
    [ renderContext setupGLEW ];

    [ pixelFormat release ];

    NSRect rect = [ self bounds ];
    IVector2 viewport = { rect.size.width, rect.size.height };

    //NSLog(@"%f %f",rect.size.width,rect.size.height);

    [[ NP Graphics ] setupWithViewportSize:viewport ];
    glXSwapIntervalSGI(0);
}

- (void) shutdown
{
    [ renderContext deactivate ];
    [ renderContext disconnectFromView ];
    [ renderContext release ];
}

- (BOOL) acceptsFirstResponder
{
    return NO;
}

- (void) update
{
    [ renderContext update ];
}

@end
