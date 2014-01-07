#import <Foundation/NSArray.h>
#import "Core/NPObject/NPObject.h"

@interface NPLocalPathManager : NPObject
{
    NSMutableArray * localPaths;
}

- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) addApplicationPath;
- (void) addLookUpPath:(NSString *)lookUpPath;
- (void) removeLookUpPath:(NSString *)lookUpPath;

- (NSString *) getAbsolutePath:(NSString *)partialPath;

@end
