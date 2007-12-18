#import "Core/NPObject/NPObject.h"
#import "Core/Math/FVector.h"

@interface NPFile : NPObject
{
    NSString * fileName;
    NSFileHandle * fileHandle;
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent fileName:(NSString *)newFileName;
- (void) dealloc;

- (NSString *) fileName;
- (void) setFileName:(NSString *)newFileName;

- (void) initFileHandle;
- (void) clear;

- (void) readInt16:(Int16 *)i;
- (void) readInt32:(Int32 *)i;
- (void) readInt32s:(Int32 *)i withLength:(UInt)length;
- (void) readInt64:(Int64 *)i;

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

@end
