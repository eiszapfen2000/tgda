#import "Core/NPObject/NPObject.h"
#import "Core/NPObject/NPPCoreProtocols.h"

@interface NPLocalPathManager : NPObject < NPPInitialStateSetup >
{
    NSMutableArray * localPaths;
    NSFileManager * fileManager;
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (void) addLookUpPath:(NSString *)lookUpPath;

@end
