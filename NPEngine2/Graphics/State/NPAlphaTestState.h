#import "NPState.h"

@interface NPAlphaTestState : NPState
{
    BOOL enabled;
    BOOL defaultEnabled;
    BOOL currentlyEnabled;

    Float alphaThreshold;
    Float defaultAlphaThreshold;
    Float currentAlphaThreshold;

    NpState comparisonFunction;
    NpState defaultComparisonFunction;
    NpState currentComparisonFunction;
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

- (Float) alphaThreshold;
- (void)  setAlphaThreshold:(Float)newAlphaThreshold;

- (Float) defaultAlphaThreshold;
- (void)  setDefaultAlphaThreshold:(Float)newDefaultAlphaThreshold;

- (NpState) comparisonFunction;
- (void)    setComparisonFunction:(NpState)newComparisonFunction;

- (NpState) defaultComparisonFunction;
- (void)    setDefaultComparisonFunction:(NpState)newDefaultComparisonFunction;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
