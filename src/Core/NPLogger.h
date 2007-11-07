#import "NPObject.h"

@interface NPLogger : NPObject
{
    NSString * fileName;
    NSString * pathToHome;
    NSFileHandle * logFile;
}
- (id) init;
- (id) initWithName:(NSString *) newName fileName:(NSString *) newFileName;
- (void) dealloc;

- (NSString *) fileName;
- (void) setFileName: (NSString *) newFileName;

- (void) write: (NSString *) string;
- (void) writeWarning: (NSString *) string;
- (void) writeError: (NSString *) string;

@end
