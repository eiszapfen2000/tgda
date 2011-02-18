#import "NPStateSet.h"
#import "NPAlphaTestState.h"
#import "NPDepthTestState.h"
#import "NPCullingState.h"
#import "NPBlendingState.h"
#import "NPPolygonFillState.h"
#import "NPColorWriteState.h"
#import "NPStateConfiguration.h"
#import "NPStateSetManager.h"
#import "NP.h"

@implementation NPStateSet

- (id) init
{
    return [ self initWithName:@"NP State Set" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    alphaTestEnabled            = NO;
    alphaTestThreshold          = 0.5f;
    alphaTestComparisonFunction = NP_COMPARISON_GREATER_EQUAL;

    blendingEnabled = NO;
    blendingMode    = NP_BLENDING_ADDITIVE;

    cullingEnabled = YES;
    cullFace       = NP_BACK_FACE;

    colorWriteEnabled = YES;

    depthTestEnabled            = YES;
    depthWriteEnabled           = YES;
    depthTestComparisonFunction = NP_COMPARISON_LESS_EQUAL;

    polgyonFillFront = NP_POLYGON_FILL_FACE;
    polgyonFillBack  = NP_POLYGON_FILL_FACE;

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

- (void) setAlphaTestComparisonFunction:(NpState)newAlphaTestComparisonFunction
{
    alphaTestComparisonFunction = newAlphaTestComparisonFunction;
}

- (void) setBlendingEnabled:(BOOL)newBlendingEnabled
{
    blendingEnabled = newBlendingEnabled;
}

- (void) setBlendingMode:(NpState)newBlendingMode
{
    blendingMode = newBlendingMode;
}

- (void) setCullingEnabled:(BOOL)newCullingEnabled
{
    cullingEnabled = newCullingEnabled;
}

- (void) setCullFace:(NpState)newCullFace
{
    cullFace = newCullFace;
}

- (void) setColorWriteEnabled:(BOOL)newColorWriteEnabled
{
    colorWriteEnabled = newColorWriteEnabled;
}

- (void) setDepthTestEnabled:(BOOL)newDepthTestEnabled
{
    depthTestEnabled = newDepthTestEnabled;
}

- (void) setDepthWriteEnabled:(BOOL)newDepthWriteEnabled
{
    depthWriteEnabled = newDepthWriteEnabled;
}

- (void) setDepthTestComparisonFunction:(NpState)newDepthTestComparisonFunction
{
    depthTestComparisonFunction = newDepthTestComparisonFunction;
}

- (void) setPolygonFillFront:(NpState)newPolygonFillFront
{
    polgyonFillFront = newPolygonFillFront;
}

- (void) setPolygonFillBack:(NpState)newPolygonFillBack
{
    polgyonFillBack = newPolygonFillBack;
}

- (void) activate
{
    NPStateConfiguration * configuration = [[ NP Graphics ] stateConfiguration ];

    [[ configuration alphaTestState ] setEnabled:alphaTestEnabled ];
    [[ configuration alphaTestState ] setAlphaThreshold:alphaTestThreshold ];
    [[ configuration alphaTestState ] setComparisonFunction:alphaTestComparisonFunction ];

    [[ configuration blendingState ] setEnabled:blendingEnabled ];
    [[ configuration blendingState ] setBlendingMode:blendingMode ];

    [[ configuration colorWriteState ] setEnabled:colorWriteEnabled ];

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
    [[[ NP Graphics ] stateConfiguration ] deactivate ];
}

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

@end
