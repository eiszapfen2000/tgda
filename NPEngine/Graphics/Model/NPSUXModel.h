#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"
#import "Core/Resource/NPResource.h"

@interface NPSUXModel : NPResource < NPPResource >
{
    NSMutableArray * lods;
    NSMutableArray * materials;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;
- (BOOL) isReady;

@end
