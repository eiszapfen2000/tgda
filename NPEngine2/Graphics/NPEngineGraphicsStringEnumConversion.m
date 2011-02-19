#import <Foundation/NSDictionary.h>
#import "NPEngineGraphicsStringEnumConversion.h"

@implementation NPEngineGraphicsStringEnumConversion

- (id) init
{
    return [ self initWithName:@"Graphics String Enum Conversion" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    blendingModes = [[ NSMutableDictionary alloc ] init ];
    comparisonFunctions = [[ NSMutableDictionary alloc ] init ];
    cullfaces = [[ NSMutableDictionary alloc ] init ];
    polygonFillModes = [[ NSMutableDictionary alloc ] init ];
    effectVariableTypes = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    DESTROY(effectVariableTypes);
    DESTROY(polygonFillModes);
    DESTROY(cullfaces);
    DESTROY(comparisonFunctions);
    DESTROY(blendingModes);

    [ super dealloc ];
}

#define INSERTENUM(_dictionary, _enum, _string) \
    [_dictionary setObject:[NSNumber numberWithInt:(int)_enum ] forKey:_string ]

- (void) startup
{
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

    INSERTENUM(effectVariableTypes, NpEffectVariableFloat, @"float");
    INSERTENUM(effectVariableTypes, NpEffectVariableFloat2, @"vec2");
    INSERTENUM(effectVariableTypes, NpEffectVariableFloat3, @"vec3");
    INSERTENUM(effectVariableTypes, NpEffectVariableFloat4, @"vec4");
    INSERTENUM(effectVariableTypes, NpEffectVariableInt,  @"int");
    INSERTENUM(effectVariableTypes, NpEffectVariableInt2, @"ivec2");
    INSERTENUM(effectVariableTypes, NpEffectVariableInt3, @"ivec3");
    INSERTENUM(effectVariableTypes, NpEffectVariableInt4, @"ivec4");
    INSERTENUM(effectVariableTypes, NpEffectVariableFMatrix2x2, @"mat2");
    INSERTENUM(effectVariableTypes, NpEffectVariableFMatrix3x3, @"mat3");
    INSERTENUM(effectVariableTypes, NpEffectVariableFMatrix4x4, @"mat4");
}

#undef INSERTENUM

- (void) shutdown
{
    [ effectVariableTypes removeAllObjects ];

    [ polygonFillModes removeAllObjects ];
    [ cullfaces removeAllObjects ];
    [ comparisonFunctions removeAllObjects ];
    [ blendingModes removeAllObjects ];
}

- (NpBlendingMode) blendingModeForString:(NSString *)string
{
    NpBlendingMode result = NpBlendingAverage;

    NSNumber * n = [ blendingModes objectForKey:string ];
    if ( n != nil )
    {
        result = (NpBlendingMode)[ n intValue ];
    }

    return result;
}

- (NpComparisonFunction) comparisonFunctionForString:(NSString *)string
{
    NpComparisonFunction result = NpComparisonAlways;

    NSNumber * n = [ comparisonFunctions objectForKey:string ];
    if ( n != nil )
    {
        result = (NpComparisonFunction)[ n intValue ];
    }

    return result;
}

- (NpCullface) cullfaceForString:(NSString *)string
{
    NpCullface result = NpCullfaceBack;

    NSNumber * n = [ cullfaces objectForKey:string ];
    if ( n != nil )
    {
        result = (NpCullface)[ n intValue ];
    }

    return result;

}

- (NpPolygonFillMode) polygonFillModeForString:(NSString *)string
{
    NpPolygonFillMode result = NpPolygonFillFace;

    NSNumber * n = [ polygonFillModes objectForKey:string ];
    if ( n != nil )
    {
        result = (NpPolygonFillMode)[ n intValue ];
    }

    return result;
}


- (NpEffectVariableType) effectVariableTypeForString:(NSString *)string
{
    NpEffectVariableType result = NpEffectVariableUnknown;

    NSNumber * n = [ effectVariableTypes objectForKey:string ];
    if ( n != nil )
    {
        result = (NpEffectVariableType)[ n intValue ];
    }

    return result;
}

@end

