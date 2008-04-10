#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;
@class NPSUXModelLod;

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

- (NSArray *) lods;
- (NSArray *) materials;

- (void) addLod:(NPSUXModelLod *)newLod;

- (void) uploadToGL;
- (void) render;

@end
