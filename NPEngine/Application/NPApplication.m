#import <AppKit/NSNibLoading.h>
#import "NPApplication.h"
#import "NP.h"

@implementation NPApplication

- (void) run
{
    NSEvent * e;

    if (_runLoopPool != nil)
    {
        [ NSException raise:NSInternalInconsistencyException
                     format:@"NSApp's run called recursively" ];
    }

    if (_app_is_launched == NO)
    {
        _app_is_launched = YES;
        _runLoopPool = [ NSAutoreleasePool new ];

        [ self finishLaunching];

        // send notification to NPApplicationController
        [[ NSNotificationCenter defaultCenter ] postNotificationName:NSApplicationDidFinishLaunchingNotification
		                                                      object:self ];

        [ _listener updateServicesMenu ];
        [ _main_menu update ];

        if ( _delegate != nil )
        {
            updateImplemented = [ _delegate respondsToSelector:@selector(update) ];

            if ( updateImplemented == NO )
            {
                NPLOG_WARNING(@"Application delegate does not implement update");
            }

            renderImplemented = [ _delegate respondsToSelector:@selector(render) ];

            if ( renderImplemented == NO )
            {
                NPLOG_WARNING(@"Application delegate does not implement render");
            }
        }

        DESTROY(_runLoopPool);
    }

    _app_is_running = YES;

    while (_app_is_running)
    {
        _runLoopPool = [ NSAutoreleasePool new ];

        NSDate * now = [ NSDate date ];

        e = [ super nextEventMatchingMask:NSAnyEventMask
                                untilDate:now
                                   inMode:NSDefaultRunLoopMode
                                  dequeue:YES ];

        while ( e != nil )
        {
            NSEventType type = [ e type ];

            [ self sendEvent:e ];

            // update (en/disable) the services menu's items
            if (type != NSPeriodic && type != NSMouseMoved)
            {
                [ _listener updateServicesMenu ];
                [ _main_menu update ];
            }

            e = [ super nextEventMatchingMask:NSAnyEventMask
                        untilDate:now
                           inMode:NSDefaultRunLoopMode
                          dequeue:YES ];
        }

        // send an update message to all visible windows
        if ( _windows_need_update )
        {
            [ super updateWindows ];
        }

        if ( updateImplemented == YES )
        {
            [ _delegate update ];
        }

        if ( renderImplemented == YES )
        {
            [ _delegate render ];
        }

        DESTROY(_runLoopPool);
    }

    /* Every single non trivial line of code must be enclosed into an
     autorelease pool.  Create an autorelease pool here to wrap
     synchronize and the NSDebugLog.  */

    _runLoopPool = [ NSAutoreleasePool new ];
    [[ NSUserDefaults standardUserDefaults ] synchronize ];
    DESTROY(_runLoopPool);
}

- (void) sendEvent:(NSEvent *)theEvent
{
    NSEventType type = [ theEvent type ];
    switch (type)
    {
        case NSPeriodic:	/* NSApplication traps the periodic events	*/
            break;

        case NSKeyDown:
        {
            NSDebugLLog(@"NSEvent", @"send key down event\n");

            if ([[self mainMenu] performKeyEquivalent:theEvent] == NO
                && [[self keyWindow] performKeyEquivalent:theEvent] == NO)
            {
                [[ theEvent window ] sendEvent:theEvent ];
            }

            break;
        }

        case NSKeyUp:
        {
            NSDebugLLog(@"NSEvent", @"send key up event\n");
            //[[ theEvent window ] sendEvent:theEvent ];

            break;
        }

        default:	/* pass all other events to the event's window	*/
        {
            NSWindow * window = [ theEvent window ];

            if (!theEvent)
            {
                NSDebugLLog(@"NSEvent", @"NSEvent is nil!\n");
            }

            if (type == NSMouseMoved)
            {
                NSDebugLLog(@"NSMotionEvent", @"Send move (%d) to window %d", 
                            type, [window windowNumber]);
            }
            else
            {
                NSDebugLLog(@"NSEvent", @"Send NSEvent type: %d to window %d", 
                            type, [window windowNumber]);
            }

            if (window)
            {
                [ window sendEvent:theEvent];
            }
        }
    }

    if ( [ _delegate renderWindowActive ] == YES ) //&& [ _delegate renderWindowActivated ] == NO )
    {
        [[ NP Input ] processEvent:theEvent ];
    }
}

@end

int NPApplicationMain(int argc, const char **argv)
{
    /*
    NSDictionary * infoDictionary;
    NSString * className;
    Class appClass;
    CREATE_AUTORELEASE_POOL(pool);

    infoDictionary = [[ NSBundle mainBundle ] infoDictionary ];
    className = [ infoDictionary objectForKey:@"NSPrincipalClass" ];
    appClass = NSClassFromString(className);

    if (appClass == 0)
    {
        NSLog(@"Bad application class '%@' specified", className);
        appClass = [ NPApplication class ];
    }

    [ appClass sharedApplication ];
    [ (NPApplication *)NSApp launch ];

    [ NSApp run ];

    DESTROY(NSApp);
    RELEASE(pool);

    return 0;
    */

    NSDictionary * infoDictionary;
    NSString * mainModelFile;
    NSString * className;
    Class	appClass;
    CREATE_AUTORELEASE_POOL(pool);

#if defined(LIB_FOUNDATION_LIBRARY) || defined(GS_PASS_ARGUMENTS)
    extern char		**environ;

    [ NSProcessInfo initializeWithArguments:(char**)argv
                                    count:argc
		                      environment:environ ];
#endif

    infoDictionary = [[ NSBundle mainBundle ] infoDictionary ];
    className = [ infoDictionary objectForKey: @"NSPrincipalClass" ];
    appClass = NSClassFromString(className);

    if (appClass == 0)
    {
        NSLog(@"Bad application class '%@' specified", className);
        appClass = [ NSApplication class ];
    }

    [ appClass sharedApplication ];

    mainModelFile = [ infoDictionary objectForKey: @"NSMainNibFile" ];

    if (mainModelFile != nil && [mainModelFile isEqual:@""] == NO)
    {
        if ([NSBundle loadNibNamed:mainModelFile owner:NSApp] == NO)
        {
            NSLog (_(@"Cannot load the main model file '%@'"), mainModelFile);
        }
    }

    RECREATE_AUTORELEASE_POOL(pool);

    [NSApp run];

    DESTROY(NSApp);

    RELEASE(pool);

    return 0;
}
