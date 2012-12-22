#import <Foundation/NSException.h>
#import <Foundation/NSData.h>
#import "Log/NPLog.h"
#import "Core/String/NPStringList.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCoreErrors.h"
#import "NPFile.h"

@implementation NPFile

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    mode = NpStreamRead;

    return self;
}

- (id) initWithName:(NSString *)newName
           fileName:(NSString *)newFileName
               mode:(NpStreamMode)newMode
              error:(NSError **)error
{
    self = [ super initWithName:newName ];

    if ( [ self openFile:newFileName
                    mode:newMode
                   error:error ] == NO )
    {
        DESTROY(self);
        return nil;
    }

    return self;
}

- (void) dealloc
{
    [ self close ];
    [ super dealloc ];
}

- (NSString *) fileName
{
    return fileName;
}

- (NpStreamMode) mode
{
    return mode;
}

- (BOOL) openFile:(NSString *)newFileName
             mode:(NpStreamMode)newMode
            error:(NSError **)error
{
    [ self close ];

    ASSIGNCOPY(fileName, newFileName);
    mode = newMode;

    switch ( mode )
    {
        case NpStreamRead:
        {
            file = fopen([ fileName fileSystemRepresentation], "rb");
            break;
        }

        case NpStreamWrite:
        {
            file = fopen([ fileName fileSystemRepresentation], "wb");
            break;
        }

        case NpStreamUpdate:
        {
            file = fopen([ fileName fileSystemRepresentation], "r+");
            break;
        }
    }

    BOOL result = YES;
    if (file == NULL)
    {
        result = NO;

        if (error != NULL)
        {
            *error = [ NSError errorWithDomain:NPEngineErrorDomain
                                          code:NPStreamOpenError
                                      userInfo:nil ];
        }
    }

    return result;
}

- (void) close
{
    if ( file != NULL )
    {
        fclose(file);
        file = NULL;
        DESTROY(fileName);
    }
}

- (BOOL) readElementsToBuffer:(void *)buffer
                  elementSize:(size_t)elementSize
             numberOfElements:(size_t)numberOfElements
{
    NSAssert(file != NULL, @"Invalid file handle");

    return (fread(buffer, elementSize, numberOfElements, file) == numberOfElements);
}

- (BOOL) writeElements:(const void *)buffer
           elementSize:(size_t)elementSize
      numberOfElements:(size_t)numberOfElements
{
    NSAssert(file != NULL, @"Invalid file handle");

    return (fwrite(buffer, elementSize, numberOfElements, file) == numberOfElements);
}

#define READ_DATA(__type, __buffer) \
    [ self readElementsToBuffer:(__buffer) \
                    elementSize:sizeof(__type) \
               numberOfElements:1 ]

- (BOOL) readInt8:(int8_t *)i
{
    return READ_DATA(int8_t, i);
}

- (BOOL) readInt16:(int16_t *)i
{
    return READ_DATA(int16_t, i);
}

- (BOOL) readInt32:(int32_t *)i
{
    return READ_DATA(int32_t, i);
}

- (BOOL) readInt64:(int64_t *)i
{
    return READ_DATA(int64_t, i);
}

- (BOOL) readUInt8:(uint8_t *)i
{
    return READ_DATA(uint8_t, i);
}

- (BOOL) readUInt16:(uint16_t *)i
{
    return READ_DATA(uint16_t, i);
}

- (BOOL) readUInt32:(uint32_t *)i
{
    return READ_DATA(uint32_t, i);
}

- (BOOL) readUInt64:(uint64_t *)i
{
    return READ_DATA(uint64_t, i);
}

- (BOOL) readFloat:(Float *)f
{
    return READ_DATA(Float, f);
}

- (BOOL) readDouble:(Double *)d
{
    return READ_DATA(Double, d);
}

- (BOOL) readBool:(BOOL *)b
{
    return READ_DATA(BOOL, b);
}

- (BOOL) readSUXString:(NSString **)s
{
    if (s != NULL)
    {
        *s = nil;
    }

    int32_t stringLength = 0;
    if ( [ self readInt32:&stringLength ] == NO )
    {
        return NO;
    }

    if ( stringLength < 0 )
    {
        return NO;
    }

    if (( s != NULL ) && ( stringLength == 0 ))
    {
        *s = @"";
        return YES;
    }

    char * buffer = alloca((size_t)stringLength);
    if ( [ self readElementsToBuffer:buffer
                         elementSize:1
                    numberOfElements:(size_t)stringLength ] == NO )
    {
        return NO;
    }

    if ( s != NULL )
    {
        *s = [[ NSString alloc] initWithBytes:buffer
                                       length:(NSUInteger)stringLength
                                     encoding:NSASCIIStringEncoding ];
        AUTORELEASE(*s);
    }

    return YES;
}

- (BOOL) readSUXScript:(NPStringList **)s
{
    if ( s != NULL )
    {
        *s = nil;
    }

    int32_t numberOfLines = 0;
    if ( [ self readInt32:&numberOfLines ] == NO )
    {
        return NO;
    }

    if ( numberOfLines < 0 )
    {
        return NO;
    }

    NPStringList * script = AUTORELEASE([[ NPStringList alloc ] init ]);
    [ script setAllowDuplicates:YES ];
    [ script setAllowEmptyStrings:YES ];

    BOOL result = YES;
    NSString * line = nil;

    for ( int32_t i = 0; i < numberOfLines; i++ )
    {
        if ( [ self readSUXString:&line ] == NO )
        {
            result = NO;
            break;
        }
 
        [ script addString:line ];
        line = nil;
    }

    if ( result == YES && s != NULL )
    {
        *s = script;
    }

    return result;
}

- (BOOL) readFVector2:(FVector2 *)v
{
    return READ_DATA(FVector2, v);
}

- (BOOL) readFVector3:(FVector3 *)v
{
    return READ_DATA(FVector3, v);
}

- (BOOL) readFVector4:(FVector4 *)v
{
    return READ_DATA(FVector4, v);
}

- (BOOL) readVector2:(Vector2 *)v
{
    return READ_DATA(Vector2, v);
}

- (BOOL) readVector3:(Vector3 *)v
{
    return READ_DATA(Vector3, v);
}

- (BOOL) readVector4:(Vector4 *)v
{
    return READ_DATA(Vector4, v);
}

- (BOOL) readIVector2:(IVector2 *)v
{
    return READ_DATA(IVector2, v);
}

#define WRITE_DATA(__type, __buffer) \
    [ self writeElements:(__buffer) \
             elementSize:sizeof(__type) \
        numberOfElements:1 ]

- (BOOL) writeInt8:(int8_t)i
{
    return WRITE_DATA(int8_t, &i);
}

- (BOOL) writeInt16:(int16_t)i
{
    return WRITE_DATA(int16_t, &i);
}

- (BOOL) writeInt32:(int32_t)i
{
    return WRITE_DATA(int32_t, &i);
}

- (BOOL) writeInt64:(int64_t)i
{
    return WRITE_DATA(int64_t, &i);
}

- (BOOL) writeUInt8:(uint8_t)i
{
    return WRITE_DATA(uint8_t, &i);
}

- (BOOL) writeUInt16:(uint16_t)i
{
    return WRITE_DATA(uint16_t, &i);
}

- (BOOL) writeUInt32:(uint32_t)i
{
    return WRITE_DATA(uint32_t, &i);
}

- (BOOL) writeUInt64:(uint64_t)i
{
    return WRITE_DATA(uint64_t, &i);
}

- (BOOL) writeFloat:(Float)f
{
    return WRITE_DATA(Float, &f);
}

- (BOOL) writeDouble:(Double)d
{
    return WRITE_DATA(Double, &d);
}

- (BOOL) writeBool:(BOOL)b
{
    return WRITE_DATA(BOOL, &b);
}

- (BOOL) writeFVector2:(FVector2)v
{
    return WRITE_DATA(FVector2, &v);
}

- (BOOL) writeFVector3:(FVector3)v
{
    return WRITE_DATA(FVector3, &v);
}

- (BOOL) writeFVector4:(FVector4)v
{
    return WRITE_DATA(FVector4, &v);
}

- (BOOL) writeVector2:(Vector2)v
{
    return WRITE_DATA(Vector2, &v);
}

- (BOOL) writeVector3:(Vector3)v
{
    return WRITE_DATA(Vector3, &v);
}

- (BOOL) writeVector4:(Vector4)v
{
    return WRITE_DATA(Vector4, &v);
}

- (BOOL) writeIVector2:(IVector2)v
{
    return WRITE_DATA(IVector2, &v);
}

- (BOOL) writeSUXString:(NSString *)string
{
    const char * cString = NULL;
    size_t length = 0;

    if ( [ string canBeConvertedToEncoding:NSASCIIStringEncoding ] == NO )
    {
        NSData * d = [ string dataUsingEncoding:NSASCIIStringEncoding
                           allowLossyConversion:YES ];

        cString = [ d bytes ];
        length = [ d length ];
    }
    else
    {
        cString = [ string cStringUsingEncoding:NSASCIIStringEncoding ];
        length = [ string lengthOfBytesUsingEncoding:NSASCIIStringEncoding ];
    }

    if ( cString == NULL )
    {
        return NO;
    }

    if ( [ self writeInt32:(int32_t)length ] == NO )
    {
        return NO;
    }

    return [ self writeElements:cString
                    elementSize:1
               numberOfElements:length ];
}

- (BOOL) writeSUXScript:(NPStringList *)script
{
    NSUInteger numberOfLines = [ script count ];

    if ( [ self writeInt32:(int32_t)numberOfLines ] == NO )
    {
        return NO;
    }

    BOOL result = YES;
    for ( NSUInteger i = 0; i < numberOfLines; i++ )
    {
        if ( [ self writeSUXString:[ script stringAtIndex:i ]] == NO )
        {
            result = NO;
            break;
        }
    }

    return result;
}

@end

