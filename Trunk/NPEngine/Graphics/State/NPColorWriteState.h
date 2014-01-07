#import "NPState.h"

@interface NPColorWriteState : NPState
{
    BOOL enabled;
    BOOL defaultEnabled;
    BOOL currentEnabled;
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

- (void) activate;
- (void) deactivate;
- (void) reset;

@end
