#import <Foundation/NSFileHandle.h>
#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"

#define NP_FILE_READING     0
#define NP_FILE_UPDATING    1
#define NP_FILE_WRITING     2

@interface NPFile : NPObject
{
    NSString * fileName;
    NSFileHandle * fileHandle;
    NpState mode;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent fileName:(NSString *)newFileName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent fileName:(NSString *)newFileName mode:(NpState)newMode;
- (void) dealloc;

- (NSString *) fileName;
- (NpState) mode;

- (void) initFileHandleWithMode:(NpState)newMode;
- (void) clear;

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
//- (NPStringList *) readSUXScript;

- (FVector2) readFVector2;
- (FVector3) readFVector3;
- (FVector4) readFVector4;
- (IVector2) readIVector2;

- (NSData *) readEntireFile;

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
- (void) writeCharArray:(const char *)c length:(NSUInteger)length;

- (void) writeSUXString:(NSString *)s;
//- (void) writeSUXScript:(NPStringList *)script;

- (void) writeFVector2:(FVector2)v;
- (void) writeFVector3:(FVector3)v;
- (void) writeFVector4:(FVector4)v;
- (void) writeIVector2:(IVector2)v;

@end
