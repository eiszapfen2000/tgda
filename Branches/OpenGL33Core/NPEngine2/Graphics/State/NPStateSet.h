#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@interface NPStateSet : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    BOOL alphaTestEnabled;
    BOOL blendingEnabled;
    BOOL cullingEnabled;
    BOOL depthTestEnabled;
    BOOL depthWriteEnabled;

    float alphaTestThreshold;
    NpComparisonFunction alphaTestComparisonFunction;
    NpComparisonFunction depthTestComparisonFunction;
    NpBlendingMode blendingMode;
    NpCullface cullFace;
    NpPolygonFillMode polgyonFillFront;
    NpPolygonFillMode polgyonFillBack;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) setAlphaTestEnabled:(BOOL)newAlphaTestEnabled;
- (void) setAlphaTestThreshold:(float)newAlphaTestThreshold;
- (void) setAlphaTestComparisonFunction:(NpComparisonFunction)newAlphaTestComparisonFunction;

- (void) setBlendingEnabled:(BOOL)newBlendingEnabled;
- (void) setBlendingMode:(NpBlendingMode)newBlendingMode;

- (void) setCullingEnabled:(BOOL)newCullingEnabled;
- (void) setCullFace:(NpCullface)newCullFace;

- (void) setDepthTestEnabled:(BOOL)newDepthTestEnabled;
- (void) setDepthWriteEnabled:(BOOL)newDepthWriteEnabled;
- (void) setDepthTestComparisonFunction:(NpComparisonFunction)newDepthTestComparisonFunction;

- (void) setPolygonFillFront:(NpPolygonFillMode)newPolygonFillFront;
- (void) setPolygonFillBack:(NpPolygonFillMode)newPolygonFillBack;

- (void) activate;
- (void) deactivate;

@end

