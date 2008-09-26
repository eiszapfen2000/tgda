#import "NPStateConfiguration.h"

@implementation NPStateConfiguration

- (id) init
{
    return [ self initWithName:@"NP State Configuration" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    locked = NO;

    alphaTestState = [[ NPAlphaTestState alloc ] initWithName:@"NP Alpha Test State" parent:self configuration:self ];
    depthTestState = [[ NPDepthTestState alloc ] initWithName:@"NP Depth Test State" parent:self configuration:self ];
    cullingState   = [[ NPCullingState   alloc ] initWithName:@"NP Culling State"    parent:self configuration:self ];

    return self;
}

- (void) dealloc
{
    [ cullingState   release ];
    [ depthTestState release ];
    [ alphaTestState release ];

    [ super dealloc ];
}

- (BOOL) locked
{
    return locked;
}

- (void) setLocked:(BOOL)newLocked
{
    locked = newLocked;
}

- (void) activate
{
    if ( locked == NO )
    {
        [ alphaTestState activate ];
        [ depthTestState activate ];
        [ cullingState   activate ];
    }
}

- (void) deactivate
{
    if ( locked == NO )
    {
        [ alphaTestState deactivate ];
        [ depthTestState deactivate ];
        [ cullingState   deactivate ];        
    }
}

- (void) reset
{
    if ( locked == NO )
    {
        [ alphaTestState reset ];
        [ depthTestState reset ];
        [ cullingState   reset ]; 
    }
}


@end
