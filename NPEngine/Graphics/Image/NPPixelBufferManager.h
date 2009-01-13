#import "Core/NPObject/NPObject.h"

@class NPPixelBuffer;
@class NPImage;
@class NPRenderTexture;

@interface NPPixelBufferManager : NPObject
{
    NSMutableArray * pixelBuffers;
    NPPixelBuffer * currentPixelBuffer;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NPPixelBuffer *) currentPixelBuffer;
- (void) setCurrentPixelBuffer:(NPPixelBuffer *)newCurrentPixelBuffer;

- (NPPixelBuffer *) createPBOCompatibleWithImage:(NPImage *)image;
- (NPPixelBuffer *) createPBOCompatibleWithRenderTexture:(NPRenderTexture *)image;
- (NPPixelBuffer *) createPBOCompatibleWithFramebuffer;

- (NPPixelBuffer *) createPBOUsingImage:(NPImage *)image;
- (NPPixelBuffer *) createPBOUsingRenderTexture:(NPRenderTexture *)renderTexture;
- (NPPixelBuffer *) createPBOUsingFramebuffer:(NpState)framebuffer;
- (NPPixelBuffer *) createPBOUsingColorbuffer:(NpState)colorbuffer;
- (void) copyImageToCurrentPBO:(NPImage *)image;
- (void) copyFramebufferToCurrentPBO:(NpState)framebuffer;
- (void) copyColorbufferToCurrentPBO:(NpState)colorbuffer;
- (void) copyImage:(NPImage *)image toPBO:(NPPixelBuffer *)pbo;
- (void) copyFramebuffer:(NpState)framebuffer toPBO:(NPPixelBuffer *)pbo;
- (void) copyColorbuffer:(NpState)colorbuffer toPBO:(NPPixelBuffer *)pbo;
//create pbo from image
//stream pbo from image
// create pbo from framebuffer
// create pbo from texture
// copy pbo ( create new pbo )
// copy pbo to specified pbo

@end
