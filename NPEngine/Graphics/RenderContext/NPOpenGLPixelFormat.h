#import <AppKit/NSOpenGL.h>

#import "Core/NPObject/NPObject.h"

typedef struct NPOpenGLPixelFormatAttributes
{
    BOOL fullscreen;
    Int32 bitsPerColorChannel;
    Int32 alphaChannelBits;
    BOOL doubleBuffered;
    Int32 depthBufferPrecision;
    BOOL stencilBuffered;
    Int32 stencilBufferPrecision;
    BOOL multiSampleBuffer;
    Int32 sampleCount;
}
NPOpenGLPixelFormatAttributes;

@interface NPOpenGLPixelFormat : NPObject
{
    NPOpenGLPixelFormatAttributes pixelFormatAttributes;
    NSOpenGLPixelFormat * pixelFormat;

    BOOL ready;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName 
             parent:(NPObject *)newParent
         fullscreen:(BOOL)fullscreen
bitsPerColorChannel:(Int32)colorBits
   alphaChannelBits:(Int32)alphaBits
     doubleBuffered:(BOOL)doubleBuffer
    depthBufferBits:(Int32)depthBits
    stencilBuffered:(BOOL)stencilBuffer
  stencilBufferBits:(Int32)stencilBits
               FSAA:(BOOL)multisampling
        sampleCount:(Int32)samples
                   ;

- (void) dealloc;

- (BOOL) setup;

- (NSOpenGLPixelFormat *)pixelFormat;

- (BOOL) ready;

- (void) setPixelFormatAttributes:(NPOpenGLPixelFormatAttributes)newPixelFormatAttributes;

- (void) setFullscreen:(BOOL)fullscreen;
- (BOOL) fullscreen;

- (void) setBitsPerColorChannel:(Int32)newBitsPerColorChannel;
- (Int32)bitsPerColorChannel;

- (void) setAlphaBits:(Int32)newAlphaChannelBits;
- (Int32) alphaChannelBits;

- (void) setDepthBufferPrecision:(Int32)newDepthBufferPrecision;
- (Int32) depthBufferPrecision;

- (void) setDoubleBuffer:(BOOL)doubleBuffered;
- (BOOL) doubleBuffered;

- (void) setStencilBufferPrecision:(Int32)newStencilBufferPrecision;
- (Int32) stencilBufferPrecision;

- (void) setSampleCount:(Int32)newSampleCount;
- (Int32) sampleCount;

@end
