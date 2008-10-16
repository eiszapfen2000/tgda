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

    transformationStates = [ [ NSMutableArray alloc ] init ];

    currentTransformationState = nil;

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(currentTransformationState);
    [ transformationStates release ];

    [ super dealloc ];
}

- (void) setup
{
    NPTransformationState * transformationState = [[ NPTransformationState alloc ] initWithName:@"" parent:self ];
    [ transformationStates addObject:transformationState ];
    [ self setCurrentTransformationState:transformationState ];
    [ transformationState release ];
}

- (NPTransformationState *) currentTransformationState
{
    return currentTransformationState;
}

- (void) setCurrentTransformationState:(NPTransformationState *)newCurrentTransformationState
{
    ASSIGN(currentTransformationState,newCurrentTransformationState);
}

@end
