#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"

#import "Cg/cg.h"
#import "Cg/cgGL.h"

@interface NPEffect : NPObject
{
    CGeffect effect;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) loadFromFile:(NPFile *)file;

@end
