#import "NPStateConfiguration.h"

@implementation NPStateConfiguration

- (id) initWithName:(NSString *)newName 
{
    self = [ super initWithName:newName ];

    locked = NO;

    alphaTestState   = [[ NPAlphaTestState   alloc ] initWithName:@"NP Alpha Test State"   configuration:self ];
    blendingState    = [[ NPBlendingState    alloc ] initWithName:@"NP Blending State"     configuration:self ];
    cullingState     = [[ NPCullingState     alloc ] initWithName:@"NP Culling State"      configuration:self ];
    depthTestState   = [[ NPDepthTestState   alloc ] initWithName:@"NP Depth Test State"   configuration:self ];
    polygonFillState = [[ NPPolygonFillState alloc ] initWithName:@"NP Polygon Fill State" configuration:self ];

    return self;
}

- (void) dealloc
{
    RELEASE(alphaTestState);
    RELEASE(blendingState);
    RELEASE(cullingState);
    RELEASE(depthTestState);
    RELEASE(polygonFillState);

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

- (id) alphaTestState
{
    return alphaTestState;
}

- (id) blendingState
{
    return blendingState;
}

- (id) cullingState
{
    return cullingState;
}

- (id) depthTestState
{
    return depthTestState;
}

- (id) polygonFillState
{
    return polygonFillState;
}

- (void) activate
{
    if ( locked == NO )
    {
        [ alphaTestState   activate ];
        [ blendingState    activate ];
        [ cullingState     activate ];
        [ depthTestState   activate ];
        [ polygonFillState activate ];
    }
}

- (void) deactivate
{
    if ( locked == NO )
    {
        [ alphaTestState   deactivate ];
        [ blendingState    deactivate ];
        [ cullingState     deactivate ];
        [ depthTestState   deactivate ];
        [ polygonFillState deactivate ];
    }
}

- (void) reset
{
    if ( locked == NO )
    {
        [ alphaTestState   reset ];
        [ blendingState    reset ];
        [ cullingState     reset ];
        [ depthTestState   reset ];
        [ polygonFillState reset ];
    }
}

@end
