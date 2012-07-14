#import "Core/Protocols/NPPObject.h"

@class NSDictionary;
@class NSError;

@protocol ODPEntity <NPPObject>

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
                           ;

- (void) update:(const double)frameTime;
- (void) render;

@end
