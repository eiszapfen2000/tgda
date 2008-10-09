#import "NPAlphaTestState.h"
#import "NPDepthTestState.h"
#import "NPCullingState.h"
#import "NPBlendingState.h"
#import "NPPolygonFillState.h"

@interface NPStateConfiguration : NPObject
{
    BOOL locked;

    NPAlphaTestState   * alphaTestState;
    NPBlendingState    * blendingState;
    NPCullingState     * cullingState;
    NPDepthTestState   * depthTestState;
    NPPolygonFillState * polygonFillState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) locked;
- (void) setLocked:(BOOL)newLocked;

- (id) alphaTestState;
- (id) blendingState;
- (id) cullingState;
- (id) depthTestState;
- (id) polygonFillState;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
