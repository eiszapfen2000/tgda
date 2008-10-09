#import "ODWindowController.h"
#import "ODOpenGLView.h"
#import "ODScene.h"
#import "ODDemo.h"
#import "Core/NPEngineCore.h"


@implementation ODWindowController

- (void) windowWillClose:(NSNotification *)aNotification
{
    id window = [ aNotification object ];
    [ (ODOpenGLView *)[ window contentView ] shutdown ];
    //[[ window contentView ] release ];
    [ window setDelegate:nil ];

    [[ ODDemo instance ] dealloc ];
    [[ NPEngineCore instance ] dealloc ];

    //[ self autorelease ];
}

- (void) windowDidBecomeKey:(NSNotification *)aNotification
{
    //NSLog(@"key");
}

- (void) windowDidBecomeMain:(NSNotification *)aNotification
{
    //NSLog(@"main");
}

/*- (void) windowDidUpdate:(NSNotification *)aNotification
{
    NSLog(@"update");
}*/

- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize
{
    //NSLog(@"willresize");
    return proposedFrameSize;
}

@end
