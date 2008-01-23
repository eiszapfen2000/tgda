#import <AppKit/AppKit.h>

#import "Core/NPObject/NPObject.h"

typedef struct
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
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) setup;

- (NSOpenGLPixelFormat *)pixelFormat;

- (void) setPixelFormatAttributes:(NPOpenGLPixelFormatAttributes)newPixelFormatAttributes;

- (void) setFullScreen:(BOOL)fullscreen;
- (BOOL) fullscreen;

- (void) setBitsPerColorChannel:(Int32)newBitsPerColorChannel;
- (Int32)bitsPerColorChannel;

- (void) setAlphaBits:(Int32)newAlphaChannelBits;
- (Int32) alphaChannelBits;

- (void) setDepthBufferPrecision:(Int32)newDepthBufferPrecision;
- (Int32) depthBufferPrecision;

- (void) setDoubleBuffer:(BOOL)doubleBuffered;
- (BOOL) doubleBuffered;

- (void) setStencilBuffer:(BOOL)stencilBuffered;
- (BOOL) stencilBuffered;
- (void) setStencilBufferPrecision:(Int32)newStencilBufferPrecision;
- (Int32) stencilBufferPrecision;

- (void) setMultiSampleBuffer:(BOOL)multiSampled;
- (BOOL) multiSampled;
- (void) setSampleCount:(Int32)newSampleCount;
- (Int32) sampleCount;

@end
