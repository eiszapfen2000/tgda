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
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

- (id) loadImageFromPath:(NSString *)path;
- (id) loadImageFromAbsolutePath:(NSString *)path;
- (id) loadImageUsingFileHandle:(NPFile *)file;

- (NPImage *) scaleImage:(NPImage *)sourceImage withFilter:(NPState)scalingFilter targetWidth:(Int)newWidth targetHeight:(Int)newHeight;


@end
