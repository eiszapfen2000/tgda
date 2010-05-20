#import "Core/NPObject/NPObject.h"
#import "Core/Utilities/NPStringList.h"
#import "Core/Resource/NPResource.h"
#import "Graphics/NPEngineGraphicsConstants.h"

@class NPFile;
@class NPEffect;

@interface NPSUXMaterialInstance : NPResource
{
    NSString * materialFileName;
    NPStringList * materialInstanceScript;
    NPEffect * effect;

    //Int32  colormapIndices[NP_GRAPHICS_SAMPLER_COUNT];
    NSMutableArray * textures2D;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NPEffect *) effect;
- (NSString *) materialFileName;

- (void) setMaterialFileName:(NSString *)newMaterialFileName;

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) saveToFile:(NPFile *)file;
- (void) reset;

- (void) addEffectFromPath:(NSString *)path;
- (void) setEffectTechniqueByName:(NSString *)techniqueName;

- (void) addTexture2DWithName:(NSString *)samplerName
                     fromPath:(NSString *)path
                         sRGB:(BOOL)sRGB
                             ;

- (void) activate;

@end
