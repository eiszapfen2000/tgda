#import <Foundation/NSException.h>
#import "NPMemoryStream.h"

@implementation NPMemoryStream

- (id) init
{
    return [ self initWithName:@"NPMemoryStream" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    buffer = [[ NSData alloc ] init ];

    return self;
}

- (void) dealloc
{
    DESTROY(buffer);

    [ super dealloc ];
}

#define READ_DATA(_type) \
    _type result; \
    [ buffer getBytes:&result length:sizeof(_type)]; \
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
    /*
    int32_t slength = [ self readInt32 ];
    if ( slength > 0 )
    {
        NSData * data = [ fileHandle readDataOfLength:(uint32_t)slength ];

        NSString * s = [[ NSString alloc] initWithBytes:[data bytes]
                                                 length:(NSUInteger)slength
                                               encoding:NSASCIIStringEncoding ];

        return AUTORELEASE(s);
    }
    */

    return @"";
}

/*
- (NPStringList *) readSUXScript
{
    Int lines = 0;
    [self readInt32:&lines ];

    NPStringList * script = [[ NPStringList alloc ] init ];
    [ script setAllowDuplicates:YES ];
    [ script setAllowEmptyStrings:YES ];

    for ( Int i = 0; i < lines; i++ )
    {
        NSString * line = [ self readSUXString ];
        [ script addString:line ];
    }

    return [ script autorelease ];
}

*/

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

#undef READ_DATA

#define WRITE_DATA(_v) \
    [ buffer appendBytes:&(_v) length:sizeof(_v) ];

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

#undef WRITE_DATA

- (void) writeCharArray:(const char *)c length:(NSUInteger)length
{
    [ buffer appendBytes:c length:length ];
}

- (void) writeSUXString:(NSString *)s
{
    NSUInteger ulength = [ s lengthOfBytesUsingEncoding:NSASCIIStringEncoding ];
    int32_t length = (int32_t)ulength;
    [ self writeInt32:length ];

    char * cstring = (char *)[ s cStringUsingEncoding:NSASCIIStringEncoding ];
    [ self writeCharArray:cstring length:ulength ];
}

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
