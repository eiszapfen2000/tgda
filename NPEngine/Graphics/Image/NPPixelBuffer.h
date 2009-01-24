#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"

@class NPImage;
@class NPTexture;
@class NPRenderTexture;

@interface NPPixelBuffer : NPObject
{
    UInt pixelBufferID;

    NpState mode;
    Int width;
    Int height;
    NpState dataFormat;
    NpState pixelFormat;
    NpState usage;

    GLenum currentTarget;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
               mode:(NpState)newMode
              width:(Int)newWidth
             height:(Int)newHeight
         dataFormat:(NpState)newDataFormat
        pixelFormat:(NpState)newPixelFormat
              usage:(NpState)newUsage
                   ;
- (void) dealloc;

- (void) reset;

- (UInt) pixelBufferID;
- (Int) width;
- (Int) height;
- (NpState) dataFormat;
- (NpState) pixelFormat;

- (void) setPixelBufferID:(UInt)newPixelBufferID;
- (void) setWidth:(Int)newWidth;
- (void) setHeight:(Int)newHeight;
- (void) setDataFormat:(NpState)newDataFormat;
- (void) setPixelFormat:(NpState)newPixelFormat;

- (BOOL) isCompatibleWithImage:(NPImage *)image;
- (BOOL) isCompatibleWithRenderTexture:(NPRenderTexture *)renderTexture;
- (BOOL) isCompatibleWithTexture:(NPTexture *)texture;
- (BOOL) isCompatibleWithFramebuffer;

- (void) generateGLBufferID;
- (void) uploadToGLWithoutData;
- (void) uploadToGLUsingData:(NSData *)data;
- (void) uploadToGLUsingData:(NSData *)data byteCount:(UInt)byteCount;

- (void) activate;
- (void) activateForReading;
- (void) activateForWriting;
- (void) deactivate;

@end
