#import <Foundation/NSObject.h>
#import <Foundation/NSNotification.h>

@interface NPWindowController : NSObject

- (void) windowWillClose:(NSNotification *)aNotification;

@end
