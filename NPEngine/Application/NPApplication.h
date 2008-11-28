#import <AppKit/AppKit.h>
#import <GNUstepGUI/GSServicesManager.h>

@interface NPApplication : NSApplication
{
    @private
    BOOL updateImplemented;
    BOOL renderImplemented;
}
- (void) run;
- (void) launch;

@end

int NPApplicationMain(int argc, const char **argv);
