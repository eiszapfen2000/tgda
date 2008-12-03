#import "NPWindowController.h"
#import "NPOpenGLView.h"
#import "NP.h"

@implementation NPWindowController

- (void) windowWillClose:(NSNotification *)aNotification
{
    id window = [ aNotification object ];

    [ (NPOpenGLView *)[ window contentView ] shutdown ];
    [ window setDelegate:nil ];

    [[ NP Input ] dealloc ];
    [[ NP Graphics ] dealloc ];
    [[ NP Core ] dealloc ];
}

@end
