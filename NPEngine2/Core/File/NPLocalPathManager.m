#import <Foundation/NSFileManager.h>
#import "Log/NPLog.h"
#import "NSFileManager+NPEngine.h"
#import "NPLocalPathManager.h"

@implementation NPLocalPathManager

- (id) init
{
    return [ self initWithName:@"NPEngine Local Paths Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

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
    NSString * workingDirectory =
        [[ NSFileManager defaultManager ] currentDirectoryPath ];

    NPLOG(@"%@: Adding application directory %@ to local paths", name, workingDirectory);

    if ( workingDirectory != nil )
    {
        [ localPaths addObject:workingDirectory ];
    }
    else
    {
        //NPLOG_ERROR_STRING(@"%@: Working directory not accessible", name);
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

- (NSString *) getAbsoluteFilePath:(NSString *)partialPath
{
    NSString * absolutePath;

    for ( NSUInteger i = 0; i < [ localPaths count ]; i++ )
    {
        absolutePath = [[ localPaths objectAtIndex:i ] stringByAppendingPathComponent:partialPath ];
        if ( [[ NSFileManager defaultManager ] isFile:absolutePath ] == YES )
        {
            return absolutePath;
        }
    }

    return [ NSString string ];
}

@end

