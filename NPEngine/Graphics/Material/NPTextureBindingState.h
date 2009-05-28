#import "Core/NPObject/NPObject.h"

@class NPTexture;

@interface NPTextureBindingState : NPObject
{
    NSMutableDictionary * textureBindings;
    NSMutableArray * textureUnits;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) clear;

- (id) textureForKey:(NSString *)colormapSemantic;
- (void) setTexture:(id)texture forKey:(NSString *)colormapSemantic;
- (void) setTexture:(id)texture forTexelUnit:(Int32)texelUnit;
- (void) deactivateTexelUnitForTexture:(id)texture;

@end
