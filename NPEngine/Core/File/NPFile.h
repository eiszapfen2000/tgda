#import "Core/NPObject/NPObject.h"

@interface NPFile : NPObject
{
    NSString * fileName;
    NSData * fileContents;
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent fileName:(NSString *)newFileName;
- (void) dealloc;

- (NSString *) fileName;
- (void) setFileName:(NSString *)newFileName;

- (void) clear;
- (void) readBytesFromFile;

@end
