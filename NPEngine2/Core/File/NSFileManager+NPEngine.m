#import "NSFileManager+NPEngine.h"

@implementation NSFileManager ( NPEngine )

- (BOOL) isFile:(NSString *)path
{
    BOOL isDirectory;

    if ( [ self fileExistsAtPath:path isDirectory:&isDirectory ] == YES )
    {
        if ( isDirectory == NO )
        {
            return YES;
        }
    }

    return NO;
}

- (BOOL) isDirectory:(NSString *)path
{
    BOOL isDirectory;

    if ( [ self fileExistsAtPath:path isDirectory:&isDirectory ] == YES )
    {
        if ( isDirectory == YES )
        {
            return YES;
        }
    }

    return NO;
}

- (BOOL) isURL:(NSString *)path
{
    NSURL * url = [ NSURL URLWithString:path ];

    if ( url != nil )
    {
        return YES;
    }

    return NO;
}

- (BOOL) createEmptyFileAtPath:(NSString *)path
{
    return [ self createFileAtPath:path contents:nil attributes:nil ];
}

@end

