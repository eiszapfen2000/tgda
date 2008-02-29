#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;

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

- (void) uploadToGL;
- (void) render;

@end
