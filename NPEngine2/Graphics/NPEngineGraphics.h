#import "Core/Basics/NpBasics.h"
#import "Core/Protocols/NPPObject.h"

@class NPAssetArray;
@class NPEngineGraphicsStringEnumConversion;
@class NPEngineGraphicsStringToClassConversion;
@class NPTextureBindingState;
@class NPStateConfiguration;
@class NPViewport;
@class NPOrthographic;

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
    int32_t numberOfDrawBuffers;
    int32_t numberOfColorAttachments;
    int32_t maximalRenderbufferSize;

    NPEngineGraphicsStringEnumConversion * stringEnumConversion;
    NPEngineGraphicsStringToClassConversion * stringToClassConversion;

    NPAssetArray * images;
    NPAssetArray * textures2D;
    NPAssetArray * effects;

    NPTextureBindingState * textureBindingState;
    NPStateConfiguration * stateConfiguration;
    NPViewport * viewport;
    NPOrthographic * orthographic;
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
- (NPViewport *) viewport;
- (NPOrthographic *) orthographic;

- (BOOL) startup;
- (void) shutdown;

- (BOOL) supportsSGIGenerateMipMap;
- (BOOL) supportsAnisotropicTextureFilter;
- (int32_t) maximumAnisotropy;
- (BOOL) supportssRGBTextures;
- (BOOL) supportsEXTFBO;
- (BOOL) supportsARBFBO;
- (int32_t) numberOfDrawBuffers;
- (int32_t) numberOfColorAttachments;
- (int32_t) maximalRenderbufferSize;

- (BOOL) checkForGLError:(NSError **)error;
- (void) checkForGLErrors;

- (void) update;
- (void) render;

- (void) clearFrameBuffer:(BOOL)clearFrameBuffer
              depthBuffer:(BOOL)clearDepthBuffer
            stencilBuffer:(BOOL)clearStencilBuffer
                         ;

@end


