#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import "Core/Container/NSArray+NPPObject.h"
#import "NPInputAction.h"
#import "NPInputActions.h"

@implementation NPInputActions

- (id) init
{
    self = [ super initWithName:@"NP Engine Input Actions" ];

    inputActions = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ inputActions removeAllObjects ];
    DESTROY(inputActions);

    [ super dealloc ];
}

- (void) reset
{
    [ inputActions removeAllObjects ];
}

- (id) inputActionWithName:(NSString *)inputActionName
{
    return [ inputActions objectWithName:inputActionName ];
}

- (id) addInputActionWithName:(NSString *)inputActionName
                   inputEvent:(NpInputEvent)newInputEvent
{
    NPInputAction * inputAction =
        [ inputActions objectWithName:inputActionName ];

    NSAssert1(inputAction == nil,
        @"NPInputAction with Name %@ already exists", inputActionName);

    inputAction =
        [[ NPInputAction alloc ] initWithName:inputActionName
                                   inputEvent:newInputEvent ];

    [ inputActions addObject:inputAction ];

    return AUTORELEASE(inputAction);
}

- (void) removeInputActionWithName:(NSString *)inputActionName
{
    [ inputActions removeObjectWithName:inputActionName ];
}

- (void) removeInputAction:(id)inputAction
{
    [ inputActions removeObjectIdenticalTo:inputAction ];
}

- (void) update
{
   [ inputActions makeObjectsPerformSelector:@selector(update) ];
}

@end
