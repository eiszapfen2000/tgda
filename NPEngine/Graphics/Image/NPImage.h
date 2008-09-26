#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;

#define    NP_IMAGE_DATAFORMAT_BYTE     0
#define    NP_IMAGE_DATAFORMAT_HALF     1
#define    NP_IMAGE_DATAFORMAT_FLOAT    2

#define    NP_IMAGE_PIXELFORMAT_R       0
#define    NP_IMAGE_PIXELFORMAT_RG      1
#define    NP_IMAGE_PIXELFORMAT_RGB     2
#define    NP_IMAGE_PIXELFORMAT_RGBA    3

@interface NPImage : NPResource
{
    NpState dataFormat;
    NpState pixelFormat;

    Int width;
    Int height;
    
    NSData * imageData;
}

+ (id) imageWithName:(NSString *)name 
               width:(Int)width 
              height:(Int)height
         pixelFormat:(NpState)pixelFormat
          dataFormat:(NpState)dataFormat 
           imageData:(NSData *)imageData;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NpState) dataFormat;
- (void) setDataFormat:(NpState)newDataFormat;
- (NpState) pixelFormat;
- (void) setPixelFormat:(NpState)newPixelFormat;
- (Int) width;
- (void) setWidth:(Int)newWidth;
- (Int) height;
- (void) setHeight:(Int)newHeight;
- (NSData *) imageData;
- (void) setImageData:(NSData *)newImageData;

- (UInt) prepareForProcessingWithDevil;
- (void) endProcessingWithDevil:(UInt)image;
- (BOOL) setupDevilImageData;

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) loadFromFile:(NPFile *)file withMipMaps:(BOOL)generateMipMaps;
- (BOOL) saveToFile:(NPFile *)file;
- (void) reset;

@end
