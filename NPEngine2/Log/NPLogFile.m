#import <Foundation/NSString.h>
#import <Foundation/NSError.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import "NPLogFile.h"

@implementation NPLogFile

- (id) init
{
    NSString * logFileName = 
        [[ NSHomeDirectory() stringByStandardizingPath ]
              stringByAppendingPathComponent:@"np.log" ];

    return [ self initWithFileName:logFileName ];

}

- (id) initWithFileName:(NSString *)fileName
{
    self = [ super init ];

    if ( [[ NSFileManager defaultManager ] 
                createFileAtPath:fileName
                        contents:nil
                      attributes:nil ] == YES )
    {
        logFile = RETAIN([ NSFileHandle fileHandleForWritingAtPath:fileName ]);
    }
    else
    {
        logFile = RETAIN([ NSFileHandle fileHandleWithStandardOutput ]);
    }

    return self;
}

- (void) dealloc
{
    [ logFile synchronizeFile ];
    [ logFile closeFile ];
    DESTROY(logFile);

    [ super dealloc ];
}

- (void) logMessage:(NSString *)message
{
    NSString * string = [ NSString stringWithFormat:@"%@\n", message ];
    NSData * data = [ string dataUsingEncoding:NSUTF8StringEncoding 
                          allowLossyConversion:NO ];

    [ logFile writeData:data  ];
    [ logFile synchronizeFile ];
}

- (void) logWarning:(NSString *)warning
{
    [ self logMessage:[ @"[WARNING]: " stringByAppendingString:warning ]];
}

- (void) logError:(NSError *)error
{
    [ self logMessage:[ NSString stringWithFormat:@"[Error]: %@ %ld %@",
        [ error domain ], [ error code ], [ error localizedDescription ]]];
}

@end
