#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <GNUstepGUI/GSServicesManager.h>

@interface NPApplication : NSApplication
{
    @private
    BOOL updateImplemented;
    BOOL renderImplemented;
}
- (void) run;
- (void) launch;
- (void) sendEvent:(NSEvent *)theEvent;

@end

int NPApplicationMain(int argc, const char **argv);
