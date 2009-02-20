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

- (GLenum) computeGLUsage:(NpState)usage
{
    GLenum pboUsage = GL_NONE;

    switch( usage )
    {
        case NP_GRAPHICS_PBO_UPLOAD_ONCE_USE_OFTEN :{ pboUsage = GL_STATIC_DRAW;  break; }
        case NP_GRAPHICS_PBO_UPLOAD_ONCE_USE_SELDOM:{ pboUsage = GL_STREAM_DRAW;  break; }
        case NP_GRAPHICS_PBO_UPLOAD_OFTEN_USE_OFTEN:{ pboUsage = GL_DYNAMIC_DRAW; break; }
        default: { pboUsage = GL_STATIC_DRAW; break; }
    }

    return pboUsage;
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
            NPLOG_ERROR(@"%@: Unknown colorbuffer %d",name,colorbuffer);
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
        NPLOG_ERROR(@"%@: Unknown framebuffer %d",name,framebuffer);
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
                                                             dataFormat:[image dataFormat]
                                                            pixelFormat:[image pixelFormat]
                                                                  usage:NP_GRAPHICS_PBO_UPLOAD_ONCE_USE_OFTEN ];
    [ pixelBuffers addObject:pixelBuffer ];    

    return [ pixelBuffer autorelease ];
}

- (NPPixelBuffer *) createPBOCompatibleWithRenderTexture:(NPRenderTexture *)renderTexture
{
    return [ self createPBOCompatibleWithTexture:[renderTexture texture]];
}

- (NPPixelBuffer *) createPBOCompatibleWithTexture:(NPTexture *)texture
{
    NSString * pboName = [ NSString stringWithFormat:@"PBOFrom%@", [ texture name ]];
    NPPixelBuffer * pixelBuffer = [[ NPPixelBuffer alloc ] initWithName:pboName
                                                                 parent:self
                                                                   mode:NP_GRAPHICS_PBO_AS_DATA_SOURCE
                                                                  width:[texture width]
                                                                 height:[texture height]
                                                             dataFormat:[texture dataFormat]
                                                            pixelFormat:[texture pixelFormat]
                                                                  usage:NP_GRAPHICS_PBO_UPLOAD_ONCE_USE_OFTEN ];
    [ pixelBuffers addObject:pixelBuffer ];    

    return [ pixelBuffer autorelease ];
}

- (NPPixelBuffer *) createPBOCompatibleWithFramebuffer
{
    IVector2 * nativeViewport = [[[[ NP Graphics ] viewportManager ] currentViewport ] controlSize ];
    NPPixelBuffer * pixelBuffer = [[ NPPixelBuffer alloc ] initWithName:@"PBOFromFramebuffer"
                                                                 parent:self
                                                                   mode:NP_GRAPHICS_PBO_AS_DATA_SOURCE
                                                                  width:nativeViewport->x
                                                                 height:nativeViewport->y
                                                             dataFormat:NP_GRAPHICS_PBO_DATAFORMAT_BYTE
                                                            pixelFormat:NP_GRAPHICS_PBO_PIXELFORMAT_RGBA
                                                                  usage:NP_GRAPHICS_PBO_UPLOAD_ONCE_USE_OFTEN ];
    [ pixelBuffers addObject:pixelBuffer ];

    return [ pixelBuffer autorelease ];
}

- (NSDictionary *) createPBOsSharingDataWithVBO:(NPVertexBuffer *)vbo
{
    NSMutableDictionary * pbos = [[ NSMutableDictionary alloc ] init ];

    if ( [ vbo hasVBO ] == YES )
    {
        NpVertexFormat * vertexFormat = [ vbo vertexFormat ];
        NpVertexBuffer * vertexBuffer = [ vbo vertexBuffer ];

        if ( vertexFormat->elementsForPosition > 0 )
        {
            NSString * pboName = [ NSString stringWithFormat:@"PBO_%@_Position",[vbo name]];
            NPPixelBuffer * pbo = [[ NPPixelBuffer alloc ] initWithName:pboName parent:self ];
            [ pbo setPixelBufferID:vertexBuffer->positionsID ];
            [ pbo setDataFormat:vertexFormat->positionsDataFormat ];
            [ pbo setPixelFormat:(vertexFormat->elementsForPosition-1) ];
            [ pbos setObject:pbo forKey:@"Positions" ];
            [ pixelBuffers addObject:pbo ];
            [ pbo release ];
        }

        if ( vertexFormat->elementsForNormal > 0 )
        {
            NSString * pboName = [ NSString stringWithFormat:@"PBO_%@_Normal",[vbo name]];
            NPPixelBuffer * pbo = [[ NPPixelBuffer alloc ] initWithName:pboName parent:self ];
            [ pbo setPixelBufferID:vertexBuffer->normalsID ];
            [ pbo setDataFormat:vertexFormat->normalsDataFormat ];
            [ pbo setPixelFormat:(vertexFormat->elementsForNormal-1) ];
            [ pbos setObject:pbo forKey:@"Normals" ];
            [ pixelBuffers addObject:pbo ];
            [ pbo release ];
        }

        if ( vertexFormat->elementsForColor > 0 )
        {
            NSString * pboName = [ NSString stringWithFormat:@"PBO_%@_Color",[vbo name]];
            NPPixelBuffer * pbo = [[ NPPixelBuffer alloc ] initWithName:pboName parent:self ];
            [ pbo setPixelBufferID:vertexBuffer->colorsID ];
            [ pbo setDataFormat:vertexFormat->colorsDataFormat ];
            [ pbo setPixelFormat:(vertexFormat->elementsForColor-1) ];
            [ pbos setObject:pbo forKey:@"Colors" ];
            [ pixelBuffers addObject:pbo ];
            [ pbo release ];
        }

        if ( vertexFormat->elementsForColor > 0 )
        {
            NSString * pboName = [ NSString stringWithFormat:@"PBO_%@_Weight",[vbo name]];
            NPPixelBuffer * pbo = [[ NPPixelBuffer alloc ] initWithName:pboName parent:self ];
            [ pbo setPixelBufferID:vertexBuffer->weightsID ];
            [ pbo setDataFormat:vertexFormat->weightsDataFormat ];
            [ pbo setPixelFormat:(vertexFormat->elementsForWeights-1) ];
            [ pbos setObject:pbo forKey:@"Weights" ];
            [ pixelBuffers addObject:pbo ];
            [ pbo release ];
        }

        for ( Int i = 0; i < 8; i++ )
        {
            if ( vertexFormat->elementsForTextureCoordinateSet[i] > 0 )
            {
                NSString * pboName = [ NSString stringWithFormat:@"PBO_%@_Texcoord%d",[vbo name],i];
                NPPixelBuffer * pbo = [[ NPPixelBuffer alloc ] initWithName:pboName parent:self ];
                [ pbo setPixelBufferID:vertexBuffer->textureCoordinatesSetID[i] ];
                [ pbo setDataFormat:vertexFormat->textureCoordinatesDataFormat[i] ];
                [ pbo setPixelFormat:(vertexFormat->elementsForTextureCoordinateSet[i]-1) ];
                [ pbos setObject:pbo forKey:[NSString stringWithFormat:@"Texcoord%d",i]];
                [ pixelBuffers addObject:pbo ];
                [ pbo release ];
            }
        }
    }
    else
    {
        NPLOG_ERROR(@"%@: %@ not uploaded to GL",name,[vbo name]);
    }

    return [ pbos autorelease ];
}

- (NSDictionary *) createPBOsSharingDataWithLOD:(NPSUXModelLod *)lod
{
    return [ self createPBOsSharingDataWithVBO:[lod vertexBuffer]];
}

- (NSDictionary *) createPBOsSharingDataWithModel:(NPSUXModel *)model lodIndex:(Int)lodIndex
{
    return [ self createPBOsSharingDataWithLOD:[ model lodAtIndex:lodIndex ]];
}

- (NPTexture *) createTextureCompatibleWithPBO:(NPPixelBuffer *)pbo
{
    NSString * textureName = [ NSString stringWithFormat:@"TextureFrom%@", [ pbo name ]];
    NPTexture * texture = [[ NPTexture alloc ] initWithName:textureName parent:self ];
    [ texture setWidth:[pbo width]];
    [ texture setHeight:[pbo height]];
    [ texture setDataFormat:[pbo dataFormat]];
    [ texture setPixelFormat:[pbo pixelFormat]];
    [ texture setMipMapping:NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_INACTIVE ];
    [ texture setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [ texture setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [ texture setTextureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP ];
    [ texture setTextureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP ];
    [ texture uploadToGLWithoutData ];

    return texture;   
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
        if ( [[[ NP Graphics ] renderTargetManager ] currentRenderTargetConfiguration ] != nil )
        {
            NpState colorbuffer = (NpState)[ renderTexture colorBufferIndex ];
            GLenum glcolorbuffer = [ self computeGLColorBuffer:colorbuffer ];
            glReadBuffer(glcolorbuffer);

            GLenum gldataformat  = [[[ NP Graphics ] textureManager ] computeGLDataFormat :[renderTexture dataFormat ]];
            GLenum glpixelformat = [[[ NP Graphics ] textureManager ] computeGLPixelFormat:[renderTexture pixelFormat]];

            [ pbo activateForWriting ];

            glReadPixels(0, 0, [renderTexture width], [renderTexture height], glpixelformat, gldataformat, 0);

            [ pbo deactivate ];

            glReadBuffer(GL_NONE);
        }
        else
        {
            NPLOG_ERROR(@"%@: No RenderTexture active, cannot copy",name);
        }
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
        glBindTexture(GL_TEXTURE_2D, [texture textureID]);
        [ pbo activateForReading ];
        [ texture uploadToGLWithoutData ];
        [ pbo deactivate ];
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}


@end
