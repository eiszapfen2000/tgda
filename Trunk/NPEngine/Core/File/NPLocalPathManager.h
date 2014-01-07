#import "Core/NPObject/NPObject.h"

@interface NPLocalPathManager : NPObject
{
    NSMutableArray * localPaths;
    NSFileManager * fileManager;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) addApplicationPath;
- (void) addLookUpPath:(NSString *)lookUpPath;
- (void) removeLookUpPath:(NSString *)lookUpPath;

- (NSString *) getAbsoluteFilePath:(NSString *)partialPath;

@end
