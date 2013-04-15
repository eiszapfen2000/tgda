#import <Foundation/NSDictionary.h>
#import "NPEngineGraphicsStringEnumConversion.h"

static NSMutableDictionary * blendingModes = nil;
static NSMutableDictionary * comparisonFunctions = nil;
static NSMutableDictionary * cullfaces = nil;
static NSMutableDictionary * polygonFillModes = nil;
static NSMutableDictionary * uniformTypes = nil;
static NSMutableDictionary * textureTypes = nil;
static NSMutableDictionary * semantics = nil;
static NSMutableDictionary * textureFilters = nil;
static NSMutableDictionary * textureWraps = nil;
static NSMutableDictionary * orthographicAlignments = nil;
static NSMutableDictionary * pixelFormats = nil;
static NSMutableDictionary * imageDataFormats = nil;

@implementation NPEngineGraphicsStringEnumConversion

#define INSERTENUM(_dictionary, _enum, _string) \
    [ _dictionary setObject:[NSNumber numberWithInt:(int)_enum ] forKey:_string ]

#define INSERTSTRING(_dictionary, _string, _enum) \
    [ _dictionary setObject:_string forKey:[NSNumber numberWithInt:(int)_enum ]]

+ (void) initialize
{
    blendingModes          = [[ NSMutableDictionary alloc ] init ];
    comparisonFunctions    = [[ NSMutableDictionary alloc ] init ];
    cullfaces              = [[ NSMutableDictionary alloc ] init ];
    polygonFillModes       = [[ NSMutableDictionary alloc ] init ];
    uniformTypes           = [[ NSMutableDictionary alloc ] init ];
    textureTypes           = [[ NSMutableDictionary alloc ] init ];
    semantics              = [[ NSMutableDictionary alloc ] init ];
    textureFilters         = [[ NSMutableDictionary alloc ] init ];
    orthographicAlignments = [[ NSMutableDictionary alloc ] init ];
    pixelFormats           = [[ NSMutableDictionary alloc ] init ];
    imageDataFormats       = [[ NSMutableDictionary alloc ] init ];

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

    INSERTENUM(textureFilters, NpTexture2DFilterNearest, @"nearest");
    INSERTENUM(textureFilters, NpTexture2DFilterLinear, @"linear");
    INSERTENUM(textureFilters, NpTexture2DFilterTrilinear, @"trilinear");

    INSERTENUM(textureWraps, NpTextureWrapToBorder, @"wraptoborder");
    INSERTENUM(textureWraps, NpTextureWrapToEdge, @"wraptoedge");
    INSERTENUM(textureWraps, NpTextureWrapRepeat, @"repeat");

    INSERTENUM(orthographicAlignments, NpOrthographicAlignTopLeft, @"topleft");
    INSERTENUM(orthographicAlignments, NpOrthographicAlignTop, @"top");
    INSERTENUM(orthographicAlignments, NpOrthographicAlignTopRight, @"topright");
    INSERTENUM(orthographicAlignments, NpOrthographicAlignRight, @"right");
    INSERTENUM(orthographicAlignments, NpOrthographicAlignBottomRight, @"bottomright");
    INSERTENUM(orthographicAlignments, NpOrthographicAlignBottom, @"bottom");
    INSERTENUM(orthographicAlignments, NpOrthographicAlignBottomLeft, @"bottomleft");
    INSERTENUM(orthographicAlignments, NpOrthographicAlignLeft, @"left");

    INSERTSTRING(pixelFormats, @"Unknown", NpTexturePixelFormatUnknown);
    INSERTSTRING(pixelFormats, @"R", NpTexturePixelFormatR);
    INSERTSTRING(pixelFormats, @"RG", NpTexturePixelFormatRG);
    INSERTSTRING(pixelFormats, @"RGB", NpTexturePixelFormatRGB);
    INSERTSTRING(pixelFormats, @"RGBA", NpTexturePixelFormatRGBA);
    INSERTSTRING(pixelFormats, @"sRGB", NpTexturePixelFormatsRGB);
    INSERTSTRING(pixelFormats, @"sRGB Linear Alpha", NpTexturePixelFormatsRGBLinearA);
    INSERTSTRING(pixelFormats, @"sRGB", NpTexturePixelFormatsRGB);
    INSERTSTRING(pixelFormats, @"Depth", NpTexturePixelFormatDepth);
    INSERTSTRING(pixelFormats, @"DepthStencil", NpTexturePixelFormatDepthStencil);

    INSERTSTRING(imageDataFormats, @"Unknown", NpTextureDataFormatUnknown);
    INSERTSTRING(imageDataFormats, @"UInt8N", NpTextureDataFormatUInt8N);
    INSERTSTRING(imageDataFormats, @"Int8N", NpTextureDataFormatInt8N);
    INSERTSTRING(imageDataFormats, @"UInt8", NpTextureDataFormatUInt8);
    INSERTSTRING(imageDataFormats, @"Int8", NpTextureDataFormatInt8);
    INSERTSTRING(imageDataFormats, @"UInt16N", NpTextureDataFormatUInt16N);
    INSERTSTRING(imageDataFormats, @"Int16N", NpTextureDataFormatInt16N);
    INSERTSTRING(imageDataFormats, @"UInt16", NpTextureDataFormatUInt16);
    INSERTSTRING(imageDataFormats, @"Int16", NpTextureDataFormatInt16);
    INSERTSTRING(imageDataFormats, @"UInt32N", NpTextureDataFormatUInt32N);
    INSERTSTRING(imageDataFormats, @"Int32N", NpTextureDataFormatInt32N);
    INSERTSTRING(imageDataFormats, @"UInt32", NpTextureDataFormatUInt32);
    INSERTSTRING(imageDataFormats, @"Int32", NpTextureDataFormatInt32);
    INSERTSTRING(imageDataFormats, @"Float16", NpTextureDataFormatFloat16);
    INSERTSTRING(imageDataFormats, @"Float32", NpTextureDataFormatFloat32);
    INSERTSTRING(imageDataFormats, @"Float64", NpTextureDataFormatFloat64);
}

#undef INSERTENUM

- (id) init
{
    return [ self initWithName:@"Graphics String Enum Conversion" ];
}

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

- (NpTexture2DFilter) textureFilterForString:(NSString *)string
                               defaultFilter:(NpTexture2DFilter)defaultFilter
{
    NpTexture2DFilter result = defaultFilter;

    NSNumber * n = [ textureFilters objectForKey:string ];
    if ( n != nil )
    {
        result = (NpTexture2DFilter)[ n intValue ];
    }

    return result;
}

- (NpTextureWrap) textureWrapForString:(NSString *)string
                           defaultWrap:(NpTextureWrap)defaultWrap
{
    NpTextureWrap result = defaultWrap;

    NSNumber * n = [ textureWraps objectForKey:string ];
    if ( n != nil )
    {
        result = (NpTextureWrap)[ n intValue ];
    }

    return result;
}

- (NpOrthographicAlignment) orthographicAlignmentForString:(NSString *)string
                                          defaultAlignment:(NpOrthographicAlignment)defaultAlignment
{
    NpOrthographicAlignment result = defaultAlignment;
    NSNumber * n = [ orthographicAlignments objectForKey:string ];
    if ( n != nil )
    {
        result = (NpOrthographicAlignment)[ n intValue ];
    }

    return result;
}

- (NSString *) stringForPixelFormat:(const NpTexturePixelFormat)pixelFormat
{
    return [ pixelFormats objectForKey:[ NSNumber numberWithInt:(int)pixelFormat ]];
}

- (NSString *) stringForImageDataFormat:(const NpTextureDataFormat)dataFormat
{
    return [ imageDataFormats objectForKey:[ NSNumber numberWithInt:(int)dataFormat ]];
}

@end

