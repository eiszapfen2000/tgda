#import "NPPathManager.h"

@implementation NPPathManager

- (id) init
{
    return [ self initWithName:@"NPEngine Pathmanager" parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    paths = [ [ NSMutableArray alloc ] init ];

    return self;
}

- (void) setupInitialState
{
    [ self _addApplicationPath ];
}

- (void) addLookUpPath:(NSString *)lookupPath
{
    [ paths addObject: lookupPath ];
}

- (void) _addApplicationPath
{
    [ paths addObject: [ [ NSFileManager defaultManager ] currentDirectoryPath ] ];
}

@end
