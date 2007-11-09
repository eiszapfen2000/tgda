#import "NPImage.h"

#import <IL/il.h>
#import <IL/ilu.h>
#import <IL/ilut.h>

@implementation NPImage

- (id) init
{
    return [ self initWithName: @"NPImage" ];
}

- (id) initWithName: (NSString *) newName
{
    self = [ super initWithName: newName ];

    pixelFormat = NP_PIXELFORMAT_NONE;
    width = height = 0;

    imageData = [ [ NSMutableArray alloc ] init ];

    return self;
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

- (void)loadImageFromFile:(NSString *)fileName withMipMaps:(BOOL)generateMipMaps
{
    [ self clear ];

    [ self setName: fileName ];

	ILuint image;
	ilGenImages(1, &image);
	ilBindImage(image);
	ILboolean success = ilLoadImage( [ fileName cString ] );

    if ( !success )
    {
        ILenum error = ilGetError();
        NSLog( [ NSString stringWithCString:iluErrorString(error) encoding:NSUTF8StringEncoding ] );
		NSLog( [ @"Could not load image: " stringByAppendingString: fileName ] );

		return;
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
                    NSLog(@"Unknown number of bytes per pixel");

                    return;
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
                    NSLog(@"Unknown number of bytes per pixel");

                    return;
                }
			}
			break;
		}

	    default:
        {
            NSLog(@"Unknown image type");

            return;
        }
	}
}

- (void) clear
{
    pixelFormat = NP_PIXELFORMAT_NONE;
    width = height = 0;

    [ imageData removeAllObjects ];
}


@end
