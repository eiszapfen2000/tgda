#import "NPImageManager.h"
#import "NPImage.h"
#import "NP.h"

#import "IL/il.h"
#import "IL/ilu.h"

@implementation NPImageManager

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPImageManager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    images = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ images removeAllObjects ];
    [ images release ];

    [ super dealloc ];
}

- (void) setup
{
    NPLOG(@"NPImageManager setup...");
    NPLOG(@"Initialising DevIL...");

    Int devilVersion = ilGetInteger(IL_VERSION_NUM);
    NPLOG(([NSString stringWithFormat:@"DevIL version is %d",devilVersion ]));

    if ( devilVersion < IL_VERSION)
    {
        NPLOG_WARNING(@"DevIL library version %d does not match DevIL header version %d", devilVersion, IL_VERSION);
    }

    ilInit();
    iluInit();

    NPLOG(@"NPImageManager ready");
}

- (id) loadImageFromPath:(NSString *)path
{
    NSString * absolutePath = [ [ [ NPEngineCore instance ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadImageFromAbsolutePath:absolutePath ];
}

- (id) loadImageFromAbsolutePath:(NSString *)path;
{
    NPLOG(@"%@: loading %@", name, path);

    if ( [ path isEqual:@"" ] == NO )
    {
        NPImage * image = [ images objectForKey:path ];

        if ( image == nil )
        {
            NPImage * image = [[ NPImage alloc ] initWithName:@"" parent:self ];

            if ( [ image loadFromPath:path ] == YES )
            {
                [ images setObject:image forKey:path ];
                [ image release ];

                return image;
            }
            else
            {
                [ image release ];

                return nil;
            }
        }

        return image;
    }

    return nil;    
}

- (Int) calculateDataFormatByteCount:(NpState)dataFormat
{
    Int dataFormatByteCount = 0;
    switch ( dataFormat )
    {
        case NP_GRAPHICS_IMAGE_DATAFORMAT_BYTE :{ dataFormatByteCount = 1; break; }
        case NP_GRAPHICS_IMAGE_DATAFORMAT_HALF :{ dataFormatByteCount = 2; break; }
        case NP_GRAPHICS_IMAGE_DATAFORMAT_FLOAT:{ dataFormatByteCount = 4; break; }
        default:{ NPLOG_ERROR(@"Unknown image data format %d",dataFormat); break; }
    }

    return dataFormatByteCount;
}

- (Int) calculatePixelFormatChannelCount:(NpState)pixelFormat
{
    Int pixelFormatChannelCount = 0;
    switch ( pixelFormat )
    {
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_R   :{ pixelFormatChannelCount = 1; break; }
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RG  :{ pixelFormatChannelCount = 2; break; }
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RGB :{ pixelFormatChannelCount = 3; break; }
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RGBA:{ pixelFormatChannelCount = 4; break; }
        default:{ NPLOG_ERROR(@"Unknown image pixel format %d",pixelFormat); break; }
    }

    return pixelFormatChannelCount;
}

- (Int) calculatePixelByteCountUsingDataFormat:(NpState)dataFormat pixelFormat:(NpState)pixelFormat
{
    Int dataFormatByteCount = [ self calculateDataFormatByteCount:dataFormat ];
    Int channelCount = [ self calculatePixelFormatChannelCount:pixelFormat ];

    return dataFormatByteCount * channelCount;
}

- (Int) calculateImageByteCount:(NPImage *)image
{
    return [ self calculateImageByteCountUsingWidth:[image width] height:[image height] pixelFormat:[image pixelFormat] dataFormat:[image dataFormat] ];
}

- (Int) calculateImageByteCountUsingWidth:(Int)width height:(Int)height pixelFormat:(NpState)pixelFormat dataFormat:(NpState)dataFormat
{
    Int dataFormatSize  = [ self calculateDataFormatByteCount:dataFormat ];
    Int pixelFormatSize = [ self calculatePixelFormatChannelCount:pixelFormat ];

    return width*height*dataFormatSize*pixelFormatSize;
}

- (Int) calculateDevilPixelFormat:(NpState)pixelFormat
{
    Int devilFormat = 0;

    switch ( pixelFormat )
    {
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_R   : { devilFormat = IL_LUMINANCE;       break; }
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RG  : { devilFormat = IL_LUMINANCE_ALPHA; break; }
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RGB : { devilFormat = IL_RGB;             break; }
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RGBA: { devilFormat = IL_RGBA;            break; }
        default: { NPLOG_ERROR(@"Unknown image pixel format"); break; }
    }

    return devilFormat;
}

- (Int) calculateDevilDataType:(NpState)dataFormat
{
    Int devilType = 0;

    switch ( dataFormat )
    {
        case NP_GRAPHICS_IMAGE_DATAFORMAT_BYTE : { devilType = IL_UNSIGNED_BYTE;  break; }
        case NP_GRAPHICS_IMAGE_DATAFORMAT_HALF : { devilType = IL_UNSIGNED_SHORT; break; }
        case NP_GRAPHICS_IMAGE_DATAFORMAT_FLOAT: { devilType = IL_FLOAT;          break; }
        default: { NPLOG_ERROR(@"Unknown image data format"); break; }
    }

    return devilType;
}

- (NPImage *) scaleImage:(NPImage *)sourceImage withFilter:(NpState)scalingFilter targetWidth:(Int)newWidth targetHeight:(Int)newHeight
{
	UInt image = [ sourceImage prepareForProcessingWithDevil ];

    if ( [ sourceImage setupDevilImageData ] == NO )
    {
        [ sourceImage endProcessingWithDevil:image ];

        return nil;
    }

    iluImageParameter(ILU_FILTER, scalingFilter);
    ILboolean success = iluScale(newWidth, newHeight, 1);
    if ( !success )
    {
        ILenum error = ilGetError();
        NPLOG_ERROR(( [ NSString stringWithCString:iluErrorString(error) encoding:NSASCIIStringEncoding ] ));
		NPLOG_ERROR(( [ @"Could not scale image: " stringByAppendingString:name ] ));
        [ sourceImage endProcessingWithDevil:image ];

		return nil;
    }

    UInt length = [self calculateImageByteCountUsingWidth:newWidth height:newHeight pixelFormat:[ sourceImage pixelFormat ] dataFormat:[ sourceImage dataFormat ] ];
    NSData * imageData = [[ NSData alloc ] initWithBytes:ilGetData() length:length ];

    [ sourceImage endProcessingWithDevil:image ];

    return [ NPImage imageWithName:@""
                             width:newWidth
                            height:newHeight
                       pixelFormat:[sourceImage pixelFormat] 
                        dataFormat:[sourceImage dataFormat] 
                        imageData:imageData ];
}

@end
