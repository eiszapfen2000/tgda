#import "NPPixelBuffer.h"
#import "NP.h"

@implementation NPPixelBuffer

- (id) init
{
    return [ self initWithName:@"NPPixelBuffer" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName
                        parent:newParent
                          mode:NP_NONE
                         width:-1
                        height:-1
                      dataType:NP_NONE
                   pixelFormat:NP_NONE
                         usage:NP_NONE ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
               mode:(NpState)newMode
              width:(Int)newWidth
             height:(Int)newHeight
           dataType:(NpState)newDataType
        pixelFormat:(NpState)newPixelFormat
              usage:(NpState)newUsage
                   ;
{
    self = [ super initWithName:newName parent:newParent ];

    [ self generateGLBufferID ];

    mode = newMode;
    width = newWidth;
    height = newHeight;
    dataType = newDataType;
    pixelFormat = newPixelFormat;
    usage = newUsage;

    return self;
}

- (void) dealloc
{
    [ self reset ];
    [ super dealloc ];
}

- (void) generateGLBufferID
{
    glGenBuffers(1, &pixelBufferID);
}

- (void) reset
{
    if ( pixelBufferID > 0 )
    {
        glDeleteBuffers(1,&pixelBufferID);
    }

    width = height = -1;
    mode = NP_NONE;
    dataType = NP_NONE;
    pixelFormat = NP_NONE;
}

- (Int) width
{
    return width;
}

- (Int) height
{
    return height;
}

- (BOOL) isCompatibleWithImage:(NPImage *)image
{
    return ( (dataType    != [image dataFormat])  ||
             (pixelFormat != [image pixelFormat]) ||
             (width       != [image width])       ||
             (height      != [image height]) );
}

- (BOOL) isCompatibleWithRenderTexture:(NPRenderTexture *)renderTexture
{
    return ( (dataType    != [renderTexture dataFormat])  || 
             (pixelFormat != [renderTexture pixelFormat]) ||
             (width       != [renderTexture width])       ||
             (height      != [renderTexture height]) );
}

- (BOOL) isCompatibleWithTexture:(NPTexture *)texture
{
    return ( (dataType    != [texture dataFormat])  || 
             (pixelFormat != [texture pixelFormat]) ||
             (width       != [texture width])       ||
             (height      != [texture height]) );
}

- (BOOL) isCompatibleWithFramebuffer
{
    IVector2 nativeViewport = [[[[ NP Graphics ] viewportManager ] nativeViewport ] viewportSize ];

    return ( (dataType    != NP_GRAPHICS_PBO_DATAFORMAT_BYTE)  || 
             (pixelFormat != NP_GRAPHICS_PBO_PIXELFORMAT_RGBA) ||
             (width       != nativeViewport.x)                 ||
             (height      != nativeViewport.y) );
}


- (GLenum) calculatePBOTarget
{
    GLenum target = 0;

    switch ( mode )
    {
        case NP_GRAPHICS_PBO_AS_DATA_TARGET:{ mode = GL_PIXEL_PACK_BUFFER; break; }
        case NP_GRAPHICS_PBO_AS_DATA_SOURCE:{ mode = GL_PIXEL_UNPACK_BUFFER; break; }
        default:{ NPLOG(([NSString stringWithFormat:@"Invalid mode specified for %@",name])); }
    }

    return target;
}

- (void) uploadToGLWithoutData
{
    NSData * emptyData = [[ NSData alloc ] init ];
    [ self uploadToGLUsingData:emptyData ];
    [ emptyData release ];
}

- (void) uploadToGLUsingData:(NSData *)data
{
    UInt byteCount = width * height * [[[ NP Graphics ] imageManager ] calculatePixelByteCountUsingDataFormat:dataType pixelFormat:pixelFormat ];

    if ( byteCount != [ data length ] )
    {
        NPLOG_ERROR(([ NSString stringWithFormat:@"%@ byte count does not match supplied data byte count",name ]));
        return;
    }

    GLenum target = [ self calculatePBOTarget ];
    glBindBuffer(target, pixelBufferID);
    glBufferData(target, byteCount, [data bytes], GL_DYNAMIC_DRAW);
    glBindBuffer(target, 0);
}

- (void) activate
{
    [[[ NP Graphics ] pixelBufferManager ] setCurrentPixelBuffer:self ];

    GLenum target = [ self calculatePBOTarget ];
    glBindBuffer(target, pixelBufferID);
}

- (void) activateForReading
{
    [[[ NP Graphics ] pixelBufferManager ] setCurrentPixelBuffer:self ];

    glBindBuffer(GL_PIXEL_UNPACK_BUFFER, pixelBufferID);
}

- (void) activateForWriting
{
    [[[ NP Graphics ] pixelBufferManager ] setCurrentPixelBuffer:self ];

    glBindBuffer(GL_PIXEL_PACK_BUFFER, pixelBufferID);
}

- (void) deactivate
{
    GLenum target = [ self calculatePBOTarget ];
    glBindBuffer(target, 0);

    [[[ NP Graphics ] pixelBufferManager ] setCurrentPixelBuffer:nil ];
}

@end
