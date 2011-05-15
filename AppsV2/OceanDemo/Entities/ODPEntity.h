#import "Core/Protocols/NPPPersistentObject.h"

@class NSDictionary;
@class NSError;

@protocol ODPEntity

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
                           ;
- (void) update:(float)frameTime;
- (void) render;

@end
