#import "NPObject.h"

@interface NPLogger : NPObject
{
    NSFileHandle * logFile;
}
- (id) init;
- (void) dealloc;

- (void) write: (NSString *) string;

@end
