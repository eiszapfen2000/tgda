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

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    fileName = @"";
    ready = NO;

    return self;
}

- (void) setFileName:(NSString *)newFileName
{
    if ( fileName != newFileName )
    {
        [ fileName release ];
        fileName = [ newFileName retain ];
    }
}

- (NSString *)fileName
{
    return fileName;
}

- (void) reset
{
    ready = NO;
    fileName = @"";
}

- (BOOL) isReady
{
    return ready;
}

@end
