#import "NPPixelBufferManager.h"
#import "NPPixelBuffer.h"
#import "NPImage.h"
#import "NP.h"

@implementation NPPixelBufferManager

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPPixelBufferManager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    pixelBuffers = [[ NSMutableArray alloc ] init ];
    currentPixelBuffer = nil;

    return self;
}

- (void) dealloc
{
    [ pixelBuffers removeAllObjects ];
    [ pixelBuffers release ];

    [ super dealloc ];
}

- (NPPixelBuffer *) currentPixelBuffer
{
    return currentPixelBuffer;
}

- (void) setCurrentPixelBuffer:(NPPixelBuffer *)newCurrentPixelBuffer
{
    ASSIGN(currentPixelBuffer,newCurrentPixelBuffer);
}

- (GLenum) computeGLColorBuffer:(NpState)colorbuffer
{
    GLenum glcolorbuffer = 0;
    Int colorBufferCount = [[[ NP Graphics ] renderTargetManager ] colorBufferCount ];

    if ( colorBufferCount > 0 )
    {
        if ( colorbuffer >= NP_GRAPHICS_COLORBUFFER_0 && colorbuffer <= colorBufferCount )
        {
            glcolorbuffer = GL_COLOR_ATTACHMENT0_EXT + colorbuffer;
        }
        else
        {
            NPLOG_ERROR(([NSString stringWithFormat:@"Unknown colorbuffer %d",colorbuffer]));
        }
    }

    return glcolorbuffer;
}

- (GLenum) computeGLFrameBuffer:(NpState)framebuffer
{
    GLenum glframebuffer = 0;

    if ( framebuffer > NP_NONE && framebuffer <= NP_GRAPHICS_FRAMEBUFFER_BACK )
    {
        glframebuffer = GL_FRONT_LEFT + framebuffer;
    }
    else
    {
        NPLOG_ERROR(([NSString stringWithFormat:@"Unknown framebuffer %d",framebuffer]));
    }

    return glframebuffer;
}

- (NPPixelBuffer *) createPBOCompatibleWithImage:(NPImage *)image
{
    NSString * pboName = [ NSString stringWithFormat:@"PBOFrom%@", [ image name ]];
    NPPixelBuffer * pixelBuffer = [[ NPPixelBuffer alloc ] initWithName:pboName
                                                                 parent:self
                                                                   mode:NP_GRAPHICS_PBO_AS_DATA_SOURCE
                                                                  width:[image width]
                                                                 height:[image height]
                                                               dataType:[image dataFormat]
                                                            pixelFormat:[image pixelFormat]
                                                                  usage:NP_GRAPHICS_PBO_UPLOAD_ONCE_USE_OFTEN ];
    [ pixelBuffers addObject:pixelBuffer ];    

    return [ pixelBuffer autorelease ];
}

- (NPPixelBuffer *) createPBOCompatibleWithRenderTexture:(NPRenderTexture *)renderTexture
{
    NSString * pboName = [ NSString stringWithFormat:@"PBOFrom%@", [ renderTexture name ]];
    NPPixelBuffer * pixelBuffer = [[ NPPixelBuffer alloc ] initWithName:pboName
                                                                 parent:self
                                                                   mode:NP_GRAPHICS_PBO_AS_DATA_SOURCE
                                                                  width:[renderTexture width]
                                                                 height:[renderTexture height]
                                                               dataType:[renderTexture dataFormat]
                                                            pixelFormat:[renderTexture pixelFormat]
                                                                  usage:NP_GRAPHICS_PBO_UPLOAD_ONCE_USE_OFTEN ];
    [ pixelBuffers addObject:pixelBuffer ];    

    return [ pixelBuffer autorelease ];
}

- (NPPixelBuffer *) createPBOCompatibleWithFramebuffer
{
    IVector2 nativeViewport = [[[[ NP Graphics ] viewportManager ] nativeViewport ] viewportSize ];
    NPPixelBuffer * pixelBuffer = [[ NPPixelBuffer alloc ] initWithName:@"PBOFromFramebuffer"
                                                                 parent:self
                                                                   mode:NP_GRAPHICS_PBO_AS_DATA_SOURCE
                                                                  width:nativeViewport.x
                                                                 height:nativeViewport.y
                                                               dataType:NP_GRAPHICS_PBO_DATAFORMAT_BYTE
                                                            pixelFormat:NP_GRAPHICS_PBO_PIXELFORMAT_RGBA
                                                                  usage:NP_GRAPHICS_PBO_UPLOAD_ONCE_USE_OFTEN ];
    [ pixelBuffers addObject:pixelBuffer ];    

    return [ pixelBuffer autorelease ];
}

- (void) copyImage:(NPImage *)image toPBO:(NPPixelBuffer *)pbo
{
    if ( [ pbo isCompatibleWithImage:image ] == YES )
    {
        [ pbo uploadToGLUsingData:[image imageData]];
    }
}

- (void) copyRenderTexture:(NPRenderTexture *)renderTexture toPBO:(NPPixelBuffer *)pbo
{
    if ( [ pbo isCompatibleWithRenderTexture:renderTexture ] == YES )
    {
        NpState colorbuffer = (NpState)[ renderTexture colorBufferIndex ];
        GLenum glcolorbuffer = [ self computeGLColorBuffer:colorbuffer ];
        glReadBuffer(glcolorbuffer);

        GLenum gldataformat  = [[[ NP Graphics ] textureManager ] computeGLDataFormat :[renderTexture dataFormat ]];
        GLenum glpixelformat = [[[ NP Graphics ] textureManager ] computeGLPixelFormat:[renderTexture pixelFormat]];

        [ pbo activateForWriting ];
        glReadPixels(0, 0, [pbo width], [pbo height], glpixelformat, gldataformat, 0);
        [ pbo deactivate ];

        glReadBuffer(GL_NONE);
    }
}

- (void) copyFramebuffer:(NpState)framebuffer toPBO:(NPPixelBuffer *)pbo
{
    if ( [ pbo isCompatibleWithFramebuffer ] == YES )
    {
        GLenum glframebuffer = [ self computeGLFrameBuffer:framebuffer ];
        glReadBuffer(glframebuffer);

        [ pbo activateForWriting ];
        glReadPixels(0, 0, [pbo width], [pbo height], GL_RGBA, GL_UNSIGNED_BYTE, 0);
        [ pbo deactivate ];

        glReadBuffer(GL_NONE);
    }
}

- (void) copyPBO:(NPPixelBuffer *)pbo toTexture:(NPTexture *)texture
{
    if ( [ pbo isCompatibleWithTexture:texture ] == YES )
    {
        [ pbo activateForReading ];
        [ pbo deactivate ];
    }
}


@end
