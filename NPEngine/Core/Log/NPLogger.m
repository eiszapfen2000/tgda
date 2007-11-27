#import "NPLogger.h"

@implementation NPLogger

- (id) init
{
    return [ self initWithName:@"NPCore Logger" parent:nil fileName:@"np.txt" ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent fileName:(NSString *)newFileName;
{
    self = [ super initWithName:newName parent:newParent ];

    pathToHome = [ NSHomeDirectory() retain ];
    fileName = [ newFileName retain ];
    logFile = nil;    

    return self;
}

- (void) dealloc
{
    [ fileName release ];
    [ pathToHome release ];
    [ logFile closeFile ];
    [ logFile release ];

    [ super dealloc ];
}

- (NSString *) fileName
{
    return fileName;
}

- (void) setFileName: (NSString *) newFileName
{
    if ( fileName != newFileName )
    {
        [ fileName release ];

        fileName = [ newFileName retain ];
    }
}

- (void) setup
{
    NSString * path = [ [ NSMutableString alloc ] initWithFormat: @"%@/%@", pathToHome, fileName ];

    if ( [ [ NSFileManager defaultManager ] createFileAtPath:path contents:nil attributes:nil ] == YES )
    {
        logFile = [ [ NSFileHandle fileHandleForWritingAtPath: path ] retain ];
    }
    else
    {
        logFile = [ [ NSFileHandle fileHandleWithStandardOutput ] retain ];
    }

    [ path release ];
}

- (void) write: (NSString *) string
{
    NSString * line = [ string stringByAppendingString: @"\r\n" ]; 

    NSData * data = [ line dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: NO ];

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
