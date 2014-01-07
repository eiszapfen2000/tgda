#import "NPTransformationStateManager.h"
#import "NPTransformationState.h"

@implementation NPTransformationStateManager

- (id) init
{
    return [ self initWithName:@"NPEngine Core Transformation State Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    transformationStates = [[ NSMutableArray alloc ] init ];

    NPTransformationState * transformationState = [[ NPTransformationState alloc ] initWithName:@"Default Transformation State" parent:self ];
    [ transformationStates addObject:transformationState ];
    currentTransformationState = [ transformationState retain ];
    [ transformationState release ];

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(currentTransformationState);
    [ transformationStates release ];

    [ super dealloc ];
}

- (NPTransformationState *) currentTransformationState
{
    return currentTransformationState;
}

- (void) setCurrentTransformationState:(NPTransformationState *)newCurrentTransformationState
{
    ASSIGN(currentTransformationState,newCurrentTransformationState);
}

- (void) resetCurrentTransformationState
{
    [ currentTransformationState reset ];
}

- (void) resetCurrentModelMatrix
{
    [ currentTransformationState resetModelMatrix ];
}

- (void) resetCurrentViewMatrix
{
    [ currentTransformationState resetViewMatrix ];
}

- (void) resetCurrentProjectionMatrix
{
    [ currentTransformationState resetProjectionMatrix ];
}

@end
