#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "NPPRenderTarget.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "Graphics/Texture/NPPTexture.h"

@class NSError;
@class NPRenderTargetConfiguration;
@class NPTexture2D;

@interface NPRenderTexture : NPObject < NPPRenderTarget2D, NPPRenderTarget3D >
{
	GLuint glID;
    NpRenderTargetType type;
	uint32_t width;
	uint32_t height;
    uint32_t depth;
    NpTexturePixelFormat pixelFormat;
    NpTextureDataFormat dataFormat;
    id < NSObject, NPPTexture > texture;
    NPRenderTargetConfiguration * rtc;
    uint32_t colorBufferIndex;
    BOOL ready;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (id < NPPTexture >) texture;

- (BOOL) generate:(NpRenderTargetType)newType
            width:(uint32_t)newWidth
           height:(uint32_t)newHeight
      pixelFormat:(NpTexturePixelFormat)newPixelFormat
       dataFormat:(NpTextureDataFormat)newDataFormat
    mipmapStorage:(BOOL)mipmapStorage
            error:(NSError **)error
                 ;

- (BOOL) generate2DArray:(NpRenderTargetType)newType
                   width:(uint32_t)newWidth
                  height:(uint32_t)newHeight
                  layers:(uint32_t)newLayers
             pixelFormat:(NpTexturePixelFormat)newPixelFormat
              dataFormat:(NpTextureDataFormat)newDataFormat
           mipmapStorage:(BOOL)mipmapStorage
                   error:(NSError **)error
                        ;

- (BOOL) generate3D:(NpRenderTargetType)newType
              width:(uint32_t)newWidth
             height:(uint32_t)newHeight
              depth:(uint32_t)newDepth
        pixelFormat:(NpTexturePixelFormat)newPixelFormat
         dataFormat:(NpTextureDataFormat)newDataFormat
      mipmapStorage:(BOOL)mipmapStorage
              error:(NSError **)error
                   ;

@end

