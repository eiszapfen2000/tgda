#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import "IL/il.h"
#import "IL/ilu.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/NPEngineGraphicsErrors.h"
#import "NPImage.h"

NpImageDataFormat convert_devil_dataformat(ILint devilDataFormat)
{
    NpImageDataFormat result = NpImageDataFormatUnknown;

    switch ( devilDataFormat )
    {
        case IL_UNSIGNED_BYTE:
            result = NpImageDataFormatByte;
            break;
        case IL_HALF:
            result = NpImageDataFormatHalf;
            break;
        case IL_FLOAT:
            result = NpImageDataFormatFloat;
            break;
        default:
            break;
    }

    return result;
}

NpImagePixelFormat convert_devil_pixelformat(ILint devilPixelFormat, BOOL sRGB)
{
    NpImagePixelFormat result = NpImagePixelFormatUnknown;

    switch ( devilPixelFormat )
    {
        case IL_LUMINANCE:
            if ( sRGB == YES )
            {
                result = NpImagePixelFormatsR;
            }
            else
            {
                result = NpImagePixelFormatR;
            }
            break;

        case IL_LUMINANCE_ALPHA:
            if ( sRGB == YES )
            {
                result = NpImagePixelFormatsRG;
            }
            else
            {
                result = NpImagePixelFormatRG;
            }
            break;

        case IL_RGBA:
            if ( sRGB == YES )
            {
                result = NpImagePixelFormatsRGBLinearA;
            }
            else
            {
                result = NpImagePixelFormatRGBA;
            }
            break;

        default:
            break;
    }

    return result;
}

@implementation NPImage

- (id) init
{
    return [ self initWithName:@"Image" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    pixelFormat = NpImagePixelFormatUnknown;
    dataFormat = NpImageDataFormatUnknown;
    width = height = 0;
    imageData = nil;

    return self;
}

- (void) dealloc
{
    if ( imageData != nil )
    {
        DESTROY(imageData);
    }

    [ super dealloc ];
}

- (uint32_t) width
{
    return width;
}

- (uint32_t) height
{
    return height;
}

- (NpImageDataFormat) dataFormat
{
    return dataFormat;
}

- (NpImagePixelFormat) pixelFormat
{
    return pixelFormat;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
                 sRGB:(BOOL)sRGB
                error:(NSError **)error
{
    [ self setName:fileName ];

    ILuint ilID;
    ilGenImages(1, &ilID);
    ilBindImage(ilID);

    ilOriginFunc(IL_ORIGIN_LOWER_LEFT );
    ilEnable(IL_ORIGIN_SET);

 	ILboolean success = ilLoadImage( [ fileName cStringUsingEncoding:NSASCIIStringEncoding ] );
    if ( success == IL_FALSE )
    {
        if ( error != NULL )
        {
            ILenum ilError = ilGetError();
            NSString * errorString =
                [ NSString stringWithUTF8String:iluErrorString(ilError) ];

            *error = [ NSError errorWithCode:NPEngineGraphicsDevILError
                                 description:errorString ];
        }

        ilBindImage(0);
    	ilDeleteImages(1, &ilID);

        return NO;
    }

    ILint imageWidth = ilGetInteger(IL_IMAGE_WIDTH);
    ILint imageHeight = ilGetInteger(IL_IMAGE_HEIGHT); 

    if ( imageWidth <= 0 || imageHeight <= 0 )
    {
        if ( error != NULL )
        {
            NSString * errorString = [ NSString stringWithFormat:@"%d x %d", imageWidth, imageHeight ];
            *error = [ NSError errorWithCode:NPEngineGraphicsImageHasInvalidSize
                                 description:errorString ];

        }

        return NO;
    }

	ILint type          = ilGetInteger(IL_IMAGE_TYPE);
	ILint format        = ilGetInteger(IL_IMAGE_FORMAT);
	ILint bytesperpixel = ilGetInteger(IL_IMAGE_BYTES_PER_PIXEL);

	// Convert RGB, BGR, or BGRA images to RGBA.
	if ((type == IL_UNSIGNED_BYTE || type == IL_BYTE )
         && ((bytesperpixel == 3) || (format == IL_BGRA)))
	{
		ilConvertImage(IL_RGBA, IL_UNSIGNED_BYTE);
		format = IL_RGBA;
		bytesperpixel = 4;
	}

    dataFormat = convert_devil_dataformat(type);
    pixelFormat = convert_devil_pixelformat(format, sRGB);

    if ( dataFormat == NpImageDataFormatUnknown
         || pixelFormat == NpImagePixelFormatUnknown )
    {
        if ( error != NULL )
        {
            NSString * errorString =
                [ NSString stringWithFormat:@"Data Format:%d Pixel Format:%d",
                     (int32_t)dataFormat, (int32_t)pixelFormat ];

            *error = [ NSError errorWithCode:NPEngineGraphicsImageHasInvalidSize
                                 description:errorString ];

        }

        return NO;
    }

    NSUInteger dataLength = width * height * bytesperpixel;
    imageData = [[ NSData alloc ] initWithBytes:ilGetData() length:dataLength ];
    ilBindImage(0);
	ilDeleteImages(1, &ilID);    

    return YES;
}

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
{
    return [ self loadFromFile:fileName sRGB:NO error:error ];
}

@end

