#import "NPPathUtilities.h"

BOOL isFile(NSString * path)
{
    BOOL isDirectory;

    if ( [ [ NSFileManager defaultManager ] fileExistsAtPath:path isDirectory:&isDirectory ] == YES )
    {
        if ( isDirectory == NO )
        {
            return YES;
        }
    }

    return NO;
}

BOOL isDirectory(NSString * path)
{
    BOOL isDirectory;

    if ( [ [ NSFileManager defaultManager ] fileExistsAtPath:path isDirectory:&isDirectory ] == YES )
    {
        if ( isDirectory == YES )
        {
            return YES;
        }
    }

    return NO;
}

BOOL isURL(NSString * path)
{
    NSURL * url = [ NSURL URLWithString:path ];

    if ( url != nil )
    {
        return YES;
    }

    return NO;
}

