#import <Foundation/NSException.h>
#import <Foundation/NSData.h>
#import "Log/NPLog.h"
#import "Core/Utilities/NPStringList.h"
#import "Core/NPEngineCoreErrors.h"
#import "NPFile.h"

@implementation NPFile

- (id) init
{
    return [ self initWithName:@"NPFile" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName parent:newParent fileName:@"" ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
           fileName:(NSString *)newFileName
{
    return [ self initWithName:newName 
                        parent:newParent
                      fileName:newFileName
                          mode:NpStreamRead
                         error:NULL ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
           fileName:(NSString *)newFileName
               mode:(NpStreamMode)newMode
              error:(NSError **)error
{
    self = [ super initWithName:newName parent:newParent ];

    [ self openFile:newFileName
               mode:newMode
              error:error ];

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
            fileHandle = RETAIN([ NSFileHandle fileHandleForReadingAtPath:fileName ]);
            break;
        }

        case NpStreamWrite:
        {
            fileHandle = RETAIN([ NSFileHandle fileHandleForWritingAtPath:fileName ]);
            break;
        }

        case NpStreamUpdate:
        {
            fileHandle = RETAIN([ NSFileHandle fileHandleForUpdatingAtPath:fileName ]);
            break;
        }
    }

    BOOL result = YES;
    if (fileHandle == nil)
    {
        result = NO;

        if (error != 0)
        {
            *error = [ NSError errorWithDomain:NPEngineErrorDomain
                                          code:NPStreamOpenError
                                      userInfo:nil ];

            NPLOG_ERROR(*error);
        }
    }

    return result;
}

- (void) close
{
    if ( fileHandle != nil )
    {
        [ fileHandle closeFile ];
        DESTROY(fileHandle);
        DESTROY(fileName);
    }
}

#define READ_DATA(_type) \
    _type result; \
    NSData * data = [ fileHandle readDataOfLength:sizeof(_type) ]; \
    [ data getBytes:&result ]; \
    return result;

- (int16_t) readInt16
{
    READ_DATA(int16_t);
}

- (int32_t) readInt32
{
    READ_DATA(int32_t);
}

- (int64_t) readInt64
{
    READ_DATA(int64_t);
}

- (uint16_t) readUInt16
{
    READ_DATA(uint16_t);
}

- (uint32_t) readUInt32
{
    READ_DATA(uint32_t);
}

- (uint64_t) readUInt64
{
    READ_DATA(uint64_t);
}

- (Float) readFloat
{
    READ_DATA(Float);
}

- (Double) readDouble
{
    READ_DATA(Double);
}

- (BOOL) readBool
{
    READ_DATA(BOOL);
}

- (uint8_t) readByte
{
    READ_DATA(uint8_t);
}

- (char) readChar
{
    READ_DATA(char);
}

- (NSString *) readSUXString
{
    int32_t stringLength = [ self readInt32 ];
    if ( stringLength > 0 )
    {
        NSData * data =
            [ fileHandle readDataOfLength:(uint32_t)stringLength ];

        NSString * string =
            [[ NSString alloc] initWithBytes:[data bytes]
                                      length:(NSUInteger)stringLength
                                    encoding:NSASCIIStringEncoding ];

        return AUTORELEASE(string);
    }

    return @"";
}

- (NPStringList *) readSUXScript
{
    NPStringList * script = [[ NPStringList alloc ] init ];
    [ script setAllowDuplicates:YES ];
    [ script setAllowEmptyStrings:YES ];

    int32_t numberOfLines = [ self readInt32 ];
    for ( int32_t i = 0; i < numberOfLines; i++ )
    {
        NSString * line = [ self readSUXString ];
        [ script addString:line ];
    }

    return AUTORELEASE(script);
}

#undef READ_DATA

- (FVector2) readFVector2
{
    FVector2 v;
    v.x = [ self readFloat ];
    v.y = [ self readFloat ];
    
    return v;
}

- (FVector3) readFVector3
{
    FVector3 v;
    v.x = [ self readFloat ];
    v.y = [ self readFloat ];
    v.z = [ self readFloat ];

    return v;
}

- (FVector4) readFVector4
{
    FVector4 v;
    v.x = [ self readFloat ];
    v.y = [ self readFloat ];
    v.z = [ self readFloat ];
    v.w = [ self readFloat ];

    return v;
}

- (Vector2) readVector2
{
    Vector2 v;
    v.x = [ self readDouble ];
    v.y = [ self readDouble ];
    
    return v;
}

- (Vector3) readVector3
{
    Vector3 v;
    v.x = [ self readDouble ];
    v.y = [ self readDouble ];
    v.z = [ self readDouble ];

    return v;
}

- (Vector4) readVector4
{
    Vector4 v;
    v.x = [ self readDouble ];
    v.y = [ self readDouble ];
    v.z = [ self readDouble ];
    v.w = [ self readDouble ];

    return v;
}

- (IVector2) readIVector2
{
    IVector2 v;
    v.x = [ self readInt32 ];
    v.y = [ self readInt32 ];

    return v;
}

- (NSData *) readEntireFile
{
    return [ fileHandle readDataToEndOfFile ];
}

#define WRITE_DATA(_v) \
    NSData * data = [ NSData dataWithBytes:&(_v) length:sizeof(_v) ]; \
    [ fileHandle writeData:data ];

- (void) writeInt16:(int16_t)i
{
    WRITE_DATA(i);
}

- (void) writeInt32:(int32_t)i
{
    WRITE_DATA(i);
}

- (void) writeInt64:(int64_t)i
{
    WRITE_DATA(i);
}

- (void) writeUInt16:(uint16_t)u
{
    WRITE_DATA(u);
}

- (void) writeUInt32:(uint32_t)u
{
    WRITE_DATA(u);
}

- (void) writeUInt64:(uint64_t)u
{
    WRITE_DATA(u);
}

- (void) writeFloat:(Float)f
{
    WRITE_DATA(f);
}

- (void) writeDouble:(Double)d
{
    WRITE_DATA(d);
}

- (void) writeByte:(uint8_t)b
{
    WRITE_DATA(b);
}

- (void) writeChar:(char)c
{
    WRITE_DATA(c);
}

- (void) writeBool:(BOOL)b
{
    WRITE_DATA(b);
}

- (void) writeCharArray:(const char *)c
                 length:(NSUInteger)length
{
    NSData * data = [ NSData dataWithBytes:c length:length ];
    [ fileHandle writeData:data ];
}

- (void) writeSUXString:(NSString *)string
{
    char * cstring = (char *)[ string cStringUsingEncoding:NSASCIIStringEncoding ];

    NSUInteger ASCIIStringLength =
        [ string lengthOfBytesUsingEncoding:NSASCIIStringEncoding ];

    [ self writeInt32:(int32_t)ASCIIStringLength ];
    [ self writeCharArray:cstring length:ASCIIStringLength ];
}

- (void) writeSUXScript:(NPStringList *)script
{
    int32_t lines = (int32_t)[ script count ];
    [ self writeInt32:lines ];

    for ( int32_t i = 0; i < lines; i++ )
    {
        [ self writeSUXString:[ script stringAtIndex:i ]];
    }
}

#undef WRITE_DATA

- (void) writeFVector2:(FVector2)v
{
    [ self writeFloat:v.x ];
    [ self writeFloat:v.y ];
}

- (void) writeFVector3:(FVector3)v
{
    [ self writeFloat:v.x ];
    [ self writeFloat:v.y ];
    [ self writeFloat:v.z ];
}

- (void) writeFVector4:(FVector4)v
{
    [ self writeFloat:v.x ];
    [ self writeFloat:v.y ];
    [ self writeFloat:v.z ];
    [ self writeFloat:v.w ];
}

- (void) writeVector2:(Vector2)v
{
    [ self writeDouble:v.x ];
    [ self writeDouble:v.y ];
}

- (void) writeVector3:(Vector3)v
{
    [ self writeDouble:v.x ];
    [ self writeDouble:v.y ];
    [ self writeDouble:v.z ];
}

- (void) writeVector4:(Vector4)v
{
    [ self writeDouble:v.x ];
    [ self writeDouble:v.y ];
    [ self writeDouble:v.z ];
    [ self writeDouble:v.w ];
}

- (void) writeIVector2:(IVector2)v
{
    [ self writeInt32:v.x ];
    [ self writeInt32:v.y ];
}

@end
