#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"

@interface NPSUXMaterial : NPObject
{
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (void) loadFromFile:(NPFile *)file;

@end
