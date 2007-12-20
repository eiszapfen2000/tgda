#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"

@interface NPSUXModel : NPObject
{
    NSMutableArray * lods;
    NSMutableArray * materials;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (void) loadFromFile:(NPFile *)file;

@end
