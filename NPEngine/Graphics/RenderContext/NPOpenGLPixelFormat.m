#import "NPOpenGLPixelFormat.h"

#import "Core/Basics/NpMemory.h"

@implementation NPOpenGLPixelFormat

- (id) init
{
    return [ self initWithName:@"NP OpenGL PixelFormat" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    pixelFormatAttributes.fullscreen = NO;
    pixelFormatAttributes.bitsPerColorChannel = 8;
    pixelFormatAttributes.alphaChannelBits = 8;
    pixelFormatAttributes.doubleBuffered = YES;
    pixelFormatAttributes.depthBufferPrecision = 24;
    pixelFormatAttributes.stencilBuffered = NO;
    pixelFormatAttributes.stencilBufferPrecision = 0;
    pixelFormatAttributes.multiSampleBuffer = NO;
    pixelFormatAttributes.sampleCount = 1;

    pixelFormat = nil;

    ready = NO;

    return self;
}

- (void) dealloc
{
    [ pixelFormat release ];

    [ super dealloc ];
}

- (Int32) countAndCheckAttributes
{
    Int32 attributeCounter = 0;

    //fullscreen attribute
    if ( pixelFormatAttributes.fullscreen == YES )
    {
        attributeCounter++;
    }

    //colorsize and alphasize, 2 attributes each
    attributeCounter = attributeCounter + 4;

    //doublebuffer attribute
    if ( pixelFormatAttributes.doubleBuffered == YES )
    {
        attributeCounter++;
    }

    if ( pixelFormatAttributes.depthBufferPrecision != 24 || pixelFormatAttributes.depthBufferPrecision != 16 )
    {
        pixelFormatAttributes.depthBufferPrecision = 24;
    }

    //depthsize
    attributeCounter = attributeCounter + 2;

    if ( pixelFormatAttributes.stencilBuffered == YES && pixelFormatAttributes.stencilBufferPrecision > 0 )
    {
        //stencil size
        attributeCounter++;        
    }

    if ( pixelFormatAttributes.multiSampleBuffer == YES )
    {
        //multisamplebuffer count attribute
        attributeCounter = attributeCounter + 2;

        if ( pixelFormatAttributes.sampleCount < 1 && pixelFormatAttributes.sampleCount > 16 )
        {
            pixelFormatAttributes.sampleCount = 4;
        }

        //samplecount attribute
        attributeCounter = attributeCounter + 2;
    }

    return attributeCounter;    
}

- (NSOpenGLPixelFormatAttribute *)buildAttributes
{
    Int32 arraySize = [ self countAndCheckAttributes ]; 

    NSOpenGLPixelFormatAttribute * attributes = ALLOC_ARRAY(NSOpenGLPixelFormatAttribute, arraySize + 1);
    
    Int32 counter = 0;

    if ( pixelFormatAttributes.fullscreen == YES )
    {
        attributes[counter++] = NSOpenGLPFAFullScreen;
    }

    attributes[counter++] = NSOpenGLPFAColorSize;
    attributes[counter++] = (NSOpenGLPixelFormatAttribute)pixelFormatAttributes.bitsPerColorChannel;

    attributes[counter++] = NSOpenGLPFAAlphaSize;
    attributes[counter++] = (NSOpenGLPixelFormatAttribute)pixelFormatAttributes.alphaChannelBits;

    if ( pixelFormatAttributes.doubleBuffered == YES )
    {
        attributes[counter++] = NSOpenGLPFADoubleBuffer;
    }
    
    attributes[counter++] = NSOpenGLPFADepthSize;
    attributes[counter++] = (NSOpenGLPixelFormatAttribute)pixelFormatAttributes.depthBufferPrecision;

    if ( pixelFormatAttributes.stencilBuffered == YES )
    {
        attributes[counter++] = NSOpenGLPFAStencilSize;
        attributes[counter++] = (NSOpenGLPixelFormatAttribute)pixelFormatAttributes.stencilBufferPrecision;
    }

    if ( pixelFormatAttributes.multiSampleBuffer == YES )
    {
        attributes[counter++] = NSOpenGLPFASampleBuffers;
        attributes[counter++] = (NSOpenGLPixelFormatAttribute)1;

        attributes[counter++] = NSOpenGLPFASamples;
        attributes[counter++] = (NSOpenGLPixelFormatAttribute)pixelFormatAttributes.sampleCount;
    }

    attributes[counter] = (NSOpenGLPixelFormatAttribute)0;

    return attributes;
}

- (BOOL) setup
{
    pixelFormat = [ [ NSOpenGLPixelFormat alloc ] initWithAttributes:[self buildAttributes] ];

    if ( pixelFormat == nil )
    {
        return NO;
    }

    ready = YES;

    return YES;
}

- (NSOpenGLPixelFormat *)pixelFormat
{
    return pixelFormat;
}

- (BOOL) isReady
{
    return ready;
}

- (void) setPixelFormatAttributes:(NPOpenGLPixelFormatAttributes)newPixelFormatAttributes
{
    pixelFormatAttributes = newPixelFormatAttributes;
}

- (void) setFullScreen:(BOOL)fullscreen
{
    if ( pixelFormatAttributes.fullscreen != fullscreen )
    {
        pixelFormatAttributes.fullscreen = fullscreen;
    }
}

- (BOOL) fullscreen
{
    return pixelFormatAttributes.fullscreen;
}

- (void) setBitsPerColorChannel:(Int32)newBitsPerColorChannel
{
    if ( pixelFormatAttributes.bitsPerColorChannel != newBitsPerColorChannel )
    {
        pixelFormatAttributes.bitsPerColorChannel = newBitsPerColorChannel;
    }
}

- (Int32)bitsPerColorChannel
{
    return pixelFormatAttributes.bitsPerColorChannel;
}

- (void) setAlphaBits:(Int32)newAlphaChannelBits
{
    if ( pixelFormatAttributes.alphaChannelBits != newAlphaChannelBits )
    {
        pixelFormatAttributes.alphaChannelBits = newAlphaChannelBits;
    }
}

- (Int32) alphaChannelBits
{
    return pixelFormatAttributes.alphaChannelBits;
}

- (void) setDoubleBuffer:(BOOL)doubleBuffered
{
    if ( pixelFormatAttributes.doubleBuffered != doubleBuffered )
    {
        pixelFormatAttributes.doubleBuffered = doubleBuffered;
    }    
}

- (BOOL) doubleBuffered
{
    return pixelFormatAttributes.doubleBuffered;
}

- (void) setDepthBufferPrecision:(Int32)newDepthBufferPrecision
{
    if ( pixelFormatAttributes.depthBufferPrecision != newDepthBufferPrecision )
    {
        pixelFormatAttributes.depthBufferPrecision = newDepthBufferPrecision;
    }     
}

- (Int32) depthBufferPrecision
{
    return pixelFormatAttributes.depthBufferPrecision;
}

- (void) setStencilBuffer:(BOOL)stencilBuffered
{
    if ( pixelFormatAttributes.stencilBuffered != stencilBuffered )
    {
        pixelFormatAttributes.stencilBuffered = stencilBuffered;
    } 
}

- (BOOL) stencilBuffered
{
    return pixelFormatAttributes.stencilBuffered;
}

- (void) setStencilBufferPrecision:(Int32)newStencilBufferPrecision
{
    if ( pixelFormatAttributes.stencilBufferPrecision != newStencilBufferPrecision )
    {
        pixelFormatAttributes.stencilBufferPrecision = newStencilBufferPrecision;
    }     
}

- (Int32) stencilBufferPrecision
{
    return pixelFormatAttributes.stencilBufferPrecision;
}

- (void) setMultiSampleBuffer:(BOOL)multiSampled
{
    if ( pixelFormatAttributes.multiSampleBuffer != multiSampled )
    {
        pixelFormatAttributes.multiSampleBuffer = multiSampled;
    }  
}

- (BOOL) multiSampled
{
    return pixelFormatAttributes.multiSampleBuffer;
}

- (void) setSampleCount:(Int32)newSampleCount
{
    if ( pixelFormatAttributes.sampleCount != newSampleCount )
    {
        pixelFormatAttributes.sampleCount = newSampleCount;
    }
}

- (Int32) sampleCount
{
    return pixelFormatAttributes.sampleCount;
}

@end
