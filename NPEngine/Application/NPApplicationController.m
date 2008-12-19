#import "NPApplicationController.h"
#import "NP.h"

@implementation NPApplicationController

- (id) init
{
    self = [ super init ];

    window = nil;
    windowController = nil;

    return self;
}

- (void) createRenderWindow
{
    // Initialise NPEngine Core
    [ NP Core ];
    [ NP Input ];

    // Load settings from Info-gnustep.plist
    id infoDictionary = [[ NSBundle mainBundle ] infoDictionary ];
    BOOL fullscreen = [[ infoDictionary objectForKey:@"Fullscreen" ] boolValue ];
    Int width       = [[ infoDictionary objectForKey:@"Width"  ] intValue ];
    Int height      = [[ infoDictionary objectForKey:@"Height" ] intValue ];

    NSRect windowRect;
    NSUInteger styleMask;
    NSInteger windowLevel;

    // If fullscreen, create a window the entire size of the screen
    if ( fullscreen == YES )
    {
        windowRect = [[ NSScreen mainScreen ] frame ];
        styleMask = NSBorderlessWindowMask;
        windowLevel = NSFloatingWindowLevel;
    }
    else
    {
        windowRect = NSMakeRect(100,100,width,height);
        styleMask = NSTitledWindowMask;
        windowLevel = NSModalPanelWindowLevel;
    }

    window = [[NSWindow alloc] initWithContentRect:windowRect
                                         styleMask:styleMask
                                           backing:NSBackingStoreNonretained
                                             defer:NO
                                            screen:[NSScreen mainScreen]];

    // The window controller's job is to close the window properly, that means
    // deactivating the rendercontext and shutting down the engine
    windowController = [[ NPWindowController alloc ] init ];
    [ window setDelegate:windowController ];

    [ window setLevel:windowLevel ];
    [ window setBackgroundColor:[NSColor clearColor]];
    [ window setReleasedWhenClosed:YES ];
    [ window makeKeyAndOrderFront:nil ];

    // Create the opengl view which contains the rendering context
    NPOpenGLView * view = [[ NPOpenGLView alloc ] initWithFrame:windowRect ];
    [ window setContentView:view ];

    // Set up opengl view (creates rendercontext and starts NPGraphics)
    [ view setup ];

    // Sync opengl view with its context
    [ view update ];
    [ view release ];

    [ window makeFirstResponder:view ];
    [ window setIgnoresMouseEvents:YES ];
}

@end
