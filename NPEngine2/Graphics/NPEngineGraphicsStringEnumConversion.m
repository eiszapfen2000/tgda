#import <Foundation/NSDictionary.h>
#import "NPEngineGraphicsStringEnumConversion.h"

static NSMutableDictionary * blendingModes = nil;
static NSMutableDictionary * comparisonFunctions = nil;
static NSMutableDictionary * cullfaces = nil;
static NSMutableDictionary * polygonFillModes = nil;
static NSMutableDictionary * uniformTypes = nil;
static NSMutableDictionary * textureTypes = nil;
static NSMutableDictionary * semantics = nil;

static NSMutableDictionary * pixelFormats = nil;
static NSMutableDictionary * imageDataFormats = nil;

@implementation NPEngineGraphicsStringEnumConversion

#define INSERTENUM(_dictionary, _enum, _string) \
    [ _dictionary setObject:[NSNumber numberWithInt:(int)_enum ] forKey:_string ]

#define INSERTSTRING(_dictionary, _string, _enum) \
    [ _dictionary setObject:_string forKey:[NSNumber numberWithInt:(int)_enum ]]

+ (void) initialize
{
    blendingModes       = [[ NSMutableDictionary alloc ] init ];
    comparisonFunctions = [[ NSMutableDictionary alloc ] init ];
    cullfaces           = [[ NSMutableDictionary alloc ] init ];
    polygonFillModes    = [[ NSMutableDictionary alloc ] init ];
    uniformTypes        = [[ NSMutableDictionary alloc ] init ];
    textureTypes        = [[ NSMutableDictionary alloc ] init ];
    semantics           = [[ NSMutableDictionary alloc ] init ];

    pixelFormats        = [[ NSMutableDictionary alloc ] init ];
    imageDataFormats    = [[ NSMutableDictionary alloc ] init ];

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

    INSERTENUM(textureTypes, NpTextureTypeTexture1D, @"sampler1D");
    INSERTENUM(textureTypes, NpTextureTypeTexture2D, @"sampler2D");
    INSERTENUM(textureTypes, NpTextureTypeTexture3D, @"sampler3D");
    INSERTENUM(textureTypes, NpTextureTypeTextureCube, @"samplerCUBE");
    INSERTENUM(textureTypes, NpTextureTypeTextureBuffer, @"samplerBuffer");

    INSERTENUM(semantics, NpModelMatrix, @"np_modelmatrix");
    INSERTENUM(semantics, NpInverseModelMatrix, @"np_inversemodelmatrix");
    INSERTENUM(semantics, NpViewMatrix, @"np_viewmatrix");
    INSERTENUM(semantics, NpInverseViewMatrix, @"np_inverseviewmatrix");
    INSERTENUM(semantics, NpProjectionMatrix, @"np_projectionmatrix");
    INSERTENUM(semantics, NpInverseProjectionMatrix, @"np_inverseprojectionmatrix");
    INSERTENUM(semantics, NpModelViewMatrix, @"np_modelviewmatrix");
    INSERTENUM(semantics, NpInverseModelViewMatrix, @"np_inversemodelviewmatrix");
    INSERTENUM(semantics, NpViewProjectionMatrix, @"np_viewprojectionmatrix");
    INSERTENUM(semantics, NpInverseViewProjectionMatrix, @"np_inverseviewprojectionmatrix");
    INSERTENUM(semantics, NpModelViewProjectionMatrix, @"np_modelviewprojectionmatrix");
    INSERTENUM(semantics, NpInverseModelViewProjection, @"np_inversemodelviewprojectionmatrix");

    INSERTSTRING(pixelFormats, @"Unknown", NpImagePixelFormatUnknown);
    INSERTSTRING(pixelFormats, @"R", NpImagePixelFormatR);
    INSERTSTRING(pixelFormats, @"RG", NpImagePixelFormatRG);
    INSERTSTRING(pixelFormats, @"RGB", NpImagePixelFormatRGB);
    INSERTSTRING(pixelFormats, @"RGBA", NpImagePixelFormatRGBA);
    INSERTSTRING(pixelFormats, @"sRGB", NpImagePixelFormatsRGB);
    INSERTSTRING(pixelFormats, @"sRGB Linear Alpha", NpImagePixelFormatsRGBLinearA);

    INSERTSTRING(imageDataFormats, @"Unknown", NpImageDataFormatUnknown);
    INSERTSTRING(imageDataFormats, @"Byte", NpImageDataFormatByte);
    INSERTSTRING(imageDataFormats, @"Float16", NpImageDataFormatFloat16);
    INSERTSTRING(imageDataFormats, @"Float32", NpImageDataFormatFloat32);
}

#undef INSERTENUM

- (id) initWithName:(NSString *)newName
{
    return [ super initWithName:newName ];
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

- (NpTextureType) textureTypeForString:(NSString *)string
{
    NpTextureType result = NpTextureTypeUnknown;

    NSNumber * n = [ uniformTypes objectForKey:string ];
    if ( n != nil )
    {
        result = (NpTextureType)[ n intValue ];
    }

    return result;
}

- (NpEffectSemantic) semanticForString:(NSString *)string
{
    NpEffectSemantic result = NpSemanticUnknown;

    NSNumber * n = [ semantics objectForKey:string ];
    if ( n != nil )
    {
        result = (NpEffectSemantic)[ n intValue ];
    }

    return result;
}

- (NSString *) stringForPixelFormat:(const NpImagePixelFormat)pixelFormat
{
    return [ pixelFormats objectForKey:[ NSNumber numberWithInt:(int)pixelFormat ]];
}

- (NSString *) stringForImageDataFormat:(const NpImageDataFormat)dataFormat
{
    return [ imageDataFormats objectForKey:[ NSNumber numberWithInt:(int)dataFormat ]];
}

@end

