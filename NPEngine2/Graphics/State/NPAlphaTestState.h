#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPState.h"

@interface NPAlphaTestState : NPState
{
    BOOL enabled;
    BOOL defaultEnabled;
    BOOL currentlyEnabled;

    float alphaThreshold;
    float defaultAlphaThreshold;
    float currentAlphaThreshold;

    NpComparisonFunction comparisonFunction;
    NpComparisonFunction defaultComparisonFunction;
    NpComparisonFunction currentComparisonFunction;
}

- (id) initWithName:(NSString *)newName
      configuration:(NPStateConfiguration *)newConfiguration
                   ;
- (void) dealloc;

- (BOOL) enabled;
- (BOOL) defaultEnabled;
- (float) alphaThreshold;
- (float) defaultAlphaThreshold;
- (NpComparisonFunction) comparisonFunction;
- (NpComparisonFunction) defaultComparisonFunction;

- (void) setEnabled:(BOOL)newEnabled;
- (void) setDefaultEnabled:(BOOL)newDefaultEnabled;
- (void) setAlphaThreshold:(float)newAlphaThreshold;
- (void) setDefaultAlphaThreshold:(float)newDefaultAlphaThreshold;
- (void) setComparisonFunction:(NpComparisonFunction)newComparisonFunction;
- (void) setDefaultComparisonFunction:(NpComparisonFunction)newDefaultComparisonFunction;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
