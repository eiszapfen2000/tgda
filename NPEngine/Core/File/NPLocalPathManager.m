#import "NPLocalPathManager.h"
#import "Core/NPEngineCore.h"

@implementation NPLocalPathManager

- (id) init
{
    return [ self initWithName:@"NPEngine Local Paths Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    fileManager = [ NSFileManager defaultManager ];

    localPaths = [ [ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ localPaths release ];

    [ super dealloc ];
}

- (void) _addApplicationPath
{
    NSString * workingDirectory = [ fileManager currentDirectoryPath ];

    if ( workingDirectory != nil )
    {
        [ localPaths addObject:workingDirectory ];
    }
    else
    {
        NPLOG_ERROR(([ NSString stringWithFormat:@"Working directory not accessible" ]));
    }
}

- (void) setup
{
    [ self _addApplicationPath ];
}

- (void) addLookUpPath:(NSString *)lookUpPath
{
    [ localPaths addObject:lookUpPath ];
}

@end

