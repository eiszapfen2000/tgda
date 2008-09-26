#import "Core/NPObject/NPObject.h"
#import "NPTransformationState.h"

@interface NPTransformationStateManager : NPObject
{
    NSMutableArray * transformationStates;
    NPTransformationState * currentTransformationState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

- (NPTransformationState *) currentTransformationState;
- (void) setCurrentTransformationState:(NPTransformationState *)newCurrentTransformationState;

@end
