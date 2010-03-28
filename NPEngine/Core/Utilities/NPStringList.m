#import "Core/File/NPPathUtilities.h"
#import "NPStringList.h"

@implementation NPStringList

- (id) init
{
    return [ self initWithName:@"NPStringList" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(lines);

    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSString * fileContents = [ NSString stringWithContentsOfFile:path ];

    if ( fileContents == nil )
    {
        return NO;
    }

    lines = [[ fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] retain ];

    return YES;
}

@end
