#import <Foundation/NSString.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
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

    if ( fileName == nil )
    {
        logFile = RETAIN([ NSFileHandle fileHandleWithStandardOutput ]);
    }
    else
    {
        BOOL fileCreated = [[ NSFileManager defaultManager ] 
                                createFileAtPath:fileName
                                        contents:nil
                                      attributes:nil ];

        if ( fileCreated == YES )
        {
            logFile = RETAIN([ NSFileHandle fileHandleForWritingAtPath:fileName ]);
        }
        else
        {
            logFile = RETAIN([ NSFileHandle fileHandleWithStandardOutput ]);
        }
    }

    return self;
}

- (void) dealloc
{
    [ logFile closeFile ];
    DESTROY(logFile);

    [ super dealloc ];
}

- (void) logMessage:(NSString *)message
{
    NSString * string = [ message stringByAppendingString:@"\r\n"];
    NSData * data = [ string dataUsingEncoding:NSASCIIStringEncoding 
                          allowLossyConversion:YES ];

    [ logFile writeData:data  ];
}

- (void) logWarning:(NSString *)warning
{
    [ self logMessage:[ @"[WARNING]: " stringByAppendingString:warning ]];
}

- (void) logError:(NSError *)error
{
    NSAssert(error != nil, @"Invalid NSError object");

    [ self logMessage:[ NSString stringWithFormat:@"[Error]: %@ %ld %@",
        [ error domain ], [ error code ], [ error localizedDescription ]]];
}

@end
