#import "Core/NPObject/NPObject.h"

@class NPFile;

@interface NPTextureManager : NPObject
{
    NSMutableDictionary * textures;
    Int maxAnisotropy;
    BOOL nonPOTSupport;
    BOOL hardwareMipMapGenerationSupport;
    NpState textureMode;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (Int) maxAnisotropy;
- (BOOL) nonPOTSupport;
- (BOOL) hardwareMipMapGenerationSupport;
- (NpState) textureMode;

- (void) setTextureMode:(NpState)newTextureMode;
- (void) setTexture2DMode;
- (void) setTexture3DMode;

- (UInt) generateGLTextureID;

- (GLenum) computeGLWrap:(NpState)wrap;
- (GLenum) computeGLDataFormat:(NpState)dataFormat;
- (GLenum) computeGLPixelFormat:(NpState)pixelFormat;
- (GLint)  computeGLInternalTextureFormatUsingDataFormat:(NpState)dataFormat pixelFormat:(NpState)pixelFormat;

- (id) loadTextureFromPath:(NSString *)path;
- (id) loadTextureFromAbsolutePath:(NSString *)path;
- (id) loadTextureUsingFileHandle:(NPFile *)file;

- (id) createTextureWithName:(NSString *)textureName
                       width:(Int)width 
                      height:(Int)height
                  dataFormat:(NpState)dataFormat
                 pixelFormat:(NpState)pixelFormat
                             ;

- (id) createTextureWithName:(NSString *)textureName
                       width:(Int)width 
                      height:(Int)height
                  dataFormat:(NpState)dataFormat
                 pixelFormat:(NpState)pixelFormat
                  mipMapping:(NpState)mipMapping
                             ;

- (id) createTexture3DWithName:(NSString *)textureName
                         width:(Int)width 
                        height:(Int)height
                         depth:(Int)depth
                    dataFormat:(NpState)dataFormat
                   pixelFormat:(NpState)pixelFormat
                              ;

@end
