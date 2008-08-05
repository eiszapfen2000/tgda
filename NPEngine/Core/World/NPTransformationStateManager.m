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

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    transformationStates = [ [ NSMutableArray alloc ] init ];

    currentActiveTransformationState = nil;

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(currentActiveTransformationState);
    [ transformationStates release ];

    [ super dealloc ];
}

- (void) setup
{
    NPTransformationState * transformationState = [[ NPTransformationState alloc ] initWithName:@"" parent:self ];
    [ transformationStates addObject:transformationState ];
    [ self setCurrentActiveTransformationState:transformationState ];
    [ transformationState release ];
}

- (NPTransformationState *) currentActiveTransformationState
{
    return currentActiveTransformationState;
}

- (void) setCurrentActiveTransformationState:(NPTransformationState *)newCurrentActiveTransformationState
{
    if ( currentActiveTransformationState != newCurrentActiveTransformationState )
    {
        [ currentActiveTransformationState release ];
        currentActiveTransformationState = [ newCurrentActiveTransformationState retain ];
    }
}

@end
