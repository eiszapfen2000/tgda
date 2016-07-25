#import "Core/NPObject/NPObject.h"

@class NPAlphaTestState;
@class NPBlendingState;
@class NPCullingState;
@class NPDepthTestState;
@class NPPolygonFillState;
@class NPStencilTestState;

@interface NPStateConfiguration : NPObject
{
    BOOL locked;
    BOOL coreProfileOnly;

    NPAlphaTestState   * alphaTestState;
    NPBlendingState    * blendingState;
    NPCullingState     * cullingState;
    NPDepthTestState   * depthTestState;
    NPPolygonFillState * polygonFillState;
    NPStencilTestState * stencilTestState;
}

- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (BOOL) locked;
- (void) setLocked:(BOOL)newLocked;
- (BOOL) coreProfileOnly;
- (void) setCoreProfileOnly:(BOOL)newCoreProfileOnly;

- (id) alphaTestState;
- (id) blendingState;
- (id) cullingState;
- (id) depthTestState;
- (id) polygonFillState;
- (id) stencilTestState;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
