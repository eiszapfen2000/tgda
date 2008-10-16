#import <AppKit/NSOpenGL.h>

#import "Core/NPObject/NPObject.h"

typedef struct NPOpenGLPixelFormatAttributes
{
    Int32 bitsPerColorChannel;
    Int32 alphaChannelBits;
    BOOL doubleBuffered;
    Int32 depthBufferPrecision;
    Int32 stencilBufferPrecision;
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
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject> )newParent
bitsPerColorChannel:(Int32)colorBits
   alphaChannelBits:(Int32)alphaBits
     doubleBuffered:(BOOL)doubleBuffer
    depthBufferBits:(Int32)depthBits
  stencilBufferBits:(Int32)stencilBits
               FSAA:(Int32)samples
                   ;

- (void) dealloc;

- (BOOL) chooseMatchingPixelFormat;

- (NSOpenGLPixelFormat *)pixelFormat;

- (BOOL) ready;

- (void) setPixelFormatAttributes:(NPOpenGLPixelFormatAttributes)newPixelFormatAttributes;

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
