#import "NPImage.h"
#import "Core/NPEngineCore.h"

#import "IL/il.h"
#import "IL/ilu.h"

@implementation NPImage

- (id) init
{
    return [ self initWithName:@"NP Image" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    dataFormat = NP_NONE;
    pixelFormat = NP_NONE;
    width = height = 0;

    imageData = nil;

    return self;
}

- (void) dealloc
{
    [ imageData release ];

    [ super dealloc ];
}

- (Int) width
{
    return width;
}

- (Int) height
{
    return height;
}

- (NPState) dataFormat
{
    return dataFormat;
}

- (NPState) pixelFormat
{
    return pixelFormat;
}

- (void) setImageData:(NSData *)newImageData
{
    if ( imageData != newImageData )
    {
        TEST_RELEASE(imageData);
        imageData = [ newImageData retain ];
    }
}

- (NSData *) imageData
{
    return imageData;
}

- (BOOL) loadFromFile:(NPFile *)file
{
    return [ self loadFromFile:file withMipMaps:NO ];
}

- (BOOL) loadFromFile:(NPFile *)file withMipMaps:(BOOL)generateMipMaps
{
    [ self reset ];

    [ self setFileName:[ file fileName ] ];
    [ self setName:fileName ];

	ILuint image;
	ilGenImages(1, &image);
	ilBindImage(image);

	ILboolean success = ilLoadImage( [ fileName cString ] );

    if ( !success )
    {
        ILenum error = ilGetError();
        NPLOG_ERROR(( [ NSString stringWithCString:iluErrorString(error) encoding:NSASCIIStringEncoding ] ));
		NPLOG_ERROR(( [ @"Could not load image: " stringByAppendingString: fileName ] ));

		return NO;
    }

	// Get image information.
	width = (Int)ilGetInteger(IL_IMAGE_WIDTH);
	height = (Int)ilGetInteger(IL_IMAGE_HEIGHT);

	ILint type = ilGetInteger(IL_IMAGE_TYPE);
	ILint bytesperpixel = ilGetInteger(IL_IMAGE_BYTES_PER_PIXEL);
	ILint format = ilGetInteger(IL_IMAGE_FORMAT);

	// Convert RGB, BGR, or BGRA images to RGBA.
	if ((type == IL_UNSIGNED_BYTE) && ((bytesperpixel == 3) || (format == IL_BGRA)))
	{
		ilConvertImage(IL_RGBA, IL_UNSIGNED_BYTE);
		format = IL_RGBA;
		bytesperpixel = 4;
	}

	switch (type)
	{
	    case IL_UNSIGNED_BYTE:
		{
            dataFormat = NP_IMAGE_DATAFORMAT_BYTE;
			switch (bytesperpixel)
			{
			    case 1:
                {
                    pixelFormat = NP_IMAGE_PIXELFORMAT_R;
                    break;
                }
			    case 2:
                {
                    pixelFormat = NP_IMAGE_PIXELFORMAT_RG;
                    break;
                }
			    case 4:
                {
                    pixelFormat = NP_IMAGE_PIXELFORMAT_RGBA;
                    break;
                }
			    default:
                {
                    NPLOG_ERROR(@"Unknown number of bytes per pixel");

                    return NO;
                }
			}

			break;
		}
	    case IL_FLOAT:
		{
            dataFormat = NP_IMAGE_DATAFORMAT_FLOAT;
			switch (bytesperpixel)
			{
			    case 1:
                {
                    pixelFormat = NP_IMAGE_PIXELFORMAT_R;
                    break;
                }
			    case 2:
                {
                    pixelFormat = NP_IMAGE_PIXELFORMAT_RG;
                    break;
                }
			    case 3:
                {
                    pixelFormat = NP_IMAGE_PIXELFORMAT_RGB;
                    break;
                }
			    case 4:
                {
                    pixelFormat = NP_IMAGE_PIXELFORMAT_RGBA;
                    break;
                }
			    default:
                {
                    NPLOG_ERROR(@"Unknown number of bytes per pixel");

                    return NO;
                }
			}

			break;
		}

	    default:
        {
            NPLOG_ERROR(@"Unknown image type");

            return NO;
        }
	}

    UInt length = 0;

    if ( type == IL_UNSIGNED_BYTE )
    {
        length = width * height * bytesperpixel * sizeof(Byte);
    }

    if ( type == IL_FLOAT )
    {
        length = width * height * bytesperpixel * sizeof(Float);
    }

    imageData = [ [ NSData alloc ] initWithBytes:ilGetData() length:length ];

	ilDeleteImages(1, &image);

    ready = YES;

    return YES;
}

- (void) reset
{
    [ super reset ];

    dataFormat = NP_NONE;
    pixelFormat = NP_NONE;
    width = height = 0;

    [ imageData release ];
}

@end
