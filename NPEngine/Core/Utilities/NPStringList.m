#import <Foundation/NSScanner.h>
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
    return [ self initWithName:newName
                        parent:newParent
               allowDuplicates:NO
             allowEmptyStrings:NO ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
    allowDuplicates:(BOOL)newAllowDuplicates
  allowEmptyStrings:(BOOL)newAllowEmptyStrings
{
    self = [ super initWithName:newName parent:newParent ];

    lines = [[ NSMutableArray alloc ] init ];

    allowDuplicates = newAllowDuplicates;
    allowEmptyStrings = newAllowEmptyStrings;

    return self;
}

- (void) dealloc
{
    [ self clear ];
    DESTROY(lines);

    [ super dealloc ];
}

- (void) clear
{
    [ lines removeAllObjects ];
}

- (void) addString:(NSString *)string
{
    if ( allowDuplicates == NO &&
         [ lines containsObject:string ] == YES )
    {
        return;
    }

    if ( allowEmptyStrings == NO &&
         [ string length ] == 0 )
    {
        return;
    }

    [ lines addObject:string ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSString * fileContents = [ NSString stringWithContentsOfFile:path ];

    if ( fileContents == nil )
    {
        return NO;
    }

    NSCharacterSet * newlineSet = [ NSCharacterSet newlineCharacterSet ];
    NSScanner * scanner = [ NSScanner scannerWithString:fileContents ];

    while ( [ scanner isAtEnd ] == NO )
    {
        NSString * string;
        if ( [ scanner scanUpToCharactersFromSet:newlineSet  intoString:&string ] == YES )
        {
            [ self addString:string ];
        }
    }

    NSLog([lines description]);

    return YES;
}

@end
