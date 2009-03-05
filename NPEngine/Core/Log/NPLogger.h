#import "Core/NPObject/NPObject.h"

@interface NPLogger : NPObject
{
    NSString * fileName;
    NSString * pathToHome;
    NSFileHandle * logFile;
    NSMutableArray * prefixes;
    NSString * prefixString;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NSString *) fileName;
- (void) setFileName:(NSString *)newFileName;

- (void) pushPrefix:(NSString *)prefix;
- (void) popPrefix;

- (void) write:(NSString *)string;
- (void) writeWarning:(NSString *)string;
- (void) writeError:(NSString *)string;

@end
