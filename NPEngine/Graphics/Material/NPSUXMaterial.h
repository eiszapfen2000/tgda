#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"

@interface NPSUXMaterial : NPObject
{
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;

- (void) loadFromFile:(NPFile *)file;

@end
