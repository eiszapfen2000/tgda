#import "NPPathManager.h"
#import "NPPathUtilities.h"
#import "Core/NPEngineCore.h"

@implementation NPPathManager

- (id) init
{
    return [ self initWithName:@"NPEngine Pathmanager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    fileManager = [ NSFileManager defaultManager ];

    //localPaths = [ [ NSMutableArray alloc ] init ];
    localPathManager = [ [ NPLocalPathManager alloc ] initWithName:@"NPEngine Local Path Manager" parent:self ];

    //remotePaths = [ [ NSMutableArray alloc ] init ];
    remotePathManager = [ [ NPRemotePathManager alloc ] initWithName:@"NPEngine Remote Path Manager" parent:self ];

    return self;
}

- (void) dealloc
{
    [ localPathManager release ];

    [ super dealloc ];
}

- (void) setup
{
    [ localPathManager setup ];
    //[ remotePathManager setup ];
}

- (void) addLookUpPath:(NSString *)lookUpPath
{
    NSString * standardizedLookUpPath = [ lookUpPath stringByStandardizingPath ];
    NPLOG(([ NSString stringWithFormat:@"%@ expand to %@", lookUpPath, standardizedLookUpPath ]));

    if ( isDirectory(standardizedLookUpPath) == YES )
    {
        [ localPathManager addLookUpPath:standardizedLookUpPath ];
        NPLOG(([ NSString stringWithFormat:@"%@ added to lookup paths", standardizedLookUpPath ]));
    }
    else if ( isURL(lookUpPath) == YES )
    {
        [ remotePathManager addLookUpURL:[ NSURL URLWithString:lookUpPath ] ];
        NPLOG(([ NSString stringWithFormat:@"%@ added to lookup URLs", lookUpPath ]));
    }
    else
    {
        NPLOG(([NSString stringWithFormat:@"%@ is not a valid directory or URL", lookUpPath ]));
    }
}

@end
