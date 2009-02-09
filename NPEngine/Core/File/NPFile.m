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

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent fileName:(NSString *)newFileName
{
    return [ self initWithName:newName parent:newParent fileName:newFileName mode:NP_FILE_READING ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent fileName:(NSString *)newFileName mode:(NpState)newMode
{
    self = [ super initWithName:newName parent:newParent ];

    fileName = [ newFileName retain ];
    fileHandle = nil;

    [ self initFileHandleWithMode:newMode ];

    return self;
}

- (void) dealloc
{
    [ self clear ];

    [ super dealloc ];
}

- (NSString *) fileName
{
    return fileName;
}

- (void) setFileName:(NSString *)newFileName
{
    if ( fileName != newFileName )
    {
        [ fileName release ];
        fileName = [ newFileName retain ];
    }
}

- (NpState) mode
{
    return mode;
}

- (void) initFileHandleWithMode:(NpState)newMode
{
    if ( fileHandle != nil )
    {
        [ fileHandle closeFile ];
        [ fileHandle release ];
        fileHandle = nil;
    }

    mode = newMode;

    switch ( mode )
    {
        case ( NP_FILE_READING ):
        {
            fileHandle = [[ NSFileHandle fileHandleForReadingAtPath:fileName ] retain ];
            break;
        }

        case ( NP_FILE_UPDATING ):
        {
            fileHandle = [[ NSFileHandle fileHandleForUpdatingAtPath:fileName ] retain ];
            break;
        }

        case ( NP_FILE_WRITING ):
        {
            fileHandle = [[ NSFileHandle fileHandleForWritingAtPath:fileName ] retain ];
            break;
        }

        default:
        {
            fileHandle = [[ NSFileHandle fileHandleForReadingAtPath:fileName ] retain ];
            break;
        }
    }
}

- (void) clear
{
    [ fileHandle closeFile ];
    [ fileHandle release ];
    fileHandle = nil;

    [ fileName release ];
    fileName = @"";

    mode = NP_NONE;
}

- (void) readInt16:(Int16 *)i
{
    NSData * data = [ fileHandle readDataOfLength:2 ];
    [ data getBytes:i ];
}

- (void) readInt32:(Int32 *)i
{
    NSData * data = [ fileHandle readDataOfLength:4 ];
    [ data getBytes:i ];
}

- (void) readInt32s:(Int32 *)i withLength:(UInt)length
{
    NSData * data = [ fileHandle readDataOfLength:(4*length) ];
    [ data getBytes:i ];
}

- (void) readInt64:(Int64 *)i;
{
    NSData * data = [ fileHandle readDataOfLength:8 ];
    [ data getBytes:i ];
}

- (void) readFloat:(Float *)f
{
    NSData * data = [ fileHandle readDataOfLength:4 ];
    [ data getBytes:f ];
}

- (void) readFloats:(Float *)f withLength:(UInt)length
{
    NSData * data = [ fileHandle readDataOfLength:(4*length) ];
    [ data getBytes:f ];
}

- (void) readDouble:(Double *)d
{
    NSData * data = [ fileHandle readDataOfLength:8 ];
    [ data getBytes:d ];
}

- (void) readByte:(Byte *)b
{
    NSData * data = [ fileHandle readDataOfLength:1 ];
    [ data getBytes:b ];
}

- (void) readBytes:(Byte *)b withLength:(UInt)length
{
    NSData * data = [ fileHandle readDataOfLength:length ];
    [ data getBytes:b ];
}

- (void) readChar:(Char *)c
{
    NSData * data = [ fileHandle readDataOfLength:1 ];
    [ data getBytes:c ];
}

- (void) readChars:(Char *)c withLength:(UInt)length
{
    NSData * data = [ fileHandle readDataOfLength:length ];
    [ data getBytes:c ];
}

- (void) readBool:(BOOL *)b
{
    NSData * data = [ fileHandle readDataOfLength:1 ];
    Byte tmp;
    [ data getBytes:&tmp ];
    *b = (BOOL)tmp;
}

- (NSString *) readSUXString
{
    Int slength;
    [self readInt32:&slength ];

    if ( slength > 0 )
    {
        NSData * data = [ fileHandle readDataOfLength:(UInt)slength ];
        NSString * s = [[ NSString alloc] initWithBytes:[data bytes] length:(UInt)slength encoding:NSASCIIStringEncoding ];

        return s;
    }

    return @"";
}

- (NSMutableArray *) readSUXScript
{
    Int lines;
    [self readInt32:&lines ];

    NSMutableArray * script = [[ NSMutableArray alloc ] initWithCapacity:(UInt)lines ];

    for ( Int i = 0; i < lines; i++ )
    {
        NSString * line = [ self readSUXString ];
        [ script addObject:line ];
        [ line release ];
    }

    return script;
}

- (FVector2 *) readFVector2
{
    FVector2 * v = fv2_alloc_init();
    [ self readFloat:&(V_X(*v)) ];
    [ self readFloat:&(V_Y(*v)) ];

    return v;
}

- (FVector3 *) readFVector3
{
    FVector3 * v = fv3_alloc_init();
    [ self readFloat:&(V_X(*v)) ];
    [ self readFloat:&(V_Y(*v)) ];
    [ self readFloat:&(V_Z(*v)) ];

    return v;
}

- (FVector4 *) readFVector4
{
    FVector4 * v = fv4_alloc_init();
    [ self readFloat:&(V_X(*v)) ];
    [ self readFloat:&(V_Y(*v)) ];
    [ self readFloat:&(V_Z(*v)) ];
    [ self readFloat:&(V_W(*v)) ];

    return v;
}

- (NSData *) readEntireFile
{
    return [ fileHandle readDataToEndOfFile ];
}

- (void) writeInt16:(Int16 *)i
{
    NSData * data = [ NSData dataWithBytes:i length:2 ];
    [ fileHandle writeData:data ];
}
- (void) writeInt32:(Int32 *)i
{
    NSData * data = [ NSData dataWithBytes:i length:4 ];
    [ fileHandle writeData:data ];
}

- (void) writeInt32s:(Int32 *)i withLength:(UInt)length
{
    NSData * data = [ NSData dataWithBytes:i length:4*length ];
    [ fileHandle writeData:data ];
}

- (void) writeInt64:(Int64 *)i
{
    NSData * data = [ NSData dataWithBytes:i length:8 ];
    [ fileHandle writeData:data ];
}

- (void) writeUInt16:(UInt16 *)u
{
    NSData * data = [ NSData dataWithBytes:u length:2 ];
    [ fileHandle writeData:data ];
}
- (void) writeUInt32:(UInt32 *)u
{
    NSData * data = [ NSData dataWithBytes:u length:4 ];
    [ fileHandle writeData:data ];
}

- (void) writeUInt32s:(UInt32 *)u withLength:(UInt)length
{
    NSData * data = [ NSData dataWithBytes:u length:4*length ];
    [ fileHandle writeData:data ];
}

- (void) writeUInt64:(UInt64 *)u
{
    NSData * data = [ NSData dataWithBytes:u length:8 ];
    [ fileHandle writeData:data ];
}

- (void) writeFloat:(Float *)f
{
    NSData * data = [ NSData dataWithBytes:f length:4 ];
    [ fileHandle writeData:data ];
}

- (void) writeFloats:(Float *)f withLength:(UInt)length
{
    NSData * data = [ NSData dataWithBytes:f length:4*length ];
    [ fileHandle writeData:data ];
}

- (void) writeDouble:(Double *)d
{
    NSData * data = [ NSData dataWithBytes:d length:8 ];
    [ fileHandle writeData:data ];
}

- (void) writeByte:(Byte *)b
{
    NSData * data = [ NSData dataWithBytes:b length:1 ];
    [ fileHandle writeData:data ];
}

- (void) writeBytes:(Byte *)b withLength:(UInt)length
{
    NSData * data = [ NSData dataWithBytes:b length:length ];
    [ fileHandle writeData:data ];
}

- (void) writeChar:(Char *)c
{
    NSData * data = [ NSData dataWithBytes:c length:1 ];
    [ fileHandle writeData:data ];
}

- (void) writeChars:(Char *)c withLength:(UInt)length
{
    NSData * data = [ NSData dataWithBytes:c length:length ];
    [ fileHandle writeData:data ];
}

- (void) writeBool:(BOOL *)b
{
    Byte tmp = (Byte)(*b);
    NSData * data = [ NSData dataWithBytes:&tmp length:1 ];
    [ fileHandle writeData:data ];
}

- (void) writeSUXString:(NSString *)s
{
    UInt32 ulength = [ s lengthOfBytesUsingEncoding:NSASCIIStringEncoding ];
    Int32 length = (Int32)ulength;

    [ self writeInt32:&length ];

    char * cstring = (char *)[ s cStringUsingEncoding:NSASCIIStringEncoding ];

    [ self writeChars:cstring withLength:ulength ];
}

- (void) writeSUXScript:(NSArray *)script
{
    Int32 lines = (Int32)[ script count ];
    [ self writeInt32:&lines ];

    for ( Int i = 0; i < lines; i++ )
    {
        [ self writeSUXString:[ script objectAtIndex:i ]];
    }
}

- (void) writeFVector2:(FVector2 *)v
{
    [ self writeFloat:&(V_X(*v)) ];
    [ self writeFloat:&(V_Y(*v)) ];
}

- (void) writeFVector3:(FVector3 *)v
{
    [ self writeFloat:&(V_X(*v)) ];
    [ self writeFloat:&(V_Y(*v)) ];
    [ self writeFloat:&(V_Z(*v)) ];
}

- (void) writeFVector4:(FVector4 *)v
{
    [ self writeFloat:&(V_X(*v)) ];
    [ self writeFloat:&(V_Y(*v)) ];
    [ self writeFloat:&(V_Z(*v)) ];
    [ self writeFloat:&(V_W(*v)) ];
}

@end
