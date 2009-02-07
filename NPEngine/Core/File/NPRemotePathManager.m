#import "NPRemotePathManager.h"

@implementation NPRemotePathManager

- (id) init
{
    return [ self initWithName:@"NPEngine Remote Paths Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    remotePaths = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ remotePaths release ];

    [ super dealloc ];
}

- (void) addLookUpURL:(NSURL *)lookUpURL
{
    [ remotePaths addObject:lookUpURL ];
}

- (void) removeLookUpURL:(NSURL *)lookUpURL
{
    [ remotePaths removeObject:lookUpURL ];    
}

@end
