#import "Core/File/NPFile.h"

@protocol NPPResource

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;
- (BOOL) ready;

@end
