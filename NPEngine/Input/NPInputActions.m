#import "NPInputAction.h"
#import "NPInputActions.h"
#import "NP.h"

@implementation NPInputActions

- (id) init
{
    return [ self initWithName:@"NP Engine Input Actions" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    inputActions = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ inputActions removeAllObjects ];
    [ inputActions release ];

    [ super dealloc ];
}

- (void) reset
{
    [ inputActions removeAllObjects ];
}

- (id) inputActions
{
    return inputActions;
}

- (id) inputActionWithName:(NSString *)inputActionName
{
    return [ inputActions objectForKey:inputActionName ];
}

- (id) addInputActionWithName:(NSString *)inputActionName
             primaryInputAction:(NpState)primaryInputAction
{
    return [ self addInputActionWithName:inputActionName
                      primaryInputAction:primaryInputAction
                    secondaryInputAction:NP_INPUT_NONE ];
}

- (id) addInputActionWithName:(NSString *)inputActionName
             primaryInputAction:(NpState)primaryInputAction
           secondaryInputAction:(NpState)secondaryInputAction
{
    NPInputAction * inputAction = [ inputActions objectForKey:inputActionName ];
    if ( inputAction == nil )
    {
        inputAction = [[ NPInputAction alloc ] initWithName:inputActionName
                                                     parent:self
                                              primaryAction:primaryInputAction
                                            secondaryAction:secondaryInputAction ];

        [ inputActions setObject:inputAction forKey:inputActionName ];

        return [ inputAction autorelease ];
    }
    else
    {
        NPLOG_WARNING(@"Input Action with name %@ already exists",inputActionName);
        return inputAction;
    }    
}

- (void) removeInputActionWithName:(NSString *)inputActionName
{
    [ inputActions removeObjectForKey:inputActionName ];
}

- (void) removeInputAction:(id)inputAction
{
    [ inputActions removeObjectForKey:[inputAction name]];
}

- (void) update
{
    NSEnumerator * actionEnumerator = [ inputActions objectEnumerator ];
    NPInputAction * action;

    while (( action = [ actionEnumerator nextObject ] ))
    {
        [ action update ];
    }
}

@end
