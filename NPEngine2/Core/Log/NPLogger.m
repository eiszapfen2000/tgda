#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSFileManager.h>
#import "NPLogger.h"

@implementation NPLogger

- (void) setupFileHandle
{
    NSString * logFileName = [[ NSHomeDirectory() stringByStandardizingPath ]
                                    stringByAppendingPathComponent:@"np.log" ];

    if ( [[ NSFileManager defaultManager ] 
                createFileAtPath:logFileName
                        contents:nil
                      attributes:nil ] == YES )
    {
        logFile = RETAIN([ NSFileHandle fileHandleForWritingAtPath:logFileName ]);
    }
    else
    {
        logFile = RETAIN([ NSFileHandle fileHandleWithStandardOutput ]);
    }
}

- (id) init
{
    self = [ super init ];

    prefixes = [[ NSMutableArray alloc ] init ];
    prefixString = @"";

    [ self setupFileHandle ];

    return self;
}

- (void) dealloc
{
    [ prefixes removeAllObjects ];
    DESTROY(prefixes);
    [ logFile closeFile ];
    DESTROY(logFile);

    [ super dealloc ];
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

    ASSIGNCOPY(prefixString, prefix);
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
    NSString * line = 
        [[ prefixString stringByAppendingString:string ] stringByAppendingString: @"\r\n" ];

    NSData * data = 
        [ line dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO ];

    [ logFile writeData:data ];
    [ logFile synchronizeFile ];
}

- (void) writeWarning:(NSString *)string
{
    [ self write:[ @"[WARNING]: " stringByAppendingString:string ]];
}

- (void) writeError:(NSError *)error
{
    [ self write:[ @"[Error]: " stringByAppendingString:[ error description ]]];
}

@end
