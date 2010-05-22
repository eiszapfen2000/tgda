#import "Core/NPObject/NPObject.h"

@class NPTexture;

@interface NPTextureBindingState : NPObject
{
    NSMutableDictionary * textureBindings;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (id) textureForKey:(NSString *)colormapSemantic;
- (void) setTexture:(id)texture forKey:(NSString *)colormapSemantic;

@end
