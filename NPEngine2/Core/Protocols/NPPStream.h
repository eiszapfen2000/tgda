#import "Core/Math/NpMath.h"

typedef enum NpStreamMode
{
    NpStreamRead = 0,
    NpStreamWrite = 1,
    NpStreamUpdate = 2
}
NpStreamMode;

@class NSString;
@class NPStringList;

@protocol NPPStream

- (BOOL) readInt8:(int8_t *)i;
- (BOOL) readInt16:(int16_t *)i;
- (BOOL) readInt32:(int32_t *)i;
- (BOOL) readInt64:(int64_t *)i;
- (BOOL) readUInt8:(uint8_t *)i;
- (BOOL) readUInt16:(uint16_t *)i;
- (BOOL) readUInt32:(uint32_t *)i;
- (BOOL) readUInt64:(uint64_t *)i;
- (BOOL) readFloat:(Float *)f;
- (BOOL) readDouble:(Double *)d;
- (BOOL) readBool:(BOOL *)b;
- (BOOL) readFVector2:(FVector2 *)v;
- (BOOL) readFVector3:(FVector3 *)v;
- (BOOL) readFVector4:(FVector4 *)v;
- (BOOL) readVector2:(Vector2 *)v;
- (BOOL) readVector3:(Vector3 *)v;
- (BOOL) readVector4:(Vector4 *)v;
- (BOOL) readIVector2:(IVector2 *)v;
- (BOOL) readSUXString:(NSString **)string;
- (BOOL) readSUXScript:(NPStringList **)script;

- (BOOL) writeInt8:(int8_t)i;
- (BOOL) writeInt16:(int16_t)i;
- (BOOL) writeInt32:(int32_t)i;
- (BOOL) writeInt64:(int64_t)i;
- (BOOL) writeUInt8:(uint8_t)u;
- (BOOL) writeUInt16:(uint16_t)u;
- (BOOL) writeUInt32:(uint32_t)u;
- (BOOL) writeUInt64:(uint64_t)u;
- (BOOL) writeFloat:(Float)f;
- (BOOL) writeDouble:(Double)d;
- (BOOL) writeBool:(BOOL)b;
- (BOOL) writeFVector2:(FVector2)v;
- (BOOL) writeFVector3:(FVector3)v;
- (BOOL) writeFVector4:(FVector4)v;
- (BOOL) writeVector2:(Vector2)v;
- (BOOL) writeVector3:(Vector3)v;
- (BOOL) writeVector4:(Vector4)v;
- (BOOL) writeIVector2:(IVector2)v;
- (BOOL) writeSUXString:(NSString *)string;
- (BOOL) writeSUXScript:(NPStringList *)script;


@end

