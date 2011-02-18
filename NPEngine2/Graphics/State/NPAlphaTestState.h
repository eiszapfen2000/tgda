#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPState.h"

@interface NPAlphaTestState : NPState
{
    BOOL enabled;
    BOOL defaultEnabled;
    BOOL currentlyEnabled;

    Float alphaThreshold;
    Float defaultAlphaThreshold;
    Float currentAlphaThreshold;

    NpComparisonFunction comparisonFunction;
    NpComparisonFunction defaultComparisonFunction;
    NpComparisonFunction currentComparisonFunction;
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
      configuration:(NPStateConfiguration *)newConfiguration
                   ;
- (void) dealloc;

- (BOOL) enabled;
- (BOOL) defaultEnabled;
- (Float) alphaThreshold;
- (Float) defaultAlphaThreshold;
- (NpComparisonFunction) comparisonFunction;
- (NpComparisonFunction) defaultComparisonFunction;

- (void) setEnabled:(BOOL)newEnabled;
- (void) setDefaultEnabled:(BOOL)newDefaultEnabled;
- (void) setAlphaThreshold:(Float)newAlphaThreshold;
- (void) setDefaultAlphaThreshold:(Float)newDefaultAlphaThreshold;
- (void) setComparisonFunction:(NpComparisonFunction)newComparisonFunction;
- (void) setDefaultComparisonFunction:(NpComparisonFunction)newDefaultComparisonFunction;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
