#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPState.h"

@interface NPBlendingState : NPState
{
    BOOL enabled;
    BOOL defaultEnabled;
    BOOL currentlyEnabled;

    NpBlendingMode blendingMode;
    NpBlendingMode defaultBlendingMode;
    NpBlendingMode currentBlendingMode;
}

- (id) initWithName:(NSString *)newName 
      configuration:(NPStateConfiguration *)newConfiguration
                   ;
- (void) dealloc;

- (BOOL) enabled;
- (BOOL) defaultEnabled;
- (NpBlendingMode) blendingMode;
- (NpBlendingMode) defaultBlendingMode;

- (void) setEnabled:(BOOL)newEnabled;
- (void) setDefaultEnabled:(BOOL)newDefaultEnabled;
- (void) setBlendingMode:(NpBlendingMode)newBlendingMode;
- (void) setDefaultBlendingMode:(NpBlendingMode)newBlendingMode;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
