#import "NPPathManager.h"
#import "NPLocalPathManager.h"
#import "NPRemotePathManager.h"
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

    localPathManager = [ [ NPLocalPathManager alloc ] initWithName:@"NPEngine Local Path Manager" parent:self ];
    remotePathManager = [ [ NPRemotePathManager alloc ] initWithName:@"NPEngine Remote Path Manager" parent:self ];

    return self;
}

- (void) dealloc
{
    [ localPathManager release ];
    [ remotePathManager release ];

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

- (void) removeLookUpPath:(NSString *)lookUpPath
{
    NSString * standardizedLookUpPath = [ lookUpPath stringByStandardizingPath ];

    if ( isDirectory(standardizedLookUpPath) == YES )
    {
        [ localPathManager removeLookUpPath:standardizedLookUpPath ];
    }
    else if ( isURL(lookUpPath) == YES )
    {
        [ remotePathManager removeLookUpURL:[ NSURL URLWithString:lookUpPath ] ];
    }
}

- (NSString *) getAbsoluteFilePath:(NSString *)partialPath;
{
    return [ localPathManager getAbsoluteFilePath:partialPath ];
}

@end
