#import <Foundation/NSDictionary.h>
#import "NPEngineGraphicsStringEnumConversion.h"

static NSMutableDictionary * blendingModes = nil;
static NSMutableDictionary * comparisonFunctions = nil;
static NSMutableDictionary * cullfaces = nil;
static NSMutableDictionary * polygonFillModes = nil;
static NSMutableDictionary * uniformTypes = nil;

@implementation NPEngineGraphicsStringEnumConversion

#define INSERTENUM(_dictionary, _enum, _string) \
    [_dictionary setObject:[NSNumber numberWithInt:(int)_enum ] forKey:_string ]

+ (void) initialize
{
    blendingModes       = [[ NSMutableDictionary alloc ] init ];
    comparisonFunctions = [[ NSMutableDictionary alloc ] init ];
    cullfaces           = [[ NSMutableDictionary alloc ] init ];
    polygonFillModes    = [[ NSMutableDictionary alloc ] init ];
    uniformTypes        = [[ NSMutableDictionary alloc ] init ];

    INSERTENUM(blendingModes, NpBlendingAdditive, @"additive");
    INSERTENUM(blendingModes, NpBlendingSubtractive, @"subtractive");
    INSERTENUM(blendingModes, NpBlendingAverage, @"average");
    INSERTENUM(blendingModes, NpBlendingMin, @"min");
    INSERTENUM(blendingModes, NpBlendingMax, @"max");

    INSERTENUM(comparisonFunctions, NpComparisonNever, @"never");
    INSERTENUM(comparisonFunctions, NpComparisonAlways, @"always");
    INSERTENUM(comparisonFunctions, NpComparisonLess, @"less");
    INSERTENUM(comparisonFunctions, NpComparisonLessEqual, @"lessequal");
    INSERTENUM(comparisonFunctions, NpComparisonEqual, @"equal");
    INSERTENUM(comparisonFunctions, NpComparisonGreaterEqual, @"greaterequal");
    INSERTENUM(comparisonFunctions, NpComparisonGreater, @"greater");

    INSERTENUM(cullfaces, NpCullfaceFront, @"front");
    INSERTENUM(cullfaces, NpCullfaceBack, @"back");

    INSERTENUM(polygonFillModes, NpPolygonFillPoint, @"point");
    INSERTENUM(polygonFillModes, NpPolygonFillLine, @"line");
    INSERTENUM(polygonFillModes, NpPolygonFillFace, @"face");

    INSERTENUM(uniformTypes, NpUniformFloat, @"float");
    INSERTENUM(uniformTypes, NpUniformFloat2, @"vec2");
    INSERTENUM(uniformTypes, NpUniformFloat3, @"vec3");
    INSERTENUM(uniformTypes, NpUniformFloat4, @"vec4");
    INSERTENUM(uniformTypes, NpUniformInt,  @"int");
    INSERTENUM(uniformTypes, NpUniformInt2, @"ivec2");
    INSERTENUM(uniformTypes, NpUniformInt3, @"ivec3");
    INSERTENUM(uniformTypes, NpUniformInt4, @"ivec4");
    INSERTENUM(uniformTypes, NpUniformFMatrix2x2, @"mat2");
    INSERTENUM(uniformTypes, NpUniformFMatrix3x3, @"mat3");
    INSERTENUM(uniformTypes, NpUniformFMatrix4x4, @"mat4");
}

#undef INSERTENUM

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
{
    return [ super initWithName:newName parent:newParent ];
}

- (void) dealloc
{
    [ super dealloc ];
}

- (NpBlendingMode) blendingModeForString:(NSString *)string 
                             defaultMode:(NpBlendingMode)defaultMode
{
    NpBlendingMode result = defaultMode;

    NSNumber * n = [ blendingModes objectForKey:string ];
    if ( n != nil )
    {
        result = (NpBlendingMode)[ n intValue ];
    }

    return result;
}

- (NpComparisonFunction) comparisonFunctionForString:(NSString *)string
                                   defaultComparison:(NpComparisonFunction)defaultComparison
{
    NpComparisonFunction result = defaultComparison;

    NSNumber * n = [ comparisonFunctions objectForKey:string ];
    if ( n != nil )
    {
        result = (NpComparisonFunction)[ n intValue ];
    }

    return result;
}

- (NpCullface) cullfaceForString:(NSString *)string
                  defaulCullface:(NpCullface)defaultCullface
{
    NpCullface result = defaultCullface;

    NSNumber * n = [ cullfaces objectForKey:string ];
    if ( n != nil )
    {
        result = (NpCullface)[ n intValue ];
    }

    return result;
}

- (NpPolygonFillMode) polygonFillModeForString:(NSString *)string
                                   defaultMode:(NpPolygonFillMode)defaultMode
{
    NpPolygonFillMode result = defaultMode;

    NSNumber * n = [ polygonFillModes objectForKey:string ];
    if ( n != nil )
    {
        result = (NpPolygonFillMode)[ n intValue ];
    }

    return result;
}

- (NpUniformType) uniformTypeForString:(NSString *)string
{
    NpUniformType result = NpUniformUnknown;

    NSNumber * n = [ uniformTypes objectForKey:string ];
    if ( n != nil )
    {
        result = (NpUniformType)[ n intValue ];
    }

    return result;
}

@end

