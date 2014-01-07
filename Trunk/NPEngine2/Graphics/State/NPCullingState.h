#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPState.h"

@interface NPCullingState : NPState
{
    BOOL enabled;
    BOOL defaultEnabled;
    BOOL currentlyEnabled;

    NpCullface cullFace;
    NpCullface defaultCullFace;
    NpCullface currentCullFace;
}

- (id) initWithName:(NSString *)newName
      configuration:(NPStateConfiguration *)newConfiguration
                   ;
- (void) dealloc;

- (BOOL) enabled;
- (BOOL) defaultEnabled;
- (NpCullface) cullFace;
- (NpCullface) defaultCullFace;

- (void) setEnabled:(BOOL)newEnabled;
- (void) setDefaultEnabled:(BOOL)newDefaultEnabled;
- (void) setCullFace:(NpCullface)newCullFace;
- (void) setDefaultCullFace:(NpCullface)newDefaultCullFace;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
