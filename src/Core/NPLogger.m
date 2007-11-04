#import "NPLogger.h"

@implementation NPLogger

- (id) init
{
    self = [ super initWithName: @"NPEngine Logger" ];

    NSString * path = [ @"~/np.txt" stringByExpandingTildeInPath ];

    [ [ NSFileManager defaultManager ] createFileAtPath:path contents:nil attributes:nil ];

    logFile = [ NSFileHandle fileHandleForWritingAtPath: path ];

    [ path release ];

    return self;    
}

- (void) dealloc
{
    [ logFile closeFile ];

    [ super dealloc ];
}

- (void) write: (NSString *) string
{
    NSString * line = [ string stringByAppendingString: @"\r\n" ]; 

    NSData * data = [ line dataUsingEncoding: NSUnicodeStringEncoding allowLossyConversion: NO ];

    [ logFile writeData: data ];
    [ logFile synchronizeFile ];

    [ data release ];
}

@end
