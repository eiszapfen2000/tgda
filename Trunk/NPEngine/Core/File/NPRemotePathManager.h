#import "Core/NPObject/NPObject.h"

@interface NPRemotePathManager : NPObject
{
    NSMutableArray * remotePaths;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) addLookUpURL:(NSURL *)lookUpURL;
- (void) removeLookUpURL:(NSURL *)lookUpURL;

@end
