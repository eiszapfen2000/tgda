#import "Core/NPObject/NPObject.h"
#import "NPEngineGraphicsEnums.h"

@interface NPEngineGraphicsStringEnumConversion : NPObject
{
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (NpBlendingMode) blendingModeForString:(NSString *)string 
                             defaultMode:(NpBlendingMode)defaultMode
                                        ;

- (NpComparisonFunction) comparisonFunctionForString:(NSString *)string
                                   defaultComparison:(NpComparisonFunction)defaultComparison
                                                    ;

- (NpCullface) cullfaceForString:(NSString *)string
                  defaulCullface:(NpCullface)defaultCullface
                                ;

- (NpPolygonFillMode) polygonFillModeForString:(NSString *)string
                                   defaultMode:(NpPolygonFillMode)defaultMode
                                              ;

- (NpUniformType) uniformTypeForString:(NSString *)string;
- (NpTextureType) textureTypeForString:(NSString *)string;
- (NpEffectSemantic) semanticForString:(NSString *)string;

- (NpTexture2DFilter) textureFilterForString:(NSString *)string
                               defaultFilter:(NpTexture2DFilter)defaultFilter
                                            ;

- (NpOrthographicAlignment) orthographicAlignmentForString:(NSString *)string
                                          defaultAlignment:(NpOrthographicAlignment)defaultAlignment
                                                          ;

- (NSString *) stringForPixelFormat:(const NpImagePixelFormat)pixelFormat;
- (NSString *) stringForImageDataFormat:(const NpImageDataFormat)dataFormat;

@end
