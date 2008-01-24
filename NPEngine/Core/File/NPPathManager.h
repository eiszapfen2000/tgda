#import "Core/NPObject/NPObject.h"
#import "NPLocalPathManager.h"
#import "NPRemotePathManager.h"

@interface NPPathManager : NPObject
{
    NSFileManager * fileManager;

    //Contains Strings
    //NSMutableArray * localPaths;
    NPLocalPathManager * localPathManager;

    //Contains URLs
    NPRemotePathManager * remotePathManager;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) addLookUpPath:(NSString *)lookUpPath;

@end
