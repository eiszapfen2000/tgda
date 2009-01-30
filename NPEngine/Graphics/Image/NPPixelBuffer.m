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
                    dataFormat:NP_NONE
                   pixelFormat:NP_NONE
                         usage:NP_NONE ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
               mode:(NpState)newMode
              width:(Int)newWidth
             height:(Int)newHeight
         dataFormat:(NpState)newDataFormat
        pixelFormat:(NpState)newPixelFormat
              usage:(NpState)newUsage
{
    self = [ super initWithName:newName parent:newParent ];

    [ self generateGLBufferID ];

    mode = newMode;
    width = newWidth;
    height = newHeight;
    dataFormat = newDataFormat;
    pixelFormat = newPixelFormat;
    usage = newUsage;
    currentTarget = GL_NONE;

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
    ownsBuffer = YES;
}

- (void) reset
{
    if ( pixelBufferID > 0 && ownsBuffer == YES )
    {
        glDeleteBuffers(1,&pixelBufferID);
    }

    width = height = -1;
    mode = NP_NONE;
    dataFormat = NP_NONE;
    pixelFormat = NP_NONE;
}

- (UInt) pixelBufferID
{
    return pixelBufferID;
}

- (Int) width
{
    return width;
}

- (Int) height
{
    return height;
}

- (NpState) dataFormat
{
    return dataFormat;
}

- (NpState) pixelFormat
{
    return pixelFormat;
}

- (void) setPixelBufferID:(UInt)newPixelBufferID
{
    if ( pixelBufferID > 0 )
    {
        glDeleteBuffers(1,&pixelBufferID);
    }

    pixelBufferID = newPixelBufferID;
    ownsBuffer = NO;
}

- (void) setWidth:(Int)newWidth
{
    width = newWidth;
}

- (void) setHeight:(Int)newHeight
{
    height = newHeight;
}

- (void) setDataFormat:(NpState)newDataFormat
{
    dataFormat = newDataFormat;
}

- (void) setPixelFormat:(NpState)newPixelFormat
{
    pixelFormat = newPixelFormat;
}

- (BOOL) isCompatibleWithImage:(NPImage *)image
{
    return ( (dataFormat  != [image dataFormat])  ||
             (pixelFormat != [image pixelFormat]) ||
             (width       != [image width])       ||
             (height      != [image height]) );
}

- (BOOL) isCompatibleWithRenderTexture:(NPRenderTexture *)renderTexture
{
    return ( (dataFormat  == [renderTexture dataFormat])  &&
             (pixelFormat == [renderTexture pixelFormat]) &&
             (width       == [renderTexture width])       &&
             (height      == [renderTexture height]) );
}

- (BOOL) isCompatibleWithTexture:(NPTexture *)texture
{
    return ( (dataFormat  == [texture dataFormat])  && 
             (pixelFormat == [texture pixelFormat]) &&
             (width       == [texture width])       &&
             (height      == [texture height]) );
}

- (BOOL) isCompatibleWithFramebuffer
{
    IVector2 nativeViewport = [[[[ NP Graphics ] viewportManager ] nativeViewport ] viewportSize ];

    return ( (dataFormat  == NP_GRAPHICS_PBO_DATAFORMAT_BYTE)  && 
             (pixelFormat == NP_GRAPHICS_PBO_PIXELFORMAT_RGBA) &&
             (width       == nativeViewport.x)                 &&
             (height      == nativeViewport.y) );
}


- (void) calculatePBOTarget
{
    switch ( mode )
    {
        case NP_GRAPHICS_PBO_AS_DATA_TARGET:{ currentTarget = GL_PIXEL_PACK_BUFFER; break; }
        case NP_GRAPHICS_PBO_AS_DATA_SOURCE:{ currentTarget = GL_PIXEL_UNPACK_BUFFER; break; }
        default:{ NPLOG(@"Invalid mode specified for PBO %@",name); }
    }
}

- (void) uploadToGLWithoutData
{
    NSData * emptyData = [[ NSData alloc ] init ];
    [ self uploadToGLUsingData:emptyData ];
    [ emptyData release ];
}

- (void) uploadToGLUsingData:(NSData *)data
{
    UInt byteCount = width * height * [[[ NP Graphics ] imageManager ] calculatePixelByteCountUsingDataFormat:dataFormat pixelFormat:pixelFormat ];

    [ self uploadToGLUsingData:data byteCount:byteCount ];
}

- (void) uploadToGLUsingData:(NSData *)data byteCount:(UInt)byteCount
{
    //[ self calculatePBOTarget ];

    GLenum glusage = [[[ NP Graphics ] pixelBufferManager ] computeGLUsage:usage ];

    glBindBuffer(GL_PIXEL_PACK_BUFFER, pixelBufferID);
    glBufferData(GL_PIXEL_PACK_BUFFER, byteCount, [data bytes], glusage);
    glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
}

- (void) activate
{
    [[[ NP Graphics ] pixelBufferManager ] setCurrentPixelBuffer:self ];

    [ self calculatePBOTarget ];
    glBindBuffer(currentTarget, pixelBufferID);
}

- (void) activateForReading
{
    [[[ NP Graphics ] pixelBufferManager ] setCurrentPixelBuffer:self ];

    currentTarget = GL_PIXEL_UNPACK_BUFFER;
    glBindBuffer(currentTarget, pixelBufferID);
}

- (void) activateForWriting
{
    [[[ NP Graphics ] pixelBufferManager ] setCurrentPixelBuffer:self ];

    currentTarget = GL_PIXEL_PACK_BUFFER;
    glBindBuffer(currentTarget, pixelBufferID);
}

- (void) deactivate
{
    glBindBuffer(currentTarget, 0);

    [[[ NP Graphics ] pixelBufferManager ] setCurrentPixelBuffer:nil ];
}

@end
