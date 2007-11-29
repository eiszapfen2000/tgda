#import "NPRemotePathManager.h"

@implementation NPRemotePathManager

- (id) init
{
    return [ self initWithName:@"NPEngine Local Paths Manager" parent:nil ];
}
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    remotePaths = [ [ NSMutableArray alloc ] init ];

    return self;
}

- (void) addURL:(NSURL *)lookUpURL
{
    [ remotePaths addObject:lookUpURL ];
}

@end
