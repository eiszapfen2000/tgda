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

- (NPPixelBuffer *) createPBOUsingImage:(NPImage *)image
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

    [ pixelBuffer uploadToGLUsingData:[image imageData]];
    [ pixelBuffers addObject:pixelBuffer ];    

    return [ pixelBuffer autorelease ];
}

- (NPPixelBuffer *) createPBOUsingRenderTexture:(NPRenderTexture *)renderTexture
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

    //[ pixelBuffer uploadToGLUsingData:[image imageData]];
    [ pixelBuffers addObject:pixelBuffer ];    

    return [ pixelBuffer autorelease ];
}

@end
