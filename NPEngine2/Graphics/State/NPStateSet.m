#import <Foundation/NSDictionary.h>
#import "Log/NPLog.h"
#import "Core/NPEngineCore.h"
#import "Core/File/NPLocalPathManager.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/NPEngineGraphics.h"
#import "Graphics/NPEngineGraphicsStringEnumConversion.h"
#import "NPStateSet.h"
#import "NPAlphaTestState.h"
#import "NPBlendingState.h"
#import "NPCullingState.h"
#import "NPDepthTestState.h"
#import "NPPolygonFillState.h"
#import "NPStateConfiguration.h"

@implementation NPStateSet

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

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

    NPEngineGraphicsStringEnumConversion * se
        = [[ NPEngineGraphics instance ] stringEnumConversion ];

    NSDictionary * alphaTest   = [ states objectForKey:@"AlphaTest" ];
    NSDictionary * blending    = [ states objectForKey:@"Blending" ];
    NSDictionary * culling     = [ states objectForKey:@"Culling" ];
    NSDictionary * depth       = [ states objectForKey:@"Depth" ];
    NSDictionary * polygonFill = [ states objectForKey:@"PolygonFill" ];

    NSString * comparison = nil;

    alphaTestEnabled   = [[ alphaTest objectForKey:@"Enabled" ] boolValue ];
    alphaTestThreshold = [[ alphaTest objectForKey:@"Threshold" ] floatValue ];

    comparison = [[ alphaTest objectForKey:@"ComparisonFunction" ] lowercaseString ];
    alphaTestComparisonFunction = [ se comparisonFunctionForString:comparison ];

    blendingEnabled = [[ blending objectForKey:@"Enabled" ] boolValue ];
    blendingMode = [ se blendingModeForString:[[ blending objectForKey:@"Mode" ] lowercaseString ]];

    cullingEnabled = [[ culling objectForKey:@"Enabled" ] boolValue ];
    cullFace = [ se cullfaceForString:[[ culling objectForKey:@"CullFace" ] lowercaseString ]];

    depthTestEnabled  = [[ depth objectForKey:@"DepthTestEnabled"  ] boolValue ];
    depthWriteEnabled = [[ depth objectForKey:@"DepthWriteEnabled" ] boolValue ];

    comparison = [[ depth objectForKey:@"ComparisonFunction" ] lowercaseString ];
    depthTestComparisonFunction = [ se comparisonFunctionForString:comparison ];

    polgyonFillFront = [ se polygonFillModeForString:[[ polygonFill objectForKey:@"Front"] lowercaseString ]];
    polgyonFillBack  = [ se polygonFillModeForString:[[ polygonFill objectForKey:@"Back" ] lowercaseString ]];

    return YES;
}

@end
