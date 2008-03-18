#import "Core/NPObject/NPObject.h"

@class NPFile;
@class NPTexture;

@interface NPTextureManager : NPObject
{
    NSMutableDictionary * textures;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

- (id) loadTextureFromPath:(NSString *)path;
- (id) loadTextureFromAbsolutePath:(NSString *)path;
- (id) loadTextureUsingFileHandle:(NPFile *)file;

@end
