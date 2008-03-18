#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;
@class NPEffect;

@interface NPSUXMaterialInstance : NPResource < NPPResource >
{
    NSString * materialFileName;
    NSMutableArray * materialInstanceScript;
    NSMutableDictionary * textureNameToSemantic;
    NSMutableDictionary * textureNameToTextureFileName;
    NSMutableDictionary * textureFileNameToTexture;
    NSMutableDictionary * textureToSemantic;
    NPEffect * effect;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (NSString *)materialFileName;
- (void) setMaterialFileName:(NSString *)newMaterialFileName;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;
- (BOOL) isReady;

@end
