#import "Core/NPObject/NPObject.h"
#import "Core/NPObject/NPPCoreProtocols.h"

@interface NPPathManager : NPObject < NPPInitialStateSetup >
{
    NSFileManager * fileManager;

    //Contains Strings
    NSMutableArray * localPaths;

    //Contains URLs
    NSMutableArray * remotePaths;
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (void) addLookUpPath:(NSString *)lookupPath;

- (void) _addApplicationPath;

@end
