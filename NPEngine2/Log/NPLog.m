#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import "NPLog.h"

static NPLog * NP_ENGINE_LOG = nil;

@implementation NPLog

+ (void) initialize
{
	if ( [ NPLog class ] == self )
	{
		[[ self alloc ] init ];
	}
}

+ (NPLog *) instance
{
    return NP_ENGINE_LOG;
}

+ (id) allocWithZone:(NSZone*)zone
{
    if ( self != [ NPLog class ] )
    {
        [ NSException raise:NSInvalidArgumentException
	                 format:@"Illegal attempt to subclass NPLog as %@", self ];
    }

    if ( NP_ENGINE_LOG == nil )
    {
        NP_ENGINE_LOG = [ super allocWithZone:zone ];
    }

    return NP_ENGINE_LOG;
}

- (id) init
{
    self = [ super init ];

    sync = [[ NSRecursiveLock alloc ] init ];
    loggers = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ loggers removeAllObjects ];
    DESTROY(loggers);
    DESTROY(sync);

    [ super dealloc ];
}

- (void) addLogger:(id <NPPLogger>)logger
{
    [ sync lock ];
    [ loggers addObject:logger ];
    [ sync unlock ];
}

- (void) removeLogger:(id <NPPLogger>)logger
{
    [ sync lock ];
    [ loggers removeObjectIdenticalTo:logger ];
    [ sync unlock ];
}

- (void) logMessage:(NSString *)message
{
    [ sync lock ];

    NSUInteger numberOfLoggers = [ loggers count ];
    for ( NSUInteger i = 0; i < numberOfLoggers; i++ )
    {
        [[ loggers objectAtIndex:i ] logMessage:message ];
    }

    [ sync unlock ];
}

- (void) logWarning:(NSString *)warning
{
    [ sync lock ];

    NSUInteger numberOfLoggers = [ loggers count ];
    for ( NSUInteger i = 0; i < numberOfLoggers; i++ )
    {
        [[ loggers objectAtIndex:i ] logWarning:warning ];
    }

    [ sync unlock ];
}

- (void) logError:(NSError *)error
{
    [ sync lock ];

    NSUInteger numberOfLoggers = [ loggers count ];
    for ( NSUInteger i = 0; i < numberOfLoggers; i++ )
    {
        [[ loggers objectAtIndex:i ] logError:error ];
    }

    [ sync unlock ];
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
