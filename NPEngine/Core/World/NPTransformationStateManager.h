#import "Core/NPObject/NPObject.h"
#import "NPTransformationState.h"

@interface NPTransformationStateManager : NPObject
{
    NSMutableArray * transformationStates;
    NPTransformationState * currentActiveTransformationState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NPTransformationState *) currentActiveTransformationState;
- (void) setCurrentActiveTransformationState:(NPTransformationState *)newCurrentActiveTransformationState;

@end
