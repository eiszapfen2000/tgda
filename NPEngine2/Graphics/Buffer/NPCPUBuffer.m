#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "NPCPUBuffer.h"

@implementation NPCPUBuffer

- (id) init
{
    return [ self initWithName:@"CPU Buffer" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    type = NpCPUBufferTypeUnknown;
    dataFormat = NpBufferDataFormatUnknown;
    numberOfComponents = 0;
    numberOfBytes = 0;
    numberOfElements = 0;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (NpCPUBufferType) type
{
    return type;
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

- (NSData *) data
{
    return data;
}

- (BOOL) generate:(NpCPUBufferType)newType
       dataFormat:(NpBufferDataFormat)newDataFormat
       components:(uint32_t)newNumberOfComponents
             data:(NSData *)newData
       dataLength:(NSUInteger)newDataLength
            error:(NSError **)error
{
    NSAssert(newData != nil, @"");

    type = newType;
    dataFormat = newDataFormat;
    numberOfComponents = newNumberOfComponents;
    numberOfBytes = newDataLength;

    numberOfElements
        = numberOfBytes
          / ( numberOfComponents * numberOfBytesForDataFormat(dataFormat));

    data = RETAIN(newData);

    return YES;
}

@end
