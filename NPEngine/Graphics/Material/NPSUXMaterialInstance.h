#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"

@interface NPSUXMaterialInstance : NPObject
{
    NSString * materialFileName;
    NSMutableArray * materialInstanceScript;
}
- (id) init;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (NSString *)materialFileName;
- (void) setMaterialFileName:(NSString *)newMaterialFileName;

- (void) loadFromFile:(NPFile *)file;

@end
