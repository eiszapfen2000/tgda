#import "NPStateConfiguration.h"

@implementation NPStateConfiguration

- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    locked = NO;

    alphaTestState   = [[ NPAlphaTestState   alloc ] initWithName:@"NP Alpha Test State"   parent:self configuration:self ];
    blendingState    = [[ NPBlendingState    alloc ] initWithName:@"NP Blending State"     parent:self configuration:self ];
    cullingState     = [[ NPCullingState     alloc ] initWithName:@"NP Culling State"      parent:self configuration:self ];
    depthTestState   = [[ NPDepthTestState   alloc ] initWithName:@"NP Depth Test State"   parent:self configuration:self ];
    polygonFillState = [[ NPPolygonFillState alloc ] initWithName:@"NP Polygon Fill State" parent:self configuration:self ];

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
