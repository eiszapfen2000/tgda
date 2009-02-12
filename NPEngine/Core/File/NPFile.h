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
- (void) setFileName:(NSString *)newFileName;

- (NpState) mode;

- (void) initFileHandleWithMode:(NpState)newMode;
- (void) clear;

- (void) readInt16:(Int16 *)i;
- (void) readInt32:(Int32 *)i;
- (void) readInt32s:(Int32 *)i withLength:(UInt)length;
- (void) readInt64:(Int64 *)i;

- (void) readUInt16:(UInt16 *)i;
- (void) readUInt32:(UInt32 *)i;
- (void) readUInt32s:(UInt32 *)i withLength:(UInt)length;
- (void) readUInt64:(UInt64 *)i;

- (void) readFloat:(Float *)f;
- (void) readFloats:(Float *)f withLength:(UInt)length;
- (void) readDouble:(Double *)d;

- (void) readByte:(Byte *)b;
- (void) readBytes:(Byte *)b withLength:(UInt)length;

- (void) readChar:(Char *)c;
- (void) readChars:(Char *)c withLength:(UInt)length;
- (void) readBool:(BOOL *)b;

- (NSString *) readSUXString;
- (NSMutableArray *) readSUXScript;

- (FVector2 *) readFVector2;
- (FVector3 *) readFVector3;
- (FVector4 *) readFVector4;
- (IVector2 *) readIVector2;

- (NSData *)readEntireFile;

- (void) writeInt16:(Int16 *)i;
- (void) writeInt32:(Int32 *)i;
- (void) writeInt32s:(Int32 *)i withLength:(UInt)length;
- (void) writeInt64:(Int64 *)i;

- (void) writeUInt16:(UInt16 *)u;
- (void) writeUInt32:(UInt32 *)u;
- (void) writeUInt32s:(UInt32 *)u withLength:(UInt)length;
- (void) writeUInt64:(UInt64 *)u;

- (void) writeFloat:(Float *)f;
- (void) writeFloats:(Float *)f withLength:(UInt)length;
- (void) writeDouble:(Double *)d;

- (void) writeByte:(Byte *)b;
- (void) writeBytes:(Byte *)b withLength:(UInt)length;

- (void) writeChar:(Char *)c;
- (void) writeChars:(Char *)c withLength:(UInt)length;
- (void) writeBool:(BOOL *)b;

- (void) writeSUXString:(NSString *)s;
- (void) writeSUXScript:(NSArray *)script;

- (void) writeFVector2:(FVector2 *)v;
- (void) writeFVector3:(FVector3 *)v;
- (void) writeFVector4:(FVector4 *)v;
- (void) writeIVector2:(IVector2 *)v;

@end
