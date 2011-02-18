#import "NPAlphaTestState.h"
#import "NPBlendingState.h"
#import "NPCullingState.h"
#import "NPDepthTestState.h"
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

- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject> )newParent
                   ;
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
