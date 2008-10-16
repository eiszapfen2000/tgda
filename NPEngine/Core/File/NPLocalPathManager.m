#import "NPLocalPathManager.h"
#import "NPPathUtilities.h"
#import "NP.h"

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

    fileManager = [ NSFileManager defaultManager ];
    localPaths = [[ NSMutableArray alloc ] init ];

    [ self addApplicationPath ];

    return self;
}

- (void) dealloc
{
    [ localPaths release ];

    [ super dealloc ];
}

- (void) addApplicationPath
{
    NSString * workingDirectory = [ fileManager currentDirectoryPath ];

    NPLOG(([NSString stringWithFormat:@"Adding application directory %@ to local paths", workingDirectory]));

    if ( workingDirectory != nil )
    {
        [ localPaths addObject:workingDirectory ];
    }
    else
    {
        NPLOG_ERROR(@"Working directory not accessible");
    }
}

- (void) addLookUpPath:(NSString *)lookUpPath
{
    [ localPaths addObject:lookUpPath ];
}

- (void) removeLookUpPath:(NSString *)lookUpPath
{
    [ localPaths removeObject:lookUpPath ];
}

- (NSString *) getAbsoluteFilePath:(NSString *)partialPath
{
    NSString * absolutePath;

    for ( Int i = 0; i < [ localPaths count ]; i++ )
    {
        absolutePath = [[[ localPaths objectAtIndex:i ] stringByAppendingPathComponent:partialPath ] retain ];

        if ( isFile(absolutePath) == YES )
        {
            return absolutePath;
        }
    }

    return @"";
}

@end

