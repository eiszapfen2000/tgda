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

@end
