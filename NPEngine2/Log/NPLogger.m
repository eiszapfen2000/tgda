#import <Foundation/NSException.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSFileManager.h>
#import "NPLogger.h"

static NPLogger * NP_ENGINE_LOGGER = nil;

@implementation NPLogger

+ (void) initialize
{
	if ( [ NPLogger class ] == self )
	{
		[[ self alloc ] init ];
	}
}

+ (NPLogger *) instance
{
    return NP_ENGINE_LOGGER;
}

+ (id) allocWithZone:(NSZone*)zone
{
    if ( self != [ NPLogger class ] )
    {
        [ NSException raise:NSInvalidArgumentException
	                 format:@"Illegal attempt to subclass NPLogger as %@", self ];
    }

    if ( NP_ENGINE_LOGGER == nil )
    {
        NP_ENGINE_LOGGER = [ super allocWithZone:zone ];
    }

    return NP_ENGINE_LOGGER;
}

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
    [ self write:[ @"[ERROR]: " stringByAppendingString:[ error description ]]];
}

- (void) writeErrorString:(NSString *)errorString
{
    [ self write:[ @"[ERROR]: " stringByAppendingString:errorString ]];
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return ULONG_MAX;
} 

- (void) release
{
    //do nothing
} 

- (id) autorelease
{
    return self;
}

@end
