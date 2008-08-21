#import "Core/File/NPFile.h"

@protocol NPPResource

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) saveToFile:(NPFile *)file;
- (void) reset;
- (BOOL) ready;

@end
