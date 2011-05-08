#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import "Log/NPLog.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPBufferObject.h"

@interface NPBufferObject (Private)

- (void) deleteBuffer;

@end

@implementation NPBufferObject (Private)

- (void) deleteBuffer
{
    if ( glID > 0 )
    {
        glDeleteBuffers(1, &glID);
        glID = 0;
    }
}

@end

@implementation NPBufferObject

- (id) init
{
    return [ self initWithName:@"Buffer Object" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    glGenBuffers(1, &glID);
    glTarget = GL_NONE;
    type = NpBufferObjectTypeUnknown;
    dataFormat = NpBufferDataFormatUnknown;
    numberOfComponents = 0;
    numberOfBytes = 0;
    numberOfElements = 0;

    return self;
}

- (void) dealloc
{
    [ self deleteBuffer ];
    [ super dealloc ];
}

- (GLuint) glID
{
    return glID;
}

- (GLenum) glDataFormat
{
    return getGLBufferDataFormat(dataFormat);
}

- (NpBufferDataFormat) dataFormat
{
    return dataFormat;
}

- (uint32_t) numberOfComponents
{
    return numberOfComponents;
}

- (NSUInteger) numberOfBytes
{
    return numberOfBytes;
}

- (NSUInteger) numberOfElements
{
    return numberOfElements;
}

- (BOOL) generate:(NpBufferObjectType)newType
       updateRate:(NpBufferDataUpdateRate)newUpdateRate
        dataUsage:(NpBufferDataUsage)newDataUsage
       dataFormat:(NpBufferDataFormat)newDataFormat
       components:(uint32_t)newNumberOfComponents
             data:(NSData *)newData
       dataLength:(NSUInteger)newDataLength
            error:(NSError **)error

{
    type = newType;
    updateRate = newUpdateRate;
    dataUsage = newDataUsage;
    dataFormat = newDataFormat;
    numberOfComponents = newNumberOfComponents;
    numberOfBytes = newDataLength;

    numberOfElements
        = numberOfBytes
          / ( numberOfComponents * numberOfBytesForDataFormat(dataFormat));

    glTarget = getGLBufferType(type);
    glBindBuffer(glTarget, glID);

    if ( glIsBuffer(glID) == GL_FALSE )
    {
        // set error
        NPLOG(@"Buffer generation error");

        // just to be on the safe side
        glBindBuffer(glTarget, 0);
        return NO;
    }

    GLenum bufferUsage = getGLBufferUsage(updateRate, dataUsage);
    glBufferData(glTarget, numberOfBytes, [ newData bytes ], bufferUsage);
    glBindBuffer(glTarget, 0);

    return YES;
}

- (void) activate
{
    glBindBuffer(glTarget, glID);
}

- (void) deactivate
{
    glBindBuffer(glTarget, 0);
}

@end
