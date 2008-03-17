#import "Core/NPObject/NPObject.h"

@class NPTextureBindingState;

@interface NPTextureBindingStateManager : NPObject
{
    NSMutableArray * textureBindingStates;
    NPTextureBindingState * currentTextureBindingState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NPTextureBindingState *)currentTextureBindingState;
- (void) setCurrentTextureBindingState:(NPTextureBindingState *)newCurrentTextureBindingState;

- (NPTextureBindingState *) createTextureBindingState;

@end
