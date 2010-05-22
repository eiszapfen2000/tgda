#import "NPResource.h"

@implementation NPResource

- (id) init
{
    return [ self initWithName:@"NPResource" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    fileName = @"";
    ready = NO;

    return self;
}

- (void) dealloc
{
    [ fileName release ];

    [ super dealloc ];
}

- (void) setFileName:(NSString *)newFileName
{
    ASSIGN(fileName, newFileName);
}

- (NSString *)fileName
{
    return fileName;
}

- (BOOL) loadFromPath:(NSString *)path;
{
    return NO;
}

- (BOOL) saveToFile:(NPFile *)file
{
    return NO;
}

- (void) reset
{
    ready = NO;

    [ fileName release ];
    fileName = @"";
}

- (BOOL) ready
{
    return ready;
}

@end
