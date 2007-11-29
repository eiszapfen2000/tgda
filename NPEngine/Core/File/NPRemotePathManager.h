#import "Core/NPObject/NPObject.h"
#import "Core/NPObject/NPPCoreProtocols.h"

@interface NPRemotePathManager : NPObject < NPPInitialStateSetup >
{
    NSMutableArray * remotePaths;
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (void) addURL:(NSURL *)lookUpURL;

@end
