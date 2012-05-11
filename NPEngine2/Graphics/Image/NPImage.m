#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import "IL/il.h"
#import "IL/ilu.h"
#import "Log/NPLog.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "Graphics/NPEngineGraphicsErrors.h"
#import "Graphics/NPEngineGraphics.h"
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
            result = NpImageDataFormatFloat16;
            break;
        case IL_FLOAT:
            result = NpImageDataFormatFloat32;
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
            result = NpImagePixelFormatR;
            break;

        case IL_LUMINANCE_ALPHA:
            result = NpImagePixelFormatRG;
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
    self = [ super initWithName:newName ];
    [[[ NPEngineGraphics instance ] images ] registerAsset:self ];

    file = nil;
    ready = NO;

    pixelFormat = NpImagePixelFormatUnknown;
    dataFormat = NpImageDataFormatUnknown;
    width = height = 0;
    imageData = nil;

    return self;
}

- (void) dealloc
{
    [ self clear ];
    [[[ NPEngineGraphics instance ] images ] unregisterAsset:self ];

    [ super dealloc ];
}

- (void) clear
{
    SAFE_DESTROY(file);
    SAFE_DESTROY(imageData);
    ready = NO;

    pixelFormat = NpImagePixelFormatUnknown;
    dataFormat = NpImageDataFormatUnknown;
    width = height = 0;
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return ready;
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

- (NSData *) imageData
{
    return imageData;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    [ self clear ];

    NSString * completeFileName
        = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    if ( completeFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    [ self setName:completeFileName ];
    ASSIGNCOPY(file, completeFileName);

    NPLOG(@"Loading image \"%@\"", completeFileName);

    ILuint ilID;
    ilGenImages(1, &ilID);
    ilBindImage(ilID);

    ilOriginFunc(IL_ORIGIN_LOWER_LEFT);
    ilEnable(IL_ORIGIN_SET);

 	ILboolean success = 
        ilLoadImage( [ completeFileName cStringUsingEncoding:NSASCIIStringEncoding ] );

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
            NSString * errorString
                = [ NSString stringWithFormat:@"%d x %d", imageWidth, imageHeight ];

            *error = [ NSError errorWithCode:NPEngineGraphicsImageHasInvalidSize
                                 description:errorString ];

        }

        ilBindImage(0);
    	ilDeleteImages(1, &ilID);

        return NO;
    }

    width  = (uint32_t)imageWidth;
    height = (uint32_t)imageHeight;

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

    // get arguments
    BOOL sRGB = NO;
    
    if ( arguments != nil )
    {
        NSString * sRGBString = [ arguments objectForKey:@"sRGB" ];
        if ( sRGBString != nil )
        {
            sRGB = [ sRGBString boolValue ];
        }
    }

    dataFormat  = convert_devil_dataformat(type);
    pixelFormat = convert_devil_pixelformat(format, sRGB);

    if ( dataFormat == NpImageDataFormatUnknown
         || pixelFormat == NpImagePixelFormatUnknown )
    {
        if ( error != NULL )
        {
            NSString * errorString =
                [ NSString stringWithFormat:@"Data Format:%d Pixel Format:%d",
                     (int32_t)dataFormat, (int32_t)pixelFormat ];

            *error = [ NSError errorWithCode:NPEngineGraphicsImageHasUnknownFormat
                                 description:errorString ];

        }

        ilBindImage(0);
    	ilDeleteImages(1, &ilID);

        return NO;
    }

    NSUInteger dataLength = width * height * bytesperpixel;
    imageData = [[ NSData alloc ] initWithBytes:ilGetData() length:dataLength ];
    ilBindImage(0);
	ilDeleteImages(1, &ilID);

    ready = YES;

    return YES;
}

@end

