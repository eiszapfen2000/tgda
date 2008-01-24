#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"
#import "NPImagePixelFormat.h"

void npimage_initialise();

@interface NPImage : NPObject
{
    NPPixelFormat pixelFormat;
    Int width;
    Int height;
    Int mipMapLevels;
    
    NSMutableArray * imageData;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (Int) width;
- (Int) height;
- (NPPixelFormat) pixelFormat;
- (Int) mipMapLevels;

- (BOOL) loadImageFromFile:(NPFile *)file withMipMaps:(BOOL)generateMipMaps;

- (void) clear;

@end
