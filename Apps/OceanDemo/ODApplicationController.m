#import <AppKit/AppKit.h>

#import "ODApplicationController.h"
#import "ODWindowController.h"
#import "ODOpenGLView.h"

#import "Core/NPEngineCore.h"

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
    [ NPEngineCore instance ];

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
        windowLevel = NSNormalWindowLevel;
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
    [ view release ];
    [ view setup ];
    [ view update ];

    [ windowController setupRenderLoopInView:view ];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    NSLog(@"app should terminate");
    return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSLog(@"will terminate");
    [ NSApp setDelegate:nil ];
    [ self autorelease ];
}

@end
