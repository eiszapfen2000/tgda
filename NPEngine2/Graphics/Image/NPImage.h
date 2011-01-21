#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "Core/File/NPPPersistentObject.h"

typedef enum NpImagePixelFormat
{
    NpImagePixelFormatUnknown = -1,
    NpImagePixelFormatR = 0,
    NpImagePixelFormatRG = 1,
    NpImagePixelFormatRGB = 2,
    NpImagePixelFormatRGBA = 3,
    NpImagePixelFormatsR = 4,
    NpImagePixelFormatsRG = 5,
    NpImagePixelFormatsRGB = 6,
    NpImagePixelFormatsRGBLinearA = 7    
}
NpImagePixelFormat;

typedef enum NpImageDataFormat
{
    NpImageDataFormatUnknown = -1,
    NpImageDataFormatByte = 0,
    NpImageDataFormatHalf = 1,
    NpImageDataFormatFloat = 2
}
NpImageDataFormat;

@class NSData;

@interface NPImage : NPObject < NPPPersistentObject >
{
    NpImageDataFormat dataFormat;
    NpImagePixelFormat pixelFormat;

    uint32_t width;
    uint32_t height;

    NSData * imageData;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (uint32_t) width;
- (uint32_t) height;
- (NpImagePixelFormat) pixelFormat;
- (NpImageDataFormat) dataFormat;

- (BOOL) loadFromFile:(NSString *)fileName
                 sRGB:(BOOL)sRGB
                error:(NSError **)error
                     ;

@end
