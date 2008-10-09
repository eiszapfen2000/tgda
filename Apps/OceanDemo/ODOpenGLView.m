#import "ODOpenGLView.h"
#import "ODScene.h"
#import "ODDemo.h"

#import "Core/NPEngineCore.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"

@implementation ODOpenGLView

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
    NSDictionary * settings = [ NSDictionary dictionaryWithContentsOfFile:@"settings.plist" ];
    Int sampleCount = [[ settings objectForKey:@"FSAA" ] intValue ];

    NPOpenGLPixelFormat * pixelFormat = [[ NPOpenGLPixelFormat alloc ] init ];
    [ pixelFormat setSampleCount:sampleCount ];

    renderContext = [[[[ NPEngineCore instance ] renderContextManager ] createRenderContextWithPixelFormat:pixelFormat andName:@"NPOpenGLViewRC" ] retain ];
    [ renderContext connectToView:self ];
    [ renderContext activate ];
    [ renderContext setupGLEW ];

    [ pixelFormat release ];

    BOOL fullscreen = [[ settings objectForKey:@"Fullscreen" ] boolValue ];

    if ( fullscreen == NO )
    {
        /*[[ NSNotificationCenter defaultCenter ] addObserver:self
                                                   selector:@selector(frameChanged:)
                                                       name:NSViewFrameDidChangeNotification
                                                     object:self ];*/
    }

    [[ NPEngineCore instance ] setup ];
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

- (void)keyDown:(NSEvent *)theEvent
{
    NSString * key  = [theEvent charactersIgnoringModifiers];
    unichar keyChar = [key characterAtIndex:0];

    switch ( keyChar )
    {
        case 'w': { [[[ ODDemo instance ] currentScene ] activateForwardMovement ]; break; }
        case 's': { [[[ ODDemo instance ] currentScene ] activateBackwardMovement ]; break; }
        case 'a': { [[[ ODDemo instance ] currentScene ] activateStrafeLeft ]; break; }
        case 'd': { [[[ ODDemo instance ] currentScene ] activateStrafeRight ]; break; }

    }    
}

- (void)keyUp:(NSEvent *)theEvent
{
    NSString * key  = [theEvent charactersIgnoringModifiers];
    unichar keyChar = [key characterAtIndex:0];

    switch ( keyChar )
    {
        case 'w': { [[[ ODDemo instance ] currentScene ] deactivateForwardMovement ]; break; }
        case 's': { [[[ ODDemo instance ] currentScene ] deactivateBackwardMovement ]; break; }
        case 'a': { [[[ ODDemo instance ] currentScene ] deactivateStrafeLeft ]; break; }
        case 'd': { [[[ ODDemo instance ] currentScene ] deactivateStrafeRight ]; break; }

    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    //NSLog(@"mouseDown");
}

- (void)mouseUp:(NSEvent *)theEvent
{
    //NSLog(@"mouseUp");
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    //NSLog(@"mouseDragged %f %f",[theEvent deltaX],[theEvent deltaY]);
    [[[ ODDemo instance ] currentScene ] cameraRotateUsingYaw:[theEvent deltaX] andPitch:[theEvent deltaY] ];

}

- (void) update
{
    [ renderContext update ];
}

- (void) drawRect:(NSRect)aRect
{
}

@end
