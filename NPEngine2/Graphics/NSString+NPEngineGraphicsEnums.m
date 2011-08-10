#import "NPEngineGraphics.h"
#import "NPEngineGraphicsStringEnumConversion.h"
#import "NSString+NPEngineGraphicsEnums.h"

@implementation NSString (NPEngineGraphicsEnums)

- (NpBlendingMode) blendingModeValueWithDefault:(NpBlendingMode)defaultValue
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ] 
                   blendingModeForString:self 
                             defaultMode:defaultValue ];
}

- (NpComparisonFunction) comparisonFunctionValueWithDefault:(NpComparisonFunction)defaultValue
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ]
                   comparisonFunctionForString:self
                             defaultComparison:defaultValue ];
}

- (NpCullface) cullfaceValueWithDefault:(NpCullface)defaultValue
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ]
                   cullfaceForString:self
                      defaulCullface:defaultValue ];
}

- (NpPolygonFillMode) polygonFillModeValueWithDefault:(NpPolygonFillMode)defaultValue
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ]
                   polygonFillModeForString:self
                                defaultMode:defaultValue ];
}

- (NpUniformType) uniformTypeValue
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ]
                   uniformTypeForString:self ];
}

- (NpTextureType) textureTypeValue
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ]
                   textureTypeForString:self ];
}

- (NpEffectSemantic) semanticValue
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ]
                   semanticForString:self ];
}

- (NpTexture2DFilter) textureFilterValueWithDefault:(NpTexture2DFilter)defaultValue
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ]
                   textureFilterForString:self
                            defaultFilter:defaultValue ];
}

- (NpOrthographicAlignment) orthographicAlignmentValueWithDefault:(NpOrthographicAlignment)defaultValue
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ]
                   orthographicAlignmentForString:self
                                 defaultAlignment:defaultValue ];
}

+ (NSString *) stringForPixelFormat:(const NpImagePixelFormat)pixelFormat
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ]
                    stringForPixelFormat:pixelFormat ];
}

+ (NSString *) stringForImageDataFormat:(const NpImageDataFormat)dataFormat
{
    return [[[ NPEngineGraphics instance ] stringEnumConversion ]
                    stringForImageDataFormat:dataFormat ];
}

@end
