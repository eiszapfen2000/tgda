#import <Foundation/Foundation.h>

@protocol ODPEntity

- (BOOL) loadFromDictionary:(NSDictionary *)path;
- (void) update:(Float)frameTime;
- (void) render;

@end
