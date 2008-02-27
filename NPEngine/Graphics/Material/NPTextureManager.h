#import "Core/NPObject/NPObject.h"

@interface NPTextureManager : NPObject
{
    NSMutableDictionary * textures;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

- (id) loadTextureFromPath:(NSString *)path;

@end
