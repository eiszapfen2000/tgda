#import "Core/Basics/NpBasics.h"
#import "Core/Protocols/NPPObject.h"

@class NPAssetArray;
@class NPEngineGraphicsStringEnumConversion;
@class NPEngineGraphicsStringToClassConversion;
@class NPTextureBindingState;
@class NPStateConfiguration;

@interface NPEngineGraphics : NSObject < NPPObject >
{
    uint32_t objectID;

    // driver stuff
    BOOL supportsSGIGenerateMipMap;
    BOOL supportsAnisotropicTextureFilter;
    int32_t maximumAnisotropy;
    BOOL supportssRGBTextures;
    BOOL supportsEXTFBO;
    BOOL supportsARBFBO;

    NPEngineGraphicsStringEnumConversion * stringEnumConversion;
    NPEngineGraphicsStringToClassConversion * stringToClassConversion;

    NPAssetArray * images;
    NPAssetArray * textures2D;
    NPAssetArray * effects;

    NPTextureBindingState * textureBindingState;
    NPStateConfiguration * stateConfiguration;
}

+ (NPEngineGraphics *) instance;

- (id) init;
- (void) dealloc;

- (NPEngineGraphicsStringEnumConversion *) stringEnumConversion;
- (NPEngineGraphicsStringToClassConversion *) stringToClassConversion;

- (NPAssetArray *) images;
- (NPAssetArray *) textures2D;
- (NPAssetArray *) effects;

- (NPTextureBindingState *) textureBindingState;
- (NPStateConfiguration *) stateConfiguration;

- (BOOL) startup;
- (void) shutdown;

- (BOOL) supportsSGIGenerateMipMap;
- (BOOL) supportsAnisotropicTextureFilter;
- (int32_t) maximumAnisotropy;
- (BOOL) supportssRGBTextures;
- (BOOL) supportsEXTFBO;
- (BOOL) supportsARBFBO;

- (BOOL) checkForGLError:(NSError **)error;
- (void) checkForGLErrors;

- (void) update;
- (void) render;

@end


