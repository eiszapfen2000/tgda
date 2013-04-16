#import <Foundation/NSString.h>
#import "NPEngineGraphicsEnums.h"

@interface NSString (NPEngineGraphicsEnums)

- (NpBlendingMode) blendingModeValueWithDefault:(NpBlendingMode)defaultValue;
- (NpComparisonFunction) comparisonFunctionValueWithDefault:(NpComparisonFunction)defaultValue;
- (NpCullface) cullfaceValueWithDefault:(NpCullface)defaultValue;
- (NpPolygonFillMode) polygonFillModeValueWithDefault:(NpPolygonFillMode)defaultValue;
- (NpUniformType) uniformTypeValue;
- (NpTextureType) textureTypeValue;
- (NpEffectSemantic) semanticValue;
- (NpTextureMinFilter) textureMinFilterValueWithDefault:(NpTextureMinFilter)defaultValue;
- (NpTextureMagFilter) textureMagFilterValueWithDefault:(NpTextureMagFilter)defaultValue;
- (NpTexture2DFilter) textureFilterValueWithDefault:(NpTexture2DFilter)defaultValue;
- (NpTextureWrap) textureWrapValueWithDefaultValue:(NpTextureWrap)defaultValue;
- (NpOrthographicAlignment) orthographicAlignmentValueWithDefault:(NpOrthographicAlignment)defaultValue;

+ (NSString *) stringForPixelFormat:(const NpImagePixelFormat)pixelFormat;
+ (NSString *) stringForImageDataFormat:(const NpImageDataFormat)dataFormat;

@end
