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
//    fileContents = nil;
    [ self readBytesFromFile ];

    return self;
}

- (void) dealloc
{
    [ fileName release ];
    [ fileContents release ];

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

- (void) readBytesFromFile
{
    NSFileHandle * fileHandle = [ NSFileHandle fileHandleForReadingAtPath:fileName ];
    fileContents = [ [ fileHandle readDataToEndOfFile ] retain ];
}

- (void) clear
{
    [ fileContents release ];
    fileContents = nil;
}

@end
