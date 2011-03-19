#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NSData;

@interface NPImage : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    NpImageDataFormat dataFormat;
    NpImagePixelFormat pixelFormat;
    uint32_t width;
    uint32_t height;
    NSData * imageData;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) clear;

- (uint32_t) width;
- (uint32_t) height;
- (NpImagePixelFormat) pixelFormat;
- (NpImageDataFormat) dataFormat;

@end
