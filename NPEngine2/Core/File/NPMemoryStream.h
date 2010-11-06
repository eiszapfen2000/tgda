#import  <Foundation/NSData.h>
#import "Core/NPObject/NPObject.h"
#import "NPPStream.h"

@interface NPMemoryStream : NPObject < NPPStream >
{
    NSMutableData * buffer;
    NSUInteger streamOffset;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject> )newParent
                   ;

- (void) dealloc;

- (void) seekToBeginningOfStream;
- (void) seekToEndOfStream;
- (void) seekToStreamOffset:(NSUInteger)offset;

@end
