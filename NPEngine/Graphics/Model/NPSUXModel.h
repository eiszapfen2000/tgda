#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"

@class NPFile;
@class NPSUXModelLod;

@interface NPSUXModel : NPResource
{
    NSMutableArray * lods;
    NSMutableArray * materials;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) saveToFile:(NPFile *)file;
- (void) reset;

- (NSArray *) lods;
- (NPSUXModelLod *) lodAtIndex:(Int)index;
- (NSArray *) materials;

- (void) addLod:(NPSUXModelLod *)newLod;

- (void) uploadToGL;
- (void) render;
- (void) renderLod:(Int)index;

@end
