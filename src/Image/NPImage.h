#import "Core/NPObject.h"
#import "NPPixelFormat.h"

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
- (id) initWithName: (NSString *) newName;

- (Int) width;
- (Int) height;
- (NPPixelFormat) pixelFormat;
- (Int) mipMapLevels;

- (BOOL) loadImageFromFile:(NSString *)fileName withMipMaps:(BOOL)generateMipMaps;

- (void) clear;

- (NSString *) description;

@end
