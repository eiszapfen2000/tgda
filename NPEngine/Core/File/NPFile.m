#import "NPFile.h"

@implementation NPFile

- (id) init
{
    return [ self initWithName:@"NPFile" parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    return [ self initWithName:newName parent:newParent fileName:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent fileName:(NSString *)newFileName
{
    self = [ super initWithName:newName parent:newParent ];

    fileName = [ newFileName retain ];

    [ self initFileHandle ];

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

- (void) initFileHandle
{
    fileHandle = [ [ NSFileHandle fileHandleForReadingAtPath:fileName ] retain ];
}

- (void) clear
{
    [ fileHandle closeFile ];
    [ fileHandle release ];
    fileHandle = nil;

    [ fileName release ];
    fileName = nil;
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
    [ data getBytes:b ];
}

- (NSString *) readSUXString
{
    Int slength;
    [self readInt32:&slength ];

    if ( slength > 0 )
    {
        NSData * data = [ fileHandle readDataOfLength:(UInt)slength ];
        NSString * s = [[NSString alloc] initWithBytes:[data bytes] length:(UInt)slength encoding:NSASCIIStringEncoding ];

        return s;
    }

    return @"";
}

- (NSMutableArray *) readSUXScript
{
    Int lines;
    [self readInt32:&lines ];

    NSMutableArray * script = [ [ NSMutableArray alloc ] initWithCapacity:(UInt)lines ];

    for ( Int i = 0; i < lines; i++ )
    {
        NSString * line = [ self readSUXString ];
        [ script addObject: line ];
        [ line release ];
    }

    return script;
}

- (FVector2 *) readFVector2
{
    FVector2 * v = fv2_alloc_init();
    [ self readFloat:&(FV_X(*v)) ];
    [ self readFloat:&(FV_Y(*v)) ];

    return v;
}

- (FVector3 *) readFVector3
{
    FVector3 * v = fv3_alloc_init();
    [ self readFloat:&(FV_X(*v)) ];
    [ self readFloat:&(FV_Y(*v)) ];
    [ self readFloat:&(FV_Z(*v)) ];

    return v;
}

- (FVector4 *) readFVector4
{
    FVector4 * v = fv4_alloc_init();
    [ self readFloat:&(FV_X(*v)) ];
    [ self readFloat:&(FV_Y(*v)) ];
    [ self readFloat:&(FV_Z(*v)) ];
    [ self readFloat:&(FV_W(*v)) ];

    return v;
}

@end
