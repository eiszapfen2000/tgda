#import <Foundation/NSDictionary.h>
#import "Log/NPLog.h"
#import "Core/NPEngineCore.h"
#import "Core/File/NPLocalPathManager.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/NPEngineGraphics.h"
#import "Graphics/NSString+NPEngineGraphicsEnums.h"
#import "NPStateSet.h"
#import "NPAlphaTestState.h"
#import "NPBlendingState.h"
#import "NPCullingState.h"
#import "NPDepthTestState.h"
#import "NPPolygonFillState.h"
#import "NPStateConfiguration.h"

@interface NPStateSet (Private)

- (void) loadAlphaTestState:(NSDictionary *)d;
- (void) loadBlendingState:(NSDictionary *)d;
- (void) loadCullingState:(NSDictionary *)d;
- (void) loadDepthState:(NSDictionary *)d;
- (void) loadPolygonFillState:(NSDictionary *)d;

@end

@implementation NPStateSet

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    file = nil;
    ready = YES;

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
    NPStateConfiguration * configuration
        = [[ NPEngineGraphics instance ] stateConfiguration ];

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

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return ready;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    NSString * completeFileName
        = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    if ( completeFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    [ self setName:completeFileName ];
    ASSIGNCOPY(file, completeFileName);

    NPLOG(@"Loading state set \"%@\"", completeFileName);

    NSDictionary * states
        = [ NSDictionary dictionaryWithContentsOfFile:completeFileName ];

    if ( states == nil )
    {
        //create error object
        return NO;
    }

    NSDictionary * alphaTest   = [ states objectForKey:@"AlphaTest" ];
    NSDictionary * blending    = [ states objectForKey:@"Blending" ];
    NSDictionary * culling     = [ states objectForKey:@"Culling" ];
    NSDictionary * depth       = [ states objectForKey:@"Depth" ];
    NSDictionary * polygonFill = [ states objectForKey:@"PolygonFill" ];

    [ self loadAlphaTestState:alphaTest ];
    [ self loadBlendingState:blending ];
    [ self loadCullingState:culling ];
    [ self loadDepthState:depth ];
    [ self loadPolygonFillState:polygonFill ];

    return YES;
}

@end

@implementation NPStateSet (Private)

- (void) loadAlphaTestState:(NSDictionary *)d
{
    if (d == nil )
    {
        return;
    }

    alphaTestEnabled   = [[ d objectForKey:@"Enabled" ] boolValue ];
    alphaTestThreshold = [[ d objectForKey:@"Threshold" ] floatValue ];

    NSString * alphaTestComparison
        = [[ d objectForKey:@"ComparisonFunction" ] lowercaseString ];

    alphaTestComparisonFunction 
        = [ alphaTestComparison comparisonFunctionValueWithDefault:alphaTestComparisonFunction ];
}

- (void) loadBlendingState:(NSDictionary *)d
{
    if (d == nil )
    {
        return;
    }

    blendingEnabled = [[ d objectForKey:@"Enabled" ] boolValue ];

    NSString * blendingModeString = [[ d objectForKey:@"Mode" ] lowercaseString ];
    blendingMode = [ blendingModeString blendingModeValueWithDefault:blendingMode ];
}

- (void) loadCullingState:(NSDictionary *)d
{
    if (d == nil )
    {
        return;
    }

    cullingEnabled = [[ d objectForKey:@"Enabled" ] boolValue ];

    NSString * cullfaceString = [[ d objectForKey:@"CullFace" ] lowercaseString ];
    cullFace = [ cullfaceString cullfaceValueWithDefault:cullFace ];
}

- (void) loadDepthState:(NSDictionary *)d
{
    if (d == nil )
    {
        return;
    }

    depthTestEnabled  = [[ d objectForKey:@"DepthTestEnabled"  ] boolValue ];
    depthWriteEnabled = [[ d objectForKey:@"DepthWriteEnabled" ] boolValue ];

    NSString * depthComparison
        = [[ d objectForKey:@"ComparisonFunction" ] lowercaseString ];

    depthTestComparisonFunction
        = [ depthComparison comparisonFunctionValueWithDefault:depthTestComparisonFunction ];
}

- (void) loadPolygonFillState:(NSDictionary *)d
{
    if (d == nil )
    {
        return;
    }

    NSString * pFront = [[ d objectForKey:@"Front" ] lowercaseString ];
    NSString * pBack  = [[ d objectForKey:@"Back"  ] lowercaseString ];

    polgyonFillFront = [ pFront polygonFillModeValueWithDefault:polgyonFillFront ];
    polgyonFillBack  = [ pBack  polygonFillModeValueWithDefault:polgyonFillBack  ];
}

@end


