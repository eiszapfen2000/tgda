#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>

@interface NPApplicationController : NSObject
{
    id window;
    id windowController;
}

- (id) init;
- (void) createRenderWindow;

@end
