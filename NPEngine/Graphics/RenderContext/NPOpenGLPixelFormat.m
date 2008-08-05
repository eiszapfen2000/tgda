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
    return [ self initWithName:newName
                        parent:newParent
                    fullscreen:NO
           bitsPerColorChannel:8
              alphaChannelBits:8
                doubleBuffered:YES
               depthBufferBits:24
               stencilBuffered:NO
             stencilBufferBits:0
                          FSAA:NO
                   sampleCount:0 ];
}

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
{
    self = [ super initWithName:newName parent:newParent ];

    pixelFormatAttributes.fullscreen = fullscreen;
    pixelFormatAttributes.bitsPerColorChannel = colorBits;
    pixelFormatAttributes.alphaChannelBits = alphaBits;
    pixelFormatAttributes.doubleBuffered = doubleBuffer;
    pixelFormatAttributes.depthBufferPrecision = depthBits;
    pixelFormatAttributes.stencilBuffered = stencilBuffer;
    pixelFormatAttributes.stencilBufferPrecision = stencilBits;
    pixelFormatAttributes.multiSampleBuffer = multisampling;
    pixelFormatAttributes.sampleCount = samples;

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
    ready = NO;
    TEST_RELEASE(pixelFormat);

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

- (BOOL) ready
{
    return ready;
}

- (void) setPixelFormatAttributes:(NPOpenGLPixelFormatAttributes)newPixelFormatAttributes
{
    pixelFormatAttributes = newPixelFormatAttributes;
}

- (void) setFullscreen:(BOOL)fullscreen
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

- (Int32) bitsPerColorChannel
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
    if ( newDepthBufferPrecision == 24 || newDepthBufferPrecision == 16 )
    {
        pixelFormatAttributes.depthBufferPrecision = newDepthBufferPrecision;
    }     
}

- (Int32) depthBufferPrecision
{
    return pixelFormatAttributes.depthBufferPrecision;
}

- (void) setStencilBufferPrecision:(Int32)newStencilBufferPrecision
{
    if ( newStencilBufferPrecision > 0 )
    {
        pixelFormatAttributes.stencilBufferPrecision = newStencilBufferPrecision;
        pixelFormatAttributes.stencilBuffered = YES;
    }
    else
    {
        pixelFormatAttributes.stencilBufferPrecision = 0;
        pixelFormatAttributes.stencilBuffered = NO;
    }
}

- (Int32) stencilBufferPrecision
{
    return pixelFormatAttributes.stencilBufferPrecision;
}

- (void) setSampleCount:(Int32)newSampleCount
{
    if ( newSampleCount > 0 )
    {
        pixelFormatAttributes.sampleCount = newSampleCount;
        pixelFormatAttributes.multiSampleBuffer = YES;
    }
    else
    {
        pixelFormatAttributes.sampleCount = 0;
        pixelFormatAttributes.multiSampleBuffer = NO;
    }
}

- (Int32) sampleCount
{
    return pixelFormatAttributes.sampleCount;
}

@end
