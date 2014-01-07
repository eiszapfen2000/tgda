#import <Foundation/NSObject.h>
#import "NPPLogger.h"

@class NSFileHandle;

@interface NPLogFile : NSObject < NPPLogger >
{
    NSFileHandle * logFile;
}

- (id) init;
- (id) initWithFileName:(NSString *)fileName;
- (void) dealloc;

@end
