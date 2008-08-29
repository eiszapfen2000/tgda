#import "NPImage.h"
#import "Core/NPEngineCore.h"

#import "IL/il.h"
#import "IL/ilu.h"

Int dataFormatByteCount(NPState dataFormat)
{
    Int dataFormatByteCount = 0;
    switch ( dataFormat )
    {
        case NP_IMAGE_DATAFORMAT_BYTE:{dataFormatByteCount = 1; break;}
        case NP_IMAGE_DATAFORMAT_HALF:{dataFormatByteCount = 2; break;}
        case NP_IMAGE_DATAFORMAT_FLOAT:{dataFormatByteCount = 4; break;}
    }

    return dataFormatByteCount;
}

Int pixelFormatChannelCount(NPState pixelFormat)
{
    Int pixelFormatChannelCount = 0;
    switch ( pixelFormat )
    {
        case NP_IMAGE_PIXELFORMAT_R:{pixelFormatChannelCount = 1; break;}
        case NP_IMAGE_PIXELFORMAT_RG:{pixelFormatChannelCount = 2; break;}
        case NP_IMAGE_PIXELFORMAT_RGB:{pixelFormatChannelCount = 3; break;}
        case NP_IMAGE_PIXELFORMAT_RGBA:{pixelFormatChannelCount = 4; break;}
    }

    return pixelFormatChannelCount;
}

Int calculateImageByteCount(Int width, Int height, NPState pixelFormat, NPState dataFormat)
{
    Int dataFormatSize = dataFormatByteCount(dataFormat);
    Int pixelFormatSize = pixelFormatChannelCount(pixelFormat);

    return width*height*dataFormatSize*pixelFormatSize;
}

Int pixelFormatToDevilFormat(NPState pixelFormat)
{
    Int devilFormat = 0;

    switch ( pixelFormat )
    {
        case NP_IMAGE_PIXELFORMAT_R: { devilFormat = IL_LUMINANCE; break; }
        case NP_IMAGE_PIXELFORMAT_RG: { devilFormat = IL_LUMINANCE_ALPHA; break; }
        case NP_IMAGE_PIXELFORMAT_RGB: { devilFormat = IL_RGB; break; }
        case NP_IMAGE_PIXELFORMAT_RGBA: { devilFormat = IL_RGBA; break; }
    }

    return devilFormat;
}

Int dataFormatToDevilType(NPState dataFormat)
{
    Int devilType = 0;

    switch ( dataFormat )
    {
        case NP_IMAGE_DATAFORMAT_BYTE: { devilType = IL_UNSIGNED_BYTE; break; }
        case NP_IMAGE_DATAFORMAT_HALF: { devilType = IL_UNSIGNED_SHORT; break; }
        case NP_IMAGE_DATAFORMAT_FLOAT: { devilType = IL_FLOAT; break; }
    }

    return devilType;
}


@implementation NPImage

+ (id) imageWithName:(NSString *)name 
               width:(Int)width 
              height:(Int)height
         pixelFormat:(NPState)pixelFormat
          dataFormat:(NPState)dataFormat 
           imageData:(NSData *)imageData
{
    NPImage * image = [[ NPImage alloc ] initWithName:name ];
    [ image setWidth:width ];
    [ image setHeight:height ];
    [ image setPixelFormat:pixelFormat ];
    [ image setDataFormat:dataFormat ];
    [ image setImageData:imageData ];

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

- (void) setWidth:(Int)newWidth
{
    width = newWidth;
}

- (Int) height
{
    return height;
}

- (void) setHeight:(Int)newHeight
{
    height = newHeight;
}

- (NPState) dataFormat
{
    return dataFormat;
}

- (void) setDataFormat:(NPState)newDataFormat
{
    dataFormat = newDataFormat;
}

- (NPState) pixelFormat
{
    return pixelFormat;
}

- (void) setPixelFormat:(NPState)newPixelFormat
{
    pixelFormat = newPixelFormat;
}

- (NSData *) imageData
{
    return imageData;
}

- (void) setImageData:(NSData *)newImageData
{
    Int bytesCount = calculateImageByteCount(width, height, pixelFormat, dataFormat);

    if ( bytesCount != (Int)[newImageData length ] )
    {
        NPLOG_ERROR(@"NPImage setImageData: wrong dataSize");
        return;
    }

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

    Int devilFormat = pixelFormatToDevilFormat(pixelFormat);
    Int devilType = dataFormatToDevilType(dataFormat);
    Int bpp = dataFormatByteCount(dataFormat) * pixelFormatChannelCount(pixelFormat);
    ILboolean success = ilTexImage(width, height, 1, bpp, devilFormat, devilType, (ILvoid *)[imageData bytes]);

    if ( !success )
    {
        ILenum error = ilGetError();
        NPLOG_ERROR(( [ NSString stringWithCString:iluErrorString(error) encoding:NSASCIIStringEncoding ] ));
		NPLOG_ERROR(( [ @"Could not process image: " stringByAppendingString:name ] ));

		return NO;
    }

    return YES;
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

    UInt image = [ self prepareForProcessingWithDevil ];

	ILboolean success = ilLoadImage( [ fileName cString ] );
    if ( !success )
    {
        ILenum error = ilGetError();
        NPLOG_ERROR(( [ NSString stringWithCString:iluErrorString(error) encoding:NSASCIIStringEncoding ] ));
		NPLOG_ERROR(( [ @"Could not load image: " stringByAppendingString:fileName ] ));
        [ self endProcessingWithDevil:image ];

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
			    case 1: { pixelFormat = NP_IMAGE_PIXELFORMAT_R; break; }
			    case 2: { pixelFormat = NP_IMAGE_PIXELFORMAT_RG; break; }
			    case 4: { pixelFormat = NP_IMAGE_PIXELFORMAT_RGBA; break; }
			    default: { NPLOG_ERROR(@"Unknown number of bytes per pixel"); return NO; }
			}

			break;
		}
	    case IL_FLOAT:
		{
            dataFormat = NP_IMAGE_DATAFORMAT_FLOAT;
			switch (bytesperpixel)
			{
			    case 1: { pixelFormat = NP_IMAGE_PIXELFORMAT_R; break; }
			    case 2: { pixelFormat = NP_IMAGE_PIXELFORMAT_RG; break; }
			    case 3: { pixelFormat = NP_IMAGE_PIXELFORMAT_RGB; break; }
			    case 4: { pixelFormat = NP_IMAGE_PIXELFORMAT_RGBA; break; }
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

@end
