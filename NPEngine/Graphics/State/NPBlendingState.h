#import "NPState.h"

@interface NPBlendingState : NPState
{
    BOOL enabled;
    BOOL defaultEnabled;
    BOOL currentlyEnabled;

    NpState blendingMode;
    NpState defaultBlendingMode;
    NpState currentBlendingMode;
}


- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent configuration:(NPStateConfiguration *)newConfiguration;
- (void) dealloc;

- (BOOL) enabled;
- (void) setEnabled:(BOOL)newEnabled;

- (BOOL) defaultEnabled;
- (void) setDefaultEnabled:(BOOL)newDefaultEnabled;

- (NpState) blendingMode;
- (void)    setBlendingMode:(NpState)newBlendingMode;

- (NpState) defaultBlendingMode;
- (void)    setDefaultBlendingMode:(NpState)newBlendingMode;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
