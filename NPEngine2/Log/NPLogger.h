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
- (void) writeErrorString:(NSString *)errorString;

@end

#define NPLOG(_logmessage,args...)         [[ NPLogger instance ] write:[ NSString stringWithFormat:_logmessage, ## args]]
#define NPLOG_WARNING(_logmessage,args...) [[ NPLogger instance ] writeWarning:[ NSString stringWithFormat:_logmessage, ## args]]
#define NPLOG_ERROR(_error)                [[ NPLogger instance ] writeError:_error ]

#define NPLOG_ERROR_STRING(_logmessage,args...) \
[[ NPLogger instance ] writeErrorString:[ NSString stringWithFormat:_logmessage, ## args]]

#define NPLOG_PUSH_PREFIX(_prefix)         [[ NPLogger instance ] pushPrefix:_prefix ];
#define NPLOG_POP_PREFIX()                 [[ NPLogger instance ] popPrefix ];
