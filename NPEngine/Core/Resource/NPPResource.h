#import "Core/File/NPFile.h"

@protocol NPPResource

- (BOOL) loadFromPath:(NSString *)path;
- (BOOL) saveToFile:(NPFile *)file;
- (void) reset;
- (BOOL) ready;

@end
