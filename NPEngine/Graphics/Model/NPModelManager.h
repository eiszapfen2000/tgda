#import "Core/NPObject/NPObject.h"

@interface NPModelManager : NPObject
{
    NSMutableDictionary * models;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (id) loadModelFromPath:(NSString *)path;

@end
