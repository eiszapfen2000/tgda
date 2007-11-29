#import "NPLocalPathManager.h"

@implementation NPLocalPathManager

- (id) init
{
    return [ self initWithName:@"NPEngine Local Paths Manager" parent:nil ];
}
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    localPaths = [ [ NSMutableArray alloc ] init ];
    fileManager = [ NSFileManager defaultManager ];

    return self;
}

- (void) _addApplicationPath
{
    [ localPaths addObject: [ fileManager currentDirectoryPath ] ];
}

- (void) setupInitialState
{
    [ self _addApplicationPath ];
}

- (void) addLookUpPath:(NSString *)lookUpPath
{
    NSString * expandedPath = [ [ lookUpPath stringByStandardizingPath ] retain ];

    BOOL isDirectory;    

    if ( [ fileManager fileExistsAtPath:expandedPath isDirectory:&isDirectory ] )
    {
        if ( isDirectory == YES )
        {
            [ localPaths addObject: expandedPath ];
        }
        else
        {
            NSLog(@"%@ is not a directory", expandedPath);
        }
    }

    [ expandedPath release ];
}

@end

