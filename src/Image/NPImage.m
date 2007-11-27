#import "NPImage.h"

#import <IL/il.h>
#import <IL/ilu.h>
#import <IL/ilut.h>

void npimage_initialise()
{
    ilInit();
    iluInit();
    ilutInit();
}

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
    mipMapLevels = 1;

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

- (Int) mipMapLevels
{
    return mipMapLevels;
}

- (BOOL) loadImageFromFile:(NSString *)fileName withMipMaps:(BOOL)generateMipMaps
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
                    NSLog(@"Unknown number of bytes per pixel");

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
                    NSLog(@"Unknown number of bytes per pixel");

                    return NO;
                }
			}

			break;
		}

	    default:
        {
            NSLog(@"Unknown image type");

            return NO;
        }
	}

    Int mipmapwidth = width;
    Int mipmapheight = height;

    if ( generateMipMaps )
    {
		iluImageParameter(ILU_FILTER, ILU_BILINEAR);

        mipMapLevels = 1;

        while ( mipmapwidth > 1 || mipmapheight > 1 )
        {
            mipmapheight /= 2;
            mipmapwidth /= 2;

            mipMapLevels++;
        }
    }
    else
    {
        mipMapLevels = 1;
    }

    mipmapwidth = width;
    mipmapheight = height;

    for ( Int i = 0; i < mipMapLevels; i++ )
    {
        UInt length = 0;

        if ( type == IL_UNSIGNED_BYTE )
        {
            length = mipmapwidth * mipmapheight * bytesperpixel * sizeof(Byte);
        }

        if ( type == IL_FLOAT )
        {
            length = mipmapwidth * mipmapheight * bytesperpixel * sizeof(Float);
        }

        NSData * tmp = [ [ NSData alloc ] initWithBytes:ilGetData() length:length ];

        [ imageData addObject:tmp ];
        [ tmp release ];

        mipmapwidth /= 2;
        mipmapheight /= 2;

        if ( i < mipMapLevels - 1 )
        {
            iluScale(mipmapwidth, mipmapheight, 1);
        }
    }

	ilDeleteImages(1, &image);

    return YES;
}

- (void) clear
{
    pixelFormat = NP_PIXELFORMAT_NONE;
    width = height = 0;
    mipMapLevels = 1;

    [ imageData removeAllObjects ];
}

- (NSString *) description
{
    return @"nix";
}


@end
