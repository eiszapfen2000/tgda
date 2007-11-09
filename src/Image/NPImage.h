#import "Core/NPObject.h"
#import "NPPixelFormat.h"

@interface NPImage : NPObject
{
    NPPixelFormat pixelFormat;
    Int width;
    Int height;
    
    NSMutableArray * imageData;
}

- (id) init;
- (id) initWithName: (NSString *) newName;

- (Int) width;
- (Int) height;
- (NPPixelFormat) pixelFormat;

- (void)loadImageFromFile:(NSString *)fileName withMipMaps:(BOOL)generateMipMaps;

- (void) clear;

@end
