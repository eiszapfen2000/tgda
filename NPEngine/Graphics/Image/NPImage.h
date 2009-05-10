#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"

@class NPFile;

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
                    ;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) reset;

- (NpState) dataFormat;
- (NpState) pixelFormat;
- (Int) width;
- (Int) height;
- (Int) pixelCount;
- (NSData *) imageData;

- (void) setPixelFormat:(NpState)newPixelFormat;
- (void) setDataFormat:(NpState)newDataFormat;
- (void) setWidth:(Int)newWidth;
- (void) setHeight:(Int)newHeight;
- (void) setImageData:(NSData *)newImageData;

- (UInt) prepareForProcessingWithDevil;
- (void) endProcessingWithDevil:(UInt)image;
- (BOOL) setupDevilImageData;

- (BOOL) loadFromPath:(NSString *)path;
- (BOOL) loadFromPath:(NSString *)path withMipMaps:(BOOL)generateMipMaps;

- (BOOL) saveToFile:(NPFile *)file;

- (void) fillWithFloatValue:(Float)value;
- (void) fillWithHalfValue:(UInt16)value;
- (void) fillWithByteValue:(Byte)value;


@end
