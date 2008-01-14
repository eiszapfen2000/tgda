#import "NPOpenGLPixelFormat.h"

#import "Core/Basics/Memory.h"

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
    pixelFormatAttributes.doubleBuffered = YES;
    pixelFormatAttributes.depthBufferPrecision = 32;
    pixelFormatAttributes.stencilBuffered = NO;
    pixelFormatAttributes.stencilBufferPrecision = 0;
    pixelFormatAttributes.multiSampleBuffer = NO;
    pixelFormatAttributes.sampleCount = 1;

    pixelFormat = nil;

    return self;
}

- (void) dealloc
{
    [ pixelFormat release ];

    [ super dealloc ];
}


- (Int32) countAndCheckAttributes
{
    // Initialized to 4, because NSOpenGLPFAColorSize and NSOpenGLPFAlphaSize are included;
    Int32 attributeCounter = 4;

    if ( pixelFormatAttributes.fullscreen == YES )
    {
        attributeCounter++;
    }

    if ( pixelFormatAttributes.doubleBuffered == YES )
    {
        attributeCounter++;
    }

    if ( pixelFormatAttributes.depthBufferPrecision != 24 || pixelFormatAttributes.depthBufferPrecision != 32 )
    {
        pixelFormatAttributes.depthBufferPrecision = 32;

        attributeCounter++;
    }

    if ( pixelFormatAttributes.stencilBuffered == YES )
    {
        if ( pixelFormatAttributes.depthBufferPrecision == 32 )
        {
            pixelFormatAttributes.depthBufferPrecision = 24;
        }

        attributeCounter++;        
    }

    if ( pixelFormatAttributes.multiSampleBuffer == YES )
    {
        attributeCounter++;

        if ( pixelFormatAttributes.sampleCount < 1 || pixelFormatAttributes.sampleCount > 16 )
        {
            pixelFormatAttributes.sampleCount = 4;
        }

        attributeCounter++;
    }

    return attributeCounter;    
}

- (NSOpenGLPixelFormatAttribute *)buildAttributes
{
    Int32 arraySize = [ self countAndCheckAttributes ];    

    NSOpenGLPixelFormatAttribute * attributes = ALLOC_ARRAY(NSOpenGLPixelFormatAttribute,arraySize);
    
    Int32 counter = 0;

    attributes[counter++] = NSOpenGLPFAColorSize;
    attributes[counter++] = (NSOpenGLPixelFormatAttribute)8;

    attributes[counter++] = NSOpenGLPFAAlphaSize;
    attributes[counter++] = (NSOpenGLPixelFormatAttribute)8;


    if ( pixelFormatAttributes.fullscreen == YES )
    {
        attributes[counter++] = NSOpenGLPFAFullScreen;
    }

    if ( pixelFormatAttributes.doubleBuffered == YES )
    {
        attributes[counter++] = NSOpenGLPFADoubleBuffer;
    }

    attributes[counter++] = NSOpenGLPFADepthSize;
    attributes[counter++] = (NSOpenGLPixelFormatAttribute)pixelFormatAttributes.depthBufferPrecision;
    

    if ( pixelFormatAttributes.stencilBuffered == YES )
    {
        attributes[counter++] = (NSOpenGLPixelFormatAttribute)pixelFormatAttributes.stencilBufferPrecision;
    }

    if ( pixelFormatAttributes.multiSampleBuffer == YES )
    {
        attributes[counter++] = NSOpenGLPFASampleBuffers;
        attributes[counter++] = (NSOpenGLPixelFormatAttribute)1;

        attributes[counter++] = NSOpenGLPFASamples;
        attributes[counter++] = (NSOpenGLPixelFormatAttribute)pixelFormatAttributes.sampleCount;
    }

    return attributes;
}

- (void) setup
{
    pixelFormat = [ [ NSOpenGLPixelFormat alloc ] initWithAttributes:[ self buildAttributes ] ];
}

- (NSOpenGLPixelFormat *)pixelFormat
{
    return pixelFormat;
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
