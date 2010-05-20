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
    return [ self loadImageFromPath:path sRGB:NO ];
}

- (id) loadImageFromPath:(NSString *)path sRGB:(BOOL)sRGB
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadImageFromAbsolutePath:absolutePath sRGB:sRGB];
}

- (id) loadImageFromAbsolutePath:(NSString *)path
{
    return [ self loadImageFromAbsolutePath:path sRGB:NO ];
}

- (id) loadImageFromAbsolutePath:(NSString *)path sRGB:(BOOL)sRGB
{
    if ( [ path isEqual:@"" ] == NO )
    {
        NPImage * image = [ images objectForKey:path ];

        if ( image == nil )
        {
            NPLOG(@"%@: loading %@", name, path);

            NPImage * image = [[ NPImage alloc ] initWithName:@"" parent:self ];

            if ( [ image loadFromPath:path sRGB:sRGB ] == YES )
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
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_R  :
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_sR :
        {
            pixelFormatChannelCount = 1;
            break;
        }

        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RG  :
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_sRG :
        {
            pixelFormatChannelCount = 2;
            break;
        }

        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RGB  :
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_sRGB :
        {
            pixelFormatChannelCount = 3;
            break;
        }

        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RGBA:
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_sRGB_LINEAR_ALPHA:
        {
            pixelFormatChannelCount = 4;
            break;
        }

        default:{ NPLOG_ERROR(@"Unknown image pixel format %d", pixelFormat); break; }
    }

    return pixelFormatChannelCount;
}

- (Int) calculatePixelByteCountUsingDataFormat:(NpState)dataFormat
                                   pixelFormat:(NpState)pixelFormat
{
    Int dataFormatByteCount     = [ self calculateDataFormatByteCount:dataFormat ];
    Int pixelFormatchannelCount = [ self calculatePixelFormatChannelCount:pixelFormat ];

    return dataFormatByteCount * pixelFormatchannelCount;
}

- (Int) calculateImageByteCount:(NPImage *)image
{
    return [ self calculateImageByteCountUsingWidth:[image width]
                                             height:[image height]
                                        pixelFormat:[image pixelFormat]
                                         dataFormat:[image dataFormat] ];
}

- (Int) calculateImageByteCountUsingWidth:(Int)width
                                   height:(Int)height
                              pixelFormat:(NpState)pixelFormat
                               dataFormat:(NpState)dataFormat
{
    Int dataFormatSize  = [ self calculateDataFormatByteCount:dataFormat ];
    Int pixelFormatSize = [ self calculatePixelFormatChannelCount:pixelFormat ];

    return width * height * dataFormatSize * pixelFormatSize;
}

- (Int) calculateDevilPixelFormat:(NpState)pixelFormat
{
    Int devilFormat = 0;

    switch ( pixelFormat )
    {
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_R  :
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_sR :
        {
            devilFormat = IL_LUMINANCE;
            break;
        }

        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RG  :
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_sRG :
        {
            devilFormat = IL_LUMINANCE_ALPHA;
            break;
        }

        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RGB  :
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_sRGB :
        {
            devilFormat = IL_RGB;
            break;
        }

        case NP_GRAPHICS_IMAGE_PIXELFORMAT_RGBA:
        case NP_GRAPHICS_IMAGE_PIXELFORMAT_sRGB_LINEAR_ALPHA:
        {
            devilFormat = IL_RGBA;
            break;
        }

        default: { NPLOG_ERROR(@"Unknown image pixel format %d", pixelFormat); break; }
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

@end
