#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPState.h"

@interface NPStencilTestState : NPState
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

    int32_t referenceValue;
    int32_t defaultReferenceValue;
    int32_t currentReferenceValue;

    uint32_t comparisonMask;
    uint32_t defaultComparisonMask;
    uint32_t currentComparisonMask;
}

- (id) initWithName:(NSString *)newName
      configuration:(NPStateConfiguration *)newConfiguration
                   ;
- (void) dealloc;

- (BOOL) enabled;
- (BOOL) defaultEnabled;
- (BOOL) writeEnabled;
- (BOOL) defaultWriteEnabled;
- (NpComparisonFunction) comparisonFunction;
- (NpComparisonFunction) defaultComparisonFunction;
- (int32_t) referenceValue;
- (int32_t) defaultReferenceValue;
- (uint32_t) comparisonMask;
- (uint32_t) defaultComparisonMask;

- (void) setEnabled:(BOOL)newEnabled;
- (void) setDefaultEnabled:(BOOL)newDefaultEnabled;
- (void) setWriteEnabled:(BOOL)newWriteEnabled;
- (void) setDefaultWriteEnabled:(BOOL)newDefaultWriteEnabled;
- (void) setComparisonFunction:(NpComparisonFunction)newComparisonFunction;
- (void) setDefaultComparisonFunction:(NpComparisonFunction)newDefaultComparisonFunction;
- (void) setReferenceValue:(int32_t)newReferenceValue;
- (void) setDefaultReferenceValue:(int32_t)newDefaultReferenceValue;
- (void) setComparisonMask:(uint32_t)newComparisonMask;
- (void) setDefaultComparisonMask:(uint32_t)newDefaultComparisonMask;

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
