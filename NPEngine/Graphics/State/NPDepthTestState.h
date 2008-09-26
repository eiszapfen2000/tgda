#import "NPState.h"

@interface NPDepthTestState : NPState
{
    BOOL enabled;
    BOOL currentlyEnabled;
    BOOL defaultEnabled;

    BOOL writeEnabled;
    BOOL defaultWriteEnabled;
    BOOL currentWriteEnabled;

    NpState comparisonFunction;
    NpState defaultComparisonFunction;
    NpState currentComparisonFunction;
}


- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent configuration:(NPStateConfiguration *)newConfiguration;
- (void) dealloc;

- (BOOL) enabled;
- (void) setEnabled:(BOOL)newEnabled;

- (BOOL) defaultEnabled;
- (void) setDefaultEnabled:(BOOL)newDefaultEnabled;

- (BOOL) writeEnabled;
- (void) setWriteEnabled:(BOOL)newWriteEnabled;

- (BOOL) defaultWriteEnabled;
- (void) setDefaultWriteEnabled:(BOOL)newDefaultWriteEnabled;

- (NpState) comparisonFunction;
- (void)    setComparisonFunction:(NpState)newComparisonFunction;

- (NpState) defaultComparisonFunction;
- (void)    setDefaultComparisonFunction:(NpState)newDefaultComparisonFunction;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
