#import <Foundation/NSBundle.h>
#import <Foundation/NSFileManager.h>
#import "Log/NPLog.h"
#import "NSFileManager+NPEngine.h"
#import "NPLocalPathManager.h"

@implementation NPLocalPathManager

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    localPaths = [[ NSMutableArray alloc ] init ];
    [ self addApplicationPath ];

    return self;
}

- (void) dealloc
{
    [ localPaths removeAllObjects ];
    DESTROY(localPaths);

    [ super dealloc ];
}

- (void) addApplicationPath
{
    NSString * pathToExecutable = [[ NSBundle mainBundle ] executablePath ];
    NSString * executableFolder = [ pathToExecutable stringByDeletingLastPathComponent ];

    NPLOG(@"%@: Adding application directory %@ to local paths", name, executableFolder);
    [ localPaths addObject:executableFolder ];

    NSString * workingDirectory = [[ NSFileManager defaultManager ] currentDirectoryPath ];
    if ( workingDirectory != nil )
    {
        NPLOG(@"%@: Adding working directory %@ to local paths", name, workingDirectory);
        [ localPaths addObject:workingDirectory ];
    }
}

- (void) addLookUpPath:(NSString *)lookUpPath
{
    if ( [[ NSFileManager defaultManager ] isDirectory:lookUpPath ] == YES )
    {
        NPLOG(@"%@: Adding %@", name, lookUpPath);
        [ localPaths addObject:lookUpPath ];
    }
    else
    {
        NPLOG(@"%@: %@ is not a directory", name, lookUpPath);
    }
}

- (void) removeLookUpPath:(NSString *)lookUpPath
{
    NPLOG(@"%@: Removing %@", name, lookUpPath);
    [ localPaths removeObject:lookUpPath ];
}

- (NSString *) getAbsolutePath:(NSString *)partialPath
{
    // standardize path
    NSString * standardizedPath = [ partialPath stringByStandardizingPath ];

    // either empty path or error while trying to standardize path
    if ( [ standardizedPath length ] == 0 || standardizedPath == partialPath)
    {
        return nil;
    }

    // check if standardizedPath is an absolute path
    if ( [ standardizedPath isAbsolutePath ] == YES )
    {
        // standardizedPath is an absolute path, now we must check if it
        // actually exists
        if ( [[ NSFileManager defaultManager ] fileExistsAtPath:standardizedPath ] == YES )
        {
            return standardizedPath;
        }
        else
        {
            return nil;
        }
    }
    // standardizedPath is a relative path
    else
    {
        NSString * absolutePath = nil;

        for ( NSUInteger i = 0; i < [ localPaths count ]; i++ )
        {
            absolutePath = [[ localPaths objectAtIndex:i ] stringByAppendingPathComponent:standardizedPath ];
            if ( [[ NSFileManager defaultManager ] fileExistsAtPath:absolutePath ] == YES )
            {
                return absolutePath;
            }
        }
    }

    return nil;
}

@end

