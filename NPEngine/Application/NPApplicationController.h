#import <AppKit/AppKit.h>

@interface NPApplicationController : NSObject
{
    id window;
    id windowController;
}

- (id) init;
- (void) createRenderWindow;

@end
