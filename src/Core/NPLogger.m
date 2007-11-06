#import "NPLogger.h"

@implementation NPLogger

- (id) init
{
    self = [ super initWithName: @"NPCore Logger" ];

    NSString * path = [ @"~/np.txt" stringByExpandingTildeInPath ];

    if ( [ [ NSFileManager defaultManager ] createFileAtPath:path contents:nil attributes:nil ] == YES )
    {
        logFile = [ NSFileHandle fileHandleForWritingAtPath: path ];

    }
    else
    {
        logFile = [ NSFileHandle fileHandleWithStandardOutput ];
    }

    [ path release ];

    return self;    
}

- (void) dealloc
{
    [ logFile closeFile ];

    [ super dealloc ];
}

- (void) setup
{
    [ self write: @"NPEngine Core Logger up and running" ];
}

- (void) write: (NSString *) string
{
    NSString * line = [ string stringByAppendingString: @"\r\n" ]; 

    NSData * data = [ line dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES ];

    [ logFile writeData: data ];
    [ logFile synchronizeFile ];
}

- (void) writeWarning: (NSString *) string
{
    [ self write: [ @"[WARNING]: " stringByAppendingString: string ] ];
}

- (void) writeError: (NSString *) string
{
    [ self write: [ @"[ERROR]: " stringByAppendingString: string ] ];
}

@end
