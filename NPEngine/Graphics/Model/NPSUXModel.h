#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;
@class NPSUXModelLod;

@interface NPSUXModel : NPResource
{
    NSMutableArray * lods;
    NSMutableArray * materials;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) saveToFile:(NPFile *)file;
- (void) reset;

- (NSArray *) lods;
- (NSArray *) materials;

- (void) addLod:(NPSUXModelLod *)newLod;

- (void) uploadToGL;
- (void) render;

@end
