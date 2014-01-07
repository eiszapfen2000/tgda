#import "Core/NPObject/NPObject.h"

@interface NPStateSet : NPObject
{
    BOOL    alphaTestEnabled;
    Float   alphaTestThreshold;
    NpState alphaTestComparisonFunction;

    BOOL    blendingEnabled;
    NpState blendingMode;

    BOOL    colorWriteEnabled;

    BOOL    cullingEnabled;
    NpState cullFace;

    BOOL    depthTestEnabled;
    BOOL    depthWriteEnabled;
    NpState depthTestComparisonFunction;

    NpState polgyonFillFront;
    NpState polgyonFillBack;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setAlphaTestEnabled:(BOOL)newAlphaTestEnabled;
- (void) setAlphaTestThreshold:(BOOL)newAlphaTestThreshold;
- (void) setAlphaTestComparisonFunction:(NpState)newAlphaTestComparisonFunction;

- (void) setBlendingEnabled:(BOOL)newBlendingEnabled;
- (void) setBlendingMode:(NpState)newBlendingMode;

- (void) setColorWriteEnabled:(BOOL)newColorWriteEnabled;

- (void) setCullingEnabled:(BOOL)newCullingEnabled;
- (void) setCullFace:(NpState)newCullFace;

- (void) setDepthTestEnabled:(BOOL)newDepthTestEnabled;
- (void) setDepthWriteEnabled:(BOOL)newDepthWriteEnabled;
- (void) setDepthTestComparisonFunction:(NpState)newDepthTestComparisonFunction;

- (void) setPolygonFillFront:(NpState)newPolygonFillFront;
- (void) setPolygonFillBack:(NpState)newPolygonFillBack;

- (void) activate;
- (void) deactivate;

- (void) loadFromFile:(NSString *)path;

@end

