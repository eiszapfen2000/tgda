#import "Core/Basics/NpBasics.h"
#import "Core/Math/FVector.h"
#import "Core/Protocols/NPPObject.h"

@class NPAssetArray;
@class NPEngineGraphicsStringEnumConversion;
@class NPEngineGraphicsStringToClassConversion;
@class NPTextureBindingState;
@class NPTextureSamplingState;
@class NPStateConfiguration;
@class NPViewport;
@class NPOrthographic;

@interface NPEngineGraphics : NSObject < NPPObject >
{
    uint32_t objectID;

    // driver stuff
    BOOL supportsSGIGenerateMipMap;
    BOOL supportsAnisotropicTextureFilter;
    BOOL supportsSamplerObjects;
    BOOL coreContext;
    BOOL debugContext;
    int32_t maximumAnisotropy;
    int32_t numberOfDrawBuffers;
    int32_t numberOfColorAttachments;
    int32_t maximalRenderbufferSize;
    int32_t maximumDebugMessageLength;

    NPEngineGraphicsStringEnumConversion * stringEnumConversion;
    NPEngineGraphicsStringToClassConversion * stringToClassConversion;

    NPAssetArray * images;
    NPAssetArray * textures2D;
    NPAssetArray * textures3D;
    NPAssetArray * effects;

    NPTextureBindingState * textureBindingState;
    NPTextureSamplingState * textureSamplingState;
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
- (NPAssetArray *) textures3D;
- (NPAssetArray *) effects;

- (NPTextureBindingState *) textureBindingState;
- (NPTextureSamplingState *) textureSamplingState;
- (NPStateConfiguration *) stateConfiguration;
- (NPViewport *) viewport;
- (NPOrthographic *) orthographic;

- (BOOL) startup;
- (void) shutdown;

- (BOOL) supportsSGIGenerateMipMap;
- (BOOL) supportsAnisotropicTextureFilter;
- (BOOL) supportsSamplerObjects;
- (BOOL) coreContext;
- (BOOL) debugContext;
- (int32_t) maximumAnisotropy;
- (int32_t) numberOfDrawBuffers;
- (int32_t) numberOfColorAttachments;
- (int32_t) maximalRenderbufferSize;
- (int32_t) maximumDebugMessageLength;

- (void) checkForDebugMessages;
- (BOOL) checkForGLError:(NSError **)error;
- (void) checkForGLErrors;

- (void) clearFrameBuffer:(BOOL)clearFrameBuffer
              depthBuffer:(BOOL)clearDepthBuffer
            stencilBuffer:(BOOL)clearStencilBuffer
                         ;

- (void) clearDrawBuffer:(int32_t)drawbuffer
                   color:(FVector4)color
                        ;

- (void) clearDepthBuffer:(float)depth;
- (void) clearStencilBuffer:(int32_t)stencil;

- (void) clearDepthBuffer:(float)depth
            stencilBuffer:(int32_t)stencil
                         ;

@end


