#import <AppKit/AppKit.h>

#import "ODApplicationController.h"
#import "ODWindowController.h"
#import "ODOpenGLView.h"
#import "ODDemo.h"

#import "NP.h"

#import <unistd.h>

@implementation ODApplicationController

- (id) init
{
    self = [ super init ];

    window = nil;
    windowController = nil;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [ NP Core ];

    NSDictionary * settings = [ NSDictionary dictionaryWithContentsOfFile:@"settings.plist" ];
    BOOL fullscreen = [[ settings objectForKey:@"Fullscreen" ] boolValue ];
    Int width = [[ settings objectForKey:@"Width" ] intValue ];
    Int height = [[ settings objectForKey:@"Height" ] intValue ];

    NSRect windowRect;
    NSUInteger styleMask;
    NSInteger windowLevel;

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

    windowController = [[ ODWindowController alloc ] init ];
    [ window setDelegate:windowController ];

    [ window setLevel: windowLevel ];
    [ window setBackgroundColor:[NSColor clearColor]];
    [ window setReleasedWhenClosed:YES ];
    [ window makeKeyAndOrderFront:nil ];

    ODOpenGLView * view = [[ ODOpenGLView alloc ] initWithFrame:windowRect ];
    [ window setContentView:view ];
    [ view setup ];
    [ view update ];
    [ view release ];

    ODScene * scene = [[ ODScene alloc ] init ];
    [ scene setup ];

    ODDemo * demo = [ ODDemo instance ];
    [ demo setCurrentScene:scene ];
    [ scene release ];

    [ window makeFirstResponder:view ];

    [ demo setupRenderLoop ];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSLog(@"brak");
    [ NSApp setDelegate:nil ];
    //[ self autorelease ];
}

@end
