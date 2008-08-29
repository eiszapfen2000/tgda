#import "ODWindowController.h"
#import "ODOpenGLView.h"
#import "Core/NPEngineCore.h"


@implementation ODWindowController

- (void) setupRenderLoopInView:(id)view
{
    timer = [ NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                                  target:view
                                                selector:@selector(updateAndRender:)
                                                userInfo:nil
                                                 repeats:YES ];
}

- (void) windowWillClose:(NSNotification *)aNotification
{
    id window = [ aNotification object ];
    [ (ODOpenGLView *)[ window contentView ] shutdown ];
    [[ window contentView ] release ];
    [ window setDelegate:nil ];

    [[ NPEngineCore instance ] dealloc ];

    [ self autorelease ];
}

- (void) windowDidBecomeKey:(NSNotification *)aNotification
{
    NSLog(@"key");
}

- (void) windowDidBecomeMain:(NSNotification *)aNotification
{
    NSLog(@"main");
}

- (void) windowDidUpdate:(NSNotification *)aNotification
{
    NSLog(@"update");
}

@end
