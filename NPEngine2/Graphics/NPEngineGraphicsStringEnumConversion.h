#import "Core/NPObject/NPObject.h"
#import "NPEngineGraphicsEnums.h"

@interface NPEngineGraphicsStringEnumConversion : NPObject
{
}

- (id) initWithName:(NSString *)newName;
- (void) dealloc;

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

@end
