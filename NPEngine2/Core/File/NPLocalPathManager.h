#import <Foundation/NSArray.h>
#import "Core/NPObject/NPObject.h"

@interface NPLocalPathManager : NPObject
{
    NSMutableArray * localPaths;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) addApplicationPath;
- (void) addLookUpPath:(NSString *)lookUpPath;
- (void) removeLookUpPath:(NSString *)lookUpPath;

- (NSString *) getAbsolutePath:(NSString *)partialPath;

@end
