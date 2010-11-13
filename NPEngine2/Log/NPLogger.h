#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSError.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSArray.h>

@interface NPLogger : NSObject
{
    NSString * fileName;
    NSFileHandle * logFile;
    NSMutableArray * prefixes;
    NSString * prefixString;
}

+ (NPLogger *) instance;

- (id) init;
- (void) dealloc;

- (void) pushPrefix:(NSString *)prefix;
- (void) popPrefix;

- (void) write:(NSString *)string;
- (void) writeWarning:(NSString *)string;
- (void) writeError:(NSError *)error;

@end
