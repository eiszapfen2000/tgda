#import <Foundation/NSArray.h>
#import "Core/NPObject/NPObject.h"

@interface NPStringList : NPObject
{
    NSArray * lines;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

@end
