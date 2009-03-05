#import "NPLogger.h"

@implementation NPLogger

- (void) _setupFileHandle
{
    NSString * path = [ [ NSString alloc ] initWithFormat: @"%@/%@", pathToHome, fileName ];

    if ( logFile != nil )
    {
        [ logFile release ];
    }

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

- (id) init
{
    return [ self initWithName:@"NPCore Logger" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
{
    self = [ super initWithName:newName parent:newParent ];

    pathToHome = [ NSHomeDirectory() retain ];
    fileName = @"np.txt" ;
    prefixes = [[ NSMutableArray alloc ] init ];
    prefixString = @"";

    [ self _setupFileHandle ];

    return self;
}

- (void) dealloc
{
    [ prefixes removeAllObjects ];
    [ prefixes release ];
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

- (void) setFileName:(NSString *)newFileName
{
    if ( fileName != newFileName )
    {
        [ fileName release ];

        fileName = [ newFileName retain ];

        [ self _setupFileHandle ];
    }
}

- (void) updatePrefixString
{
    NSEnumerator * enumerator = [ prefixes objectEnumerator ];
    NSString * prefix = @"";
    NSString * tmp;

    while (( tmp = [ enumerator nextObject ] ))
    {
        prefix = [ prefix stringByAppendingString:tmp ];
    }

    prefixString = [ prefix retain ];
}

- (void) pushPrefix:(NSString *)prefix
{
    [ prefixes insertObject:prefix atIndex:0 ];

    [ self updatePrefixString ];
}

- (void) popPrefix
{
    [ prefixes removeObjectAtIndex:0 ];

    [ self updatePrefixString ];
}

- (void) write:(NSString *)string
{
    NSString * line = [[ prefixString stringByAppendingString:string ] stringByAppendingString: @"\r\n" ]; 

    NSData * data = [ line dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO ];

    [ logFile writeData:data ];
    [ logFile synchronizeFile ];
}

- (void) writeWarning:(NSString *)string
{
    [ self write:[ @"[WARNING]: " stringByAppendingString:string ]];
}

- (void) writeError:(NSString *)string
{
    [ self write:[ @"[ERROR]: " stringByAppendingString:string ]];
}

@end
