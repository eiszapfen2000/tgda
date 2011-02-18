#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPState.h"

@interface NPDepthTestState : NPState
{
    BOOL enabled;
    BOOL currentlyEnabled;
    BOOL defaultEnabled;

    BOOL writeEnabled;
    BOOL defaultWriteEnabled;
    BOOL currentWriteEnabled;

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
- (BOOL) writeEnabled;
- (BOOL) defaultWriteEnabled;
- (NpComparisonFunction) comparisonFunction;
- (NpComparisonFunction) defaultComparisonFunction;

- (void) setEnabled:(BOOL)newEnabled;
- (void) setDefaultEnabled:(BOOL)newDefaultEnabled;
- (void) setWriteEnabled:(BOOL)newWriteEnabled;
- (void) setDefaultWriteEnabled:(BOOL)newDefaultWriteEnabled;
- (void) setComparisonFunction:(NpComparisonFunction)newComparisonFunction;
- (void) setDefaultComparisonFunction:(NpComparisonFunction)newDefaultComparisonFunction;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
