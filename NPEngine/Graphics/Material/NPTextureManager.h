#import "Core/NPObject/NPObject.h"

@class NPFile;

@interface NPTextureManager : NPObject
{
    NSMutableDictionary * textures;
    NpState maxAnisotropy;
    NpState anisotropy;
    BOOL nonPOTSupport;
    BOOL hardwareMipMapGenerationSupport;
    BOOL srgbTextureSupport;
    NpState textureMode;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (NpState) anisotropy;
- (NpState) maxAnisotropy;
- (BOOL) nonPOTSupport;
- (BOOL) hardwareMipMapGenerationSupport;
- (NpState) textureMode;

- (void) setAnisotropy:(NpState)newAnisotropy;;
- (void) setTextureMode:(NpState)newTextureMode;
- (void) setTexture2DMode;
- (void) setTexture3DMode;

- (UInt) generateGLTextureID;

- (Int) calculateDataFormatByteCount:(NpState)dataFormat;
- (Int) calculatePixelFormatChannelCount:(NpState)pixelFormat;
- (GLenum) computeGLWrap:(NpState)wrap;
- (GLenum) computeGLDataFormat:(NpState)dataFormat;
- (GLenum) computeGLPixelFormat:(NpState)pixelFormat;
- (GLint)  computeGLInternalTextureFormatUsingDataFormat:(NpState)dataFormat pixelFormat:(NpState)pixelFormat;

- (id) loadTextureFromPath:(NSString *)path;
- (id) loadTextureFromAbsolutePath:(NSString *)path;
- (id) loadTextureUsingFileHandle:(NPFile *)file;

- (id) loadTextureFromPath:(NSString *)path sRGB:(BOOL)sRGB;
- (id) loadTextureFromAbsolutePath:(NSString *)path sRGB:(BOOL)sRGB;
- (id) loadTextureUsingFileHandle:(NPFile *)file sRGB:(BOOL)sRGB;


- (id) textureWithName:(NSString *)textureName
                 width:(Int)width 
                height:(Int)height
            dataFormat:(NpState)dataFormat
           pixelFormat:(NpState)pixelFormat
                      ;

- (id) textureWithName:(NSString *)textureName
                 width:(Int)width 
                height:(Int)height
            dataFormat:(NpState)dataFormat
           pixelFormat:(NpState)pixelFormat
            mipMapping:(NpState)mipMapping
                      ;

- (id) texture3DWithName:(NSString *)textureName
                   width:(Int)width 
                  height:(Int)height
                   depth:(Int)depth
              dataFormat:(NpState)dataFormat
             pixelFormat:(NpState)pixelFormat
                        ;

@end
