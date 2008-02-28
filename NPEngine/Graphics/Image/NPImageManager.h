#import "Core/NPObject/NPObject.h"

@class NPFile;

@interface NPImageManager : NPObject
{
    NSMutableDictionary * images;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

- (id) loadImageFromPath:(NSString *)path;
- (id) loadImageFromAbsolutePath:(NSString *)path;
- (id) loadImageUsingFileHandle:(NPFile *)file;

@end
