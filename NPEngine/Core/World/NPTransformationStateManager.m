#import "NPTransformationStateManager.h"

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
    [ transformationStates release ];

    [ super dealloc ];
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
