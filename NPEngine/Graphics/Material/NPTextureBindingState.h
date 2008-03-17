#import "Core/NPObject/NPObject.h"

@class NPTexture;

@interface NPTextureBindingState : NPObject
{
    NSMutableDictionary * textureBindings;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NPTexture *) textureForKey:(NSString *)colormapSemantic;
- (void) setTexture:(NPTexture *)texture forKey:(NSString *)colormapSemantic;

@end
