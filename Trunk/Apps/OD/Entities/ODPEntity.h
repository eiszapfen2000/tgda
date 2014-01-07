#import <Foundation/Foundation.h>

@protocol ODPEntity

- (BOOL) loadFromDictionary:(NSDictionary *)config;
- (void) update:(Float)frameTime;
- (void) render;

@end
