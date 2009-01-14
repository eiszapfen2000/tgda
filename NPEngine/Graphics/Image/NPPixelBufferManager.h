#import "Core/NPObject/NPObject.h"

@class NPPixelBuffer;
@class NPImage;
@class NPTexture;
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
- (NPPixelBuffer *) createPBOCompatibleWithRenderTexture:(NPRenderTexture *)renderTexture;
- (NPPixelBuffer *) createPBOCompatibleWithFramebuffer;

- (void) copyImage:(NPImage *)image toPBO:(NPPixelBuffer *)pbo;
- (void) copyRenderTexture:(NPRenderTexture *)renderTexture toPBO:(NPPixelBuffer *)pbo;
- (void) copyFramebuffer:(NpState)framebuffer toPBO:(NPPixelBuffer *)pbo;
- (void) copyPBO:(NPPixelBuffer *)pbo toTexture:(NPTexture *)texture;

@end
