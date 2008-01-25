#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"
#import "Core/Resource/NPResource.h"
#import "NPImagePixelFormat.h"

void npimage_initialise();

@interface NPImage : NPResource < NPPResource >
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

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) loadFromFile:(NPFile *)file withMipMaps:(BOOL)generateMipMaps;
- (void) reset;
- (BOOL) isReady;

@end
