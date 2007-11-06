#import "NPObject.h"

@interface NPLogger : NPObject
{
    NSFileHandle * logFile;
}
- (id) init;
- (void) dealloc;

- (void) write: (NSString *) string;
- (void) writeWarning: (NSString *) string;
- (void) writeError: (NSString *) string;

@end
