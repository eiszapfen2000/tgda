#import "Core/NPObject/NPObject.h"

@class NPLocalPathManager;
@class NPRemotePathManager;

@interface NPPathManager : NPObject
{
    NSFileManager * fileManager;

    NPLocalPathManager * localPathManager;
    NPRemotePathManager * remotePathManager;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) addLookUpPath:(NSString *)lookUpPath;
- (void) removeLookUpPath:(NSString *)lookUpPath;

- (NSString *) getAbsoluteFilePath:(NSString *)partialPath;

@end
