#import "NPPathManager.h"

@implementation NPPathManager

- (id) init
{
    return [ self initWithName:@"NPEngine Pathmanager" parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    fileManager = [ NSFileManager defaultManager ];

    localPaths = [ [ NSMutableArray alloc ] init ];
    remotePaths = [ [ NSMutableArray alloc ] init ];

    return self;
}

- (void) setupInitialState
{
    [ self _addApplicationPath ];
}

- (void) addLookUpPath:(NSString *)lookupPath
{
    [ localPaths addObject: lookupPath ];
}

- (void) _addApplicationPath
{
    [ localPaths addObject: [ fileManager currentDirectoryPath ] ];
}

- (NSString *)description
{
    return [ NSString stringWithFormat: @"%@ %@",[localPaths description],[remotePaths description]];
}

@end
