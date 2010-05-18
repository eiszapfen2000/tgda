#import "NPImage.h"
#import "NPImageManager.h"
#import "NP.h"

#import "IL/il.h"
#import "IL/ilu.h"

@implementation NPImage

+ (id) imageWithName:(NSString *)name 
               width:(Int)width 
              height:(Int)height
         pixelFormat:(NpState)pixelFormat
          dataFormat:(NpState)dataFormat 
{
    NPImage * image = [[ NPImage alloc ] initWithName:name ];
    [ image setWidth:width ];
    [ image setHeight:height ];
    [ image setPixelFormat:pixelFormat ];
    [ image setDataFormat:dataFormat ];

    return [ image autorelease ];
}

- (id) init
{
    return [ self initWithName:@"NP Image" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    dataFormat  = NP_NONE;
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

- (Int) pixelCount
{
    return width * height;
}

- (NpState) dataFormat
{
    return dataFormat;
}

- (NpState) pixelFormat
{
    return pixelFormat;
}

- (NSData *) imageData
{
    return imageData;
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

- (void) setImageData:(NSData *)newImageData
{
    ASSIGN(imageData,newImageData);
}

- (UInt) prepareForProcessingWithDevil
{
 	UInt image;
	ilGenImages(1, &image);
	ilBindImage(image);

    return image;
}

- (void) endProcessingWithDevil:(UInt)image
{
	ilDeleteImages(1, &image);
}

- (BOOL) setupDevilImageData
{
    if ( imageData == nil )
    {
        return NO;
    }

    Int devilFormat   = [[[ NP Graphics ] imageManager ] calculateDevilPixelFormat:pixelFormat ];
    Int devilType     = [[[ NP Graphics ] imageManager ] calculateDevilDataType:dataFormat ];
    Int bytesPerPixel = [[[ NP Graphics ] imageManager ] calculatePixelByteCountUsingDataFormat:dataFormat pixelFormat:pixelFormat ];

    ILboolean success = ilTexImage(width, height, 1, bytesPerPixel, devilFormat, devilType, (ILvoid *)[imageData bytes]);
    if ( !success )
    {
        ILenum error = ilGetError();
        NPLOG_ERROR(( [ NSString stringWithCString:iluErrorString(error) encoding:NSASCIIStringEncoding ] ));
		NPLOG_ERROR(( [ @"Could not process image: " stringByAppendingString:name ] ));

		return NO;
    }

    return YES;
}

- (BOOL) loadFromPath:(NSString *)path
{
    return [ self loadFromPath:path withMipMaps:NO ];
}

- (BOOL) loadFromPath:(NSString *)path withMipMaps:(BOOL)generateMipMaps
{
    [ self reset ];

    [ self setFileName:path ];
    [ self setName:path ];

    NSString * pathExtension = [ path pathExtension ];
    if ( [ pathExtension isEqual:@"" ] == YES )
    {
        return NO;
    }

    UInt image = [ self prepareForProcessingWithDevil ];

	ILboolean success = ilLoadImage( [ path cString ] );
    if ( !success )
    {
        ILenum error = ilGetError();
        NPLOG_ERROR(( [ NSString stringWithCString:iluErrorString(error) encoding:NSASCIIStringEncoding ] ));
		NPLOG_ERROR(( [ @"Could not load image: " stringByAppendingString:fileName ] ));
        [ self endProcessingWithDevil:image ];

		return NO;
    }

    // Get image information.
	width  = (Int)ilGetInteger(IL_IMAGE_WIDTH);
	height = (Int)ilGetInteger(IL_IMAGE_HEIGHT);

    BOOL flipImage = NO;

    // OpenGL needs the origin to be at the lower left
    Int origin = (Int)ilGetInteger(IL_IMAGE_ORIGIN);
    if ( origin == IL_ORIGIN_UPPER_LEFT )
    {
        flipImage = YES;
    }

	ILint type          = ilGetInteger(IL_IMAGE_TYPE);
	ILint format        = ilGetInteger(IL_IMAGE_FORMAT);
	ILint bytesperpixel = ilGetInteger(IL_IMAGE_BYTES_PER_PIXEL);

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
            dataFormat = NP_GRAPHICS_IMAGE_DATAFORMAT_BYTE;
			switch ( bytesperpixel )
			{
			    case 1: { pixelFormat = NP_GRAPHICS_IMAGE_PIXELFORMAT_R;    break; }
			    case 2: { pixelFormat = NP_GRAPHICS_IMAGE_PIXELFORMAT_RG;   break; }
			    case 4: { pixelFormat = NP_GRAPHICS_IMAGE_PIXELFORMAT_RGBA; break; }
			    default: { NPLOG_ERROR(@"Unknown number of bytes per pixel"); return NO; }
			}

			break;
		}
	    case IL_FLOAT:
		{
            dataFormat = NP_GRAPHICS_IMAGE_DATAFORMAT_FLOAT;
			switch (bytesperpixel)
			{
			    case 1: { pixelFormat = NP_GRAPHICS_IMAGE_PIXELFORMAT_R;    break; }
			    case 2: { pixelFormat = NP_GRAPHICS_IMAGE_PIXELFORMAT_RG;   break; }
			    case 3: { pixelFormat = NP_GRAPHICS_IMAGE_PIXELFORMAT_RGB;  break; }
			    case 4: { pixelFormat = NP_GRAPHICS_IMAGE_PIXELFORMAT_RGBA; break; }
			    default: { NPLOG_ERROR(@"Unknown number of bytes per pixel"); return NO; }
			}

			break;
		}

	    default: { NPLOG_ERROR(@"Unknown image type"); return NO; }
	}

    UInt length = 0;

    if ( type == IL_UNSIGNED_BYTE )
    {
        length = width * height * bytesperpixel;// * sizeof(Byte);
    }

    if ( type == IL_FLOAT )
    {
        length = width * height * bytesperpixel;// * sizeof(Float);
    }

    if ( flipImage == YES )
    {
        iluFlipImage();
    }

    imageData = [[ NSData alloc ] initWithBytes:ilGetData() length:length ];

	[ self endProcessingWithDevil:image ];

    ready = YES;

    return YES;
}

- (BOOL) saveToFile:(NPFile *)file
{
    UInt image = [ self prepareForProcessingWithDevil ];

    if (  [ self setupDevilImageData ] == NO )
    {
        [ self endProcessingWithDevil:image ];

        return NO;
    }

    ilEnable(IL_FILE_OVERWRITE);

    ILboolean success = ilSaveImage( [[ file fileName ] cString ] );
    if ( !success )
    {
        ILenum error = ilGetError();
        NPLOG_ERROR(( [ NSString stringWithCString:iluErrorString(error) encoding:NSASCIIStringEncoding ] ));
		NPLOG_ERROR(( [ @"Could not save image: " stringByAppendingString:fileName ] ));

		return NO;
    }

    ilDisable(IL_FILE_OVERWRITE);

    [ self endProcessingWithDevil:image ];

    return YES;
}

- (void) reset
{
    [ super reset ];

    dataFormat = NP_NONE;
    pixelFormat = NP_NONE;
    width = height = 0;

    DESTROY(imageData);
}

- (void) fillWithFloatValue:(Float)value
{
    if ( dataFormat != NP_GRAPHICS_IMAGE_DATAFORMAT_FLOAT )
    {
        NPLOG_ERROR(@"%@: image dataformat is not float", name);
        return;
    }

    Int channelCount = [[[ NP Graphics ] imageManager ] calculatePixelFormatChannelCount:pixelFormat ];
    Int elementCount = width * height * channelCount;

    Float * imageFloatData = ALLOC_ARRAY(Float, elementCount);

    for ( Int i = 0; i < elementCount; i++ )
    {
        imageFloatData[elementCount] = value;
    }

    imageData = [[ NSData alloc ] initWithBytesNoCopy:imageFloatData length:elementCount*4 freeWhenDone:YES ];   
}

- (void) fillWithHalfValue:(UInt16)value
{
    if ( dataFormat != NP_GRAPHICS_IMAGE_DATAFORMAT_HALF )
    {
        NPLOG_ERROR(@"%@: image dataformat is not half", name);
        return;
    } 

    if ( value != 0 )
    {
        NPLOG_ERROR(@"%@: no half support for filling", name);
    }

    Int channelCount = [[[ NP Graphics ] imageManager ] calculatePixelFormatChannelCount:pixelFormat ];
    Int elementCount = width * height * channelCount;

    UInt16 * imageHalfData = ALLOC_ARRAY(UInt16, elementCount);

    for ( Int i = 0; i < height; i++ )
    {
        for ( Int j = 0; j < width; j++ )
        {
            imageHalfData[i * width + j] = value;
        }
    }

    imageData = [[ NSData alloc ] initWithBytesNoCopy:imageHalfData length:elementCount*2 freeWhenDone:YES ];    
}

- (void) fillWithByteValue:(Byte)value
{
    if ( dataFormat != NP_GRAPHICS_IMAGE_DATAFORMAT_BYTE )
    {
        NPLOG_ERROR(@"%@: image dataformat is not byte", name);
        return;
    } 

    Int channelCount = [[[ NP Graphics ] imageManager ] calculatePixelFormatChannelCount:pixelFormat ];
    Int elementCount = width * height * channelCount;

    Byte * imageByteData = ALLOC_ARRAY(Byte, elementCount);

    for ( Int i = 0; i < height; i++ )
    {
        for ( Int j = 0; j < width; j++ )
        {
            imageByteData[i * width + j] = value;
        }
    }

    imageData = [[ NSData alloc ] initWithBytesNoCopy:imageByteData length:elementCount freeWhenDone:YES ];
}

@end
