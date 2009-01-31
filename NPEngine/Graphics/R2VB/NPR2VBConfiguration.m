#import "NPR2VBConfiguration.h"
#import "NP.h"

@implementation NPR2VBConfiguration


- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NP R2VB Configuration" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    mode = NP_NONE;
    sources = [[ NSMutableDictionary alloc ] init ];
    targets = nil;

    return self;
}

- (void) dealloc
{
    [ targets removeAllObjects ];
    [ sources removeAllObjects ];

    [ targets release ];
    [ sources release ];

    [ super dealloc ];
}

- (void) setTarget:(NPVertexBuffer *)newTarget
{
    if ( targets != nil )
    {
        [ targets removeAllObjects ];
        [ targets release ];
    }

    targets = [[[[ NP Graphics ] pixelBufferManager ] createPBOsSharingDataWithVBO:newTarget ] retain ];
}

- (void) setRenderTextureSource:(NPRenderTexture *)renderTexture forTargetBuffer:(NSString *)targetBuffer
{
    if ( mode != NP_NONE && mode != NP_GRAPHICS_R2VB_FRAMEBUFFER_MODE )
    {
        if ( [[[[ NP Graphics ] r2vbManager ] bufferKeys ] containsObject:targetBuffer ] == YES )
        {
            NPPixelBuffer * pbo = [ targets objectForKey:targetBuffer ];
            if ( pbo != nil )
            {
                [ sources setObject:renderTexture forKey:targetBuffer ];
                [ pbo setWidth :[renderTexture width ]];
                [ pbo setHeight:[renderTexture height]];
            }
            else
            {
                NPLOG_ERROR(@"%@: invalid buffer %@ specified",name,targetBuffer);
            }
        }
    }
    else
    {
        NPLOG_ERROR(@"%@: wrong mode %d",name,mode);
    }
}

//FIXME
- (void) setFrameBufferSource:(NpState)frameBuffer forTargetBuffer:(NSString *)targetBuffer
{
    if ( mode != NP_NONE && mode != NP_GRAPHICS_R2VB_RENDERTEXTURE_MODE )
    {
        if ( [[[ NP Graphics ] r2vbManager ] isValidBufferKey:targetBuffer ] == YES )
        {
            NPPixelBuffer * pbo = [ targets objectForKey:targetBuffer ];
            if ( pbo != nil )
            {
                [ sources setObject:[NSNumber numberWithInt:frameBuffer] forKey:targetBuffer ];

                IVector2 nativeViewport = [[[[ NP Graphics ] viewportManager ] nativeViewport ] viewportSize ];

                [ pbo setWidth :nativeViewport.x ];
                [ pbo setHeight:nativeViewport.y ];
            }
            else
            {
                NPLOG_ERROR(@"%@: invalid buffer %@ specified",name,targetBuffer);
            }
        }
    }
    else
    {
        NPLOG_ERROR(@"%@: wrong mode %d",name,mode);
    }
}

- (void) copyBuffers
{
    UInt sourcesCount = [ sources count ];
    UInt targetsCount = [ targets count ];

    if ( sourcesCount != targetsCount )
    {
        NPLOG_ERROR(@"%@: %d sources vs %d targets",name,sourcesCount,targetsCount);
        return;
    }

    NSEnumerator * sourcesEnumerator = [ sources objectEnumerator ];
    NSEnumerator * targetsEnumerator = [ targets objectEnumerator ];
    id source, target;

    switch ( mode )
    {
        case NP_GRAPHICS_R2VB_FRAMEBUFFER_MODE:
        {
            while (( source = [ sourcesEnumerator nextObject ] ) && ( target = [ targetsEnumerator nextObject ] ))
            {
                [[[ NP Graphics ] pixelBufferManager ] copyFramebuffer:[ source intValue ]
                                                                 toPBO:target ];
            }

            break;
        }

        case NP_GRAPHICS_R2VB_RENDERTEXTURE_MODE:
        {
            while (( source = [ sourcesEnumerator nextObject ] ) && ( target = [ targetsEnumerator nextObject ] ))
            {
                [[[ NP Graphics ] pixelBufferManager ] copyRenderTexture:source
                                                                   toPBO:target ];
            }
            
            break;
        }

        default:
        {
            NPLOG_ERROR(@"%@: invalid mode %d specified",name,mode);
            break;
        }
    }
}

@end
