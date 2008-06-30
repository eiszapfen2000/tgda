#import "Core/NPObject/NPObject.h"

@class NPFile;
@class NPTexture;

@interface NPTextureManager : NPObject
{
    NSMutableDictionary * textures;
    Int maxAnisotropy;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

- (Int) maxAnisotropy;

- (id) loadTextureFromPath:(NSString *)path;
- (id) loadTextureFromAbsolutePath:(NSString *)path;
- (id) loadTextureUsingFileHandle:(NPFile *)file;

@end
