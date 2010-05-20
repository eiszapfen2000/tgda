#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"

@class NPFile;
@class NPEffect;

@interface NPSUXMaterialInstance : NPResource
{
    NSString * materialFileName;
    NSMutableArray * materialInstanceScript;

    NSMutableDictionary * textureNameToSemantic;
    NSMutableDictionary * textureNameToTextureFileName;
    NSMutableDictionary * textureNameToTexture;
    NSMutableDictionary * textureToSemantic;

    NPEffect * effect;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NSString *)materialFileName;
- (void) setMaterialFileName:(NSString *)newMaterialFileName;

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) saveToFile:(NPFile *)file;
- (void) reset;

- (NSArray *) textures;
- (NPEffect *) effect;

- (void) addEffectFromPath:(NSString *)path;
- (void) setEffectTechniqueByName:(NSString *)techniqueName;

- (void) addTexture2DWithName:(NSString *)samplerName
                     fromPath:(NSString *)path
                         sRGB:(BOOL)sRGB
                             ;

- (void) activate;

@end
