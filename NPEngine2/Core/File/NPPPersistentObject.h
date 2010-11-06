#import <Foundation/NSString.h>
#import "NPPStream.h"

@protocol NPPPersistentObject

- (void) loadFromStream:(id <NPPSttream>)stream;
- (void) loadFromFile:(NSString *)fileName;

@end
