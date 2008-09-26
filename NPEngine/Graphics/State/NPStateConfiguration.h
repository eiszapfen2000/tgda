#import "NPAlphaTestState.h"
#import "NPDepthTestState.h"
#import "NPCullingState.h"

@interface NPStateConfiguration : NPObject
{
    BOOL locked;

    NPAlphaTestState * alphaTestState;
    NPDepthTestState * depthTestState;
    NPCullingState   * cullingState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) locked;
- (void) setLocked:(BOOL)newLocked;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
