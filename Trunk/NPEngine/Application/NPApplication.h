#import <Foundation/NSBundle.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSUserDefaults.h>
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
- (void) sendEvent:(NSEvent *)theEvent;

@end

int NPApplicationMain(int argc, const char **argv);
