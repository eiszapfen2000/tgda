#import "Core/NPObject/NPObject.h"

@interface NPLocalPathManager : NPObject
{
    NSMutableArray * localPaths;
    NSFileManager * fileManager;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) addLookUpPath:(NSString *)lookUpPath;
- (void) setup;

@end
