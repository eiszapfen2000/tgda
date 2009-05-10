#import "Core/NPObject/NPObject.h"

@class NPFile;
@class NPImage;

#define NP_IMAGE_FILTER_NEAREST     ILU_NEAREST
#define NP_IMAGE_FILTER_LINEAR      ILU_LINEAR
#define NP_IMAGE_FILTER_BILINEAR    ILU_BILINEAR
#define NP_IMAGE_FILTER_BOX         ILU_SCALE_BOX
#define NP_IMAGE_FILTER_TRIANGLE    ILU_SCALE_TRIANGLE

@interface NPImageManager : NPObject
{
    NSMutableDictionary * images;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (id) loadImageFromPath:(NSString *)path;
- (id) loadImageFromAbsolutePath:(NSString *)path;

- (Int) calculateDataFormatByteCount:(NpState)dataFormat;
- (Int) calculatePixelFormatChannelCount:(NpState)pixelFormat;
- (Int) calculatePixelByteCountUsingDataFormat:(NpState)dataFormat pixelFormat:(NpState)pixelFormat;
- (Int) calculateImageByteCount:(NPImage *)image;
- (Int) calculateImageByteCountUsingWidth:(Int)width height:(Int)height pixelFormat:(NpState)pixelFormat dataFormat:(NpState)dataFormat;
- (Int) calculateDevilPixelFormat:(NpState)pixelFormat;
- (Int) calculateDevilDataType:(NpState)dataFormat;

//- (NPImage *) scaleImage:(NPImage *)sourceImage withFilter:(NpState)scalingFilter targetWidth:(Int)newWidth targetHeight:(Int)newHeight;


@end
