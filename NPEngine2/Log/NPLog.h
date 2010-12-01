#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSError.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSArray.h>
#import "NPPLogger.h"

@interface NPLog : NSObject
{
    NSString * fileName;
    NSFileHandle * logFile;
    
    NSMutableArray* loggers;
}

+ (NPLog *) instance;

- (id) init;
- (void) dealloc;

- (void) addLogger:(id <NPPLogger>)logger;
- (void) removeLogger:(id <NPPLogger>)logger;

- (void) logMessage:(NSString *)message;
- (void) logWarning:(NSString *)warning;
- (void) logError:(NSError *)error;

@end

#define NPLOG(_logmessage,args...)         [[ NPLog instance ] logMessage:[ NSString stringWithFormat:_logmessage, ## args]]
#define NPLOG_WARNING(_logmessage,args...) [[ NPLog instance ] logWarning:[ NSString stringWithFormat:_logmessage, ## args]]
#define NPLOG_ERROR(_error)                [[ NPLog instance ] logError:_error ]

