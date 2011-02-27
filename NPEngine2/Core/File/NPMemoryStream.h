#import "Core/NPObject/NPObject.h"
#import "NPPStream.h"

@interface NPMemoryStream : NPObject < NPPStream >
{
    id buffer;
    NSUInteger streamOffset;
}

- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) seekToBeginningOfStream;
- (void) seekToEndOfStream;
- (void) seekToStreamOffset:(NSUInteger)offset;

@end
