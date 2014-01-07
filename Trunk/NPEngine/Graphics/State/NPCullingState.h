#import "NPState.h"

@interface NPCullingState : NPState
{
    BOOL enabled;
    BOOL defaultEnabled;
    BOOL currentlyEnabled;

    NpState cullFace;
    NpState defaultCullFace;
    NpState currentCullFace;
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

- (NpState) cullFace;
- (void)    setCullFace:(NpState)newCullFace;

- (NpState) defaultCullFace;
- (void)    setDefaultCullFace:(NpState)newDefaultCullFace;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
