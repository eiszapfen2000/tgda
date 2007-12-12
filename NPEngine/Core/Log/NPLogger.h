#import "Core/NPObject/NPObject.h"
#import "Core/NPObject/NPPCoreProtocols.h"

@interface NPLogger : NPObject
{
    NSString * fileName;
    NSString * pathToHome;
    NSFileHandle * logFile;
}
- (id) init;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent fileName:(NSString *)newFileName;
- (void) dealloc;

- (NSString *) fileName;
- (void) setFileName: (NSString *) newFileName;

- (void) write: (NSString *) string;
- (void) writeWarning: (NSString *) string;
- (void) writeError: (NSString *) string;

- (void) _setupFileHandle;

@end
