#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "GL/glew.h"

@class NSData;
@class NSError;

@interface NPCPUBuffer : NPObject
{
    NpCPUBufferType type;
    NpBufferDataFormat dataFormat;
    uint32_t numberOfComponents;
    NSUInteger numberOfBytes;
    NSUInteger numberOfElements;
    NSData * data;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (NpCPUBufferType) type;
- (NpBufferDataFormat) dataFormat;
- (uint32_t) numberOfComponents;
- (NSUInteger) numberOfBytes;
- (NSUInteger) numberOfElements;
- (NSData *) data;

- (BOOL) generate:(NpCPUBufferType)newType
       dataFormat:(NpBufferDataFormat)newDataFormat
       components:(uint32_t)newNumberOfComponents
             data:(NSData *)newData
       dataLength:(NSUInteger)newDataLength
            error:(NSError **)error
                 ;

@end

