#import "Core/NPObject/NPObject.h"

@interface ODEntityManager : NPObject
{
    id entities;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (id) loadEntityFromPath:(NSString *)path;
- (id) loadEntityFromAbsolutePath:(NSString *)path;

@end
