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

    pixelFormat = NP_PIXELFORMAT_NONE;
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

- (NPPixelFormat) pixelFormat
{
    return pixelFormat;
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
        NPLOG(( [ NSString stringWithCString:iluErrorString(error) encoding:NSASCIIStringEncoding ] ));
		NPLOG(( [ @"Could not load image: " stringByAppendingString: fileName ] ));

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
			switch (bytesperpixel)
			{
			    case 1:
                {
                    pixelFormat = NP_PIXELFORMAT_BYTE_R;
                    break;
                }
			    case 2:
                {
                    pixelFormat = NP_PIXELFORMAT_BYTE_RG;
                    break;
                }
			    case 4:
                {
                    pixelFormat = NP_PIXELFORMAT_BYTE_RGBA;
                    break;
                }
			    default:
                {
                    NPLOG(@"Unknown number of bytes per pixel");

                    return NO;
                }
			}

			break;
		}
	    case IL_FLOAT:
		{
			switch (bytesperpixel)
			{
			    case 1:
                {
                    pixelFormat = NP_PIXELFORMAT_FLOAT32_R;
                    break;
                }
			    case 2:
                {
                    pixelFormat = NP_PIXELFORMAT_FLOAT32_RG;
                    break;
                }
			    case 3:
                {
                    pixelFormat = NP_PIXELFORMAT_FLOAT32_RGB;
                    break;
                }
			    case 4:
                {
                    pixelFormat = NP_PIXELFORMAT_FLOAT32_RGBA;
                    break;
                }
			    default:
                {
                    NPLOG(@"Unknown number of bytes per pixel");

                    return NO;
                }
			}

			break;
		}

	    default:
        {
            NPLOG(@"Unknown image type");

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

    pixelFormat = NP_PIXELFORMAT_NONE;
    width = height = 0;

    [ imageData release ];
}

- (BOOL) isReady
{
    return ready;
}

@end
