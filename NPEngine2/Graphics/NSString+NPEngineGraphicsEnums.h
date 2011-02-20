#import <Foundation/NSString.h>
#import "NPEngineGraphicsEnums.h"

@interface NSString (NPEngineGraphicsEnums)

- (NpBlendingMode) blendingModeValueWithDefault:(NpBlendingMode)defaultValue;
- (NpComparisonFunction) comparisonFunctionValueWithDefault:(NpComparisonFunction)defaultValue;
- (NpCullface) cullfaceValueWithDefault:(NpCullface)defaultValue;
- (NpPolygonFillMode) polygonFillModeValueWithDefault:(NpPolygonFillMode)defaultValue;
- (NpUniformType) uniformTypeValue;

@end
