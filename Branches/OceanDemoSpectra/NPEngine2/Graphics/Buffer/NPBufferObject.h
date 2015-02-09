#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "GL/glew.h"

@class NSData;
@class NSError;

@interface NPBufferObject : NPObject
{
    GLuint glID;
    GLenum glTarget;
    NpBufferObjectType type;
    NpBufferDataUpdateRate updateRate;
    NpBufferDataUsage dataUsage;
    NpBufferDataFormat dataFormat;
    uint32_t numberOfComponents;
    NSUInteger numberOfBytes;
    NSUInteger numberOfElements;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (GLuint) glID;
- (GLenum) glDataFormat;
- (NpBufferDataFormat) dataFormat;
- (uint32_t) numberOfComponents;
- (NSUInteger) numberOfBytes;
- (NSUInteger) numberOfElements;

- (BOOL) generateStaticGeometryBuffer:(NpBufferDataFormat)newDataFormat
                           components:(uint32_t)newNumberOfComponents
                                 data:(NSData *)newData
                           dataLength:(NSUInteger)newDataLength
                                error:(NSError **)error
                                     ;

- (BOOL) generate:(NpBufferObjectType)newType
       updateRate:(NpBufferDataUpdateRate)newUpdateRate
        dataUsage:(NpBufferDataUsage)newDataUsage
       dataFormat:(NpBufferDataFormat)newDataFormat
       components:(uint32_t)newNumberOfComponents
             data:(NSData *)newData
       dataLength:(NSUInteger)newDataLength
            error:(NSError **)error
                 ;

- (void) activate;
- (void) deactivate;

@end

