#import "Core/Math/NpMath.h"

@protocol NPPStream

- (int16_t) readInt16;
- (int32_t) readInt32;
- (int64_t) readInt64;
- (uint16_t) readUInt16;
- (uint32_t) readUInt32;
- (uint64_t) readUInt64;
- (Float) readFloat;
- (Double) readDouble;
- (uint8_t) readByte;
- (char) readChar;
- (BOOL) readBool;
- (NSString *) readSUXString;
- (FVector2) readFVector2;
- (FVector3) readFVector3;
- (FVector4) readFVector4;
- (Vector2) readVector2;
- (Vector3) readVector3;
- (Vector4) readVector4;
- (IVector2) readIVector2;

- (void) writeInt16:(int16_t)i;
- (void) writeInt32:(int32_t)i;
- (void) writeInt64:(int64_t)i;
- (void) writeUInt16:(uint16_t)u;
- (void) writeUInt32:(uint32_t)u;
- (void) writeUInt64:(uint64_t)u;
- (void) writeFloat:(Float)f;
- (void) writeDouble:(Double)d;
- (void) writeByte:(uint8_t)b;
- (void) writeChar:(char)c;
- (void) writeBool:(BOOL)b;
- (void) writeSUXString:(NSString *)s;
- (void) writeFVector2:(FVector2)v;
- (void) writeFVector3:(FVector3)v;
- (void) writeFVector4:(FVector4)v;
- (void) writeVector2:(Vector2)v;
- (void) writeVector3:(Vector3)v;
- (void) writeVector4:(Vector4)v;
- (void) writeIVector2:(IVector2)v;

@end

