#import "Core/NPObject/NPObject.h"
#import "NPTransformationState.h"

@interface NPTransformationStateManager : NPObject
{
    NSMutableArray * transformationStates;
    NPTransformationState * currentTransformationState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NPTransformationState *) currentTransformationState;
- (void) setCurrentTransformationState:(NPTransformationState *)newCurrentTransformationState;

- (void) resetCurrentTransformationState;
- (void) resetCurrentModelMatrix;
- (void) resetCurrentViewMatrix;
- (void) resetCurrentProjectionMatrix;

@end
