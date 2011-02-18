#import "NPStateSet.h"
#import "NPAlphaTestState.h"
#import "NPBlendingState.h"
#import "NPCullingState.h"
#import "NPDepthTestState.h"
#import "NPPolygonFillState.h"
#import "NPStateConfiguration.h"
#import "Graphics/NPEngineGraphics.h"

@implementation NPStateSet

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    alphaTestEnabled   = NO;
    alphaTestThreshold = 0.5f;
    alphaTestComparisonFunction = NpComparisonGreaterEqual;

    blendingEnabled = NO;
    blendingMode    = NpBlendingAdditive;

    cullingEnabled = YES;
    cullFace       = NpCullfaceBack;

    depthTestEnabled  = YES;
    depthWriteEnabled = YES;
    depthTestComparisonFunction = NpComparisonLessEqual;

    polgyonFillFront = NpPolygonFillFace;
    polgyonFillBack  = NpPolygonFillFace;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) setAlphaTestEnabled:(BOOL)newAlphaTestEnabled
{
    alphaTestEnabled = newAlphaTestEnabled;
}

- (void) setAlphaTestThreshold:(BOOL)newAlphaTestThreshold
{
    alphaTestThreshold = newAlphaTestThreshold;
}

- (void) setAlphaTestComparisonFunction:(NpComparisonFunction)newAlphaTestComparisonFunction
{
    alphaTestComparisonFunction = newAlphaTestComparisonFunction;
}

- (void) setBlendingEnabled:(BOOL)newBlendingEnabled
{
    blendingEnabled = newBlendingEnabled;
}

- (void) setBlendingMode:(NpBlendingMode)newBlendingMode
{
    blendingMode = newBlendingMode;
}

- (void) setCullingEnabled:(BOOL)newCullingEnabled
{
    cullingEnabled = newCullingEnabled;
}

- (void) setCullFace:(NpCullface)newCullFace
{
    cullFace = newCullFace;
}

- (void) setDepthTestEnabled:(BOOL)newDepthTestEnabled
{
    depthTestEnabled = newDepthTestEnabled;
}

- (void) setDepthWriteEnabled:(BOOL)newDepthWriteEnabled
{
    depthWriteEnabled = newDepthWriteEnabled;
}

- (void) setDepthTestComparisonFunction:(NpComparisonFunction)newDepthTestComparisonFunction
{
    depthTestComparisonFunction = newDepthTestComparisonFunction;
}

- (void) setPolygonFillFront:(NpPolygonFillMode)newPolygonFillFront
{
    polgyonFillFront = newPolygonFillFront;
}

- (void) setPolygonFillBack:(NpPolygonFillMode)newPolygonFillBack
{
    polgyonFillBack = newPolygonFillBack;
}

- (void) activate
{
    NPStateConfiguration * configuration = [[ NPEngineGraphics instance ] stateConfiguration ];

    [[ configuration alphaTestState ] setEnabled:alphaTestEnabled ];
    [[ configuration alphaTestState ] setAlphaThreshold:alphaTestThreshold ];
    [[ configuration alphaTestState ] setComparisonFunction:alphaTestComparisonFunction ];

    [[ configuration blendingState ] setEnabled:blendingEnabled ];
    [[ configuration blendingState ] setBlendingMode:blendingMode ];

    [[ configuration cullingState ] setEnabled:cullingEnabled ];
    [[ configuration cullingState ] setCullFace:cullFace ];

    [[ configuration depthTestState ] setEnabled:depthTestEnabled ];
    [[ configuration depthTestState ] setWriteEnabled:depthWriteEnabled ];
    [[ configuration depthTestState ] setComparisonFunction:depthTestComparisonFunction ];

    [[ configuration polygonFillState ] setFrontFaceFill:polgyonFillFront ];
    [[ configuration polygonFillState ] setBackFaceFill:polgyonFillBack ];

    [ configuration activate ];
}

- (void) deactivate
{
    [[[ NPEngineGraphics instance ] stateConfiguration ] deactivate ];
}

/*
- (void) loadFromFile:(NSString *)path;
{
    NSDictionary * states = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSDictionary * alphaTest = [ states objectForKey:@"AlphaTest" ];
    alphaTestEnabled   = [[ alphaTest objectForKey:@"Enabled" ] boolValue ];
    alphaTestThreshold = [[ alphaTest objectForKey:@"Enabled" ] floatValue ];
    alphaTestComparisonFunction = [[(NPStateSetManager *)parent valueForKeyword:[alphaTest objectForKey:@"ComparisonFunction"]] intValue ];

    NSDictionary * blending = [ states objectForKey:@"Blending" ];
    blendingEnabled = [[ blending objectForKey:@"Enabled" ] boolValue ];
    blendingMode = [[(NPStateSetManager *)parent valueForKeyword:[ blending objectForKey:@"Mode" ]] intValue ];

    NSDictionary * colorWrite = [ states objectForKey:@"ColorWrite" ];
    colorWriteEnabled = [[ colorWrite objectForKey:@"Enabled" ] boolValue ];

    NSDictionary * culling = [ states objectForKey:@"Culling" ];
    cullingEnabled = [[ culling objectForKey:@"Enabled" ] boolValue ];
    cullFace = [[(NPStateSetManager *)parent valueForKeyword:[ culling objectForKey:@"CullFace" ]] intValue ];

    NSDictionary * depth = [ states objectForKey:@"Depth" ];
    depthTestEnabled  = [[ depth objectForKey:@"DepthTestEnabled"  ] boolValue ];
    depthWriteEnabled = [[ depth objectForKey:@"DepthWriteEnabled" ] boolValue ];
    depthTestComparisonFunction = [[(NPStateSetManager *)parent valueForKeyword:[depth objectForKey:@"ComparisonFunction"]] intValue ];

    NSDictionary * polygonFill = [ states objectForKey:@"PolygonFill" ];
    polgyonFillFront = [[(NPStateSetManager *)parent valueForKeyword:[polygonFill objectForKey:@"Front"]] intValue ];
    polgyonFillBack  = [[(NPStateSetManager *)parent valueForKeyword:[polygonFill objectForKey:@"Back" ]] intValue ];
}
*/

@end
