#import <Foundation/NSException.h>
#import <Foundation/NSScanner.h>
#import "Core/File/NPFile.h"
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

- (BOOL) allowDuplicates
{
    return allowDuplicates;
}

- (BOOL) allowEmptyStrings
{
    return allowEmptyStrings;
}

- (NSUInteger) count
{
    return [ lines count ];
}

- (NSString *) stringAtIndex:(NSUInteger)index
{
    return [ lines objectAtIndex:index ];
}

- (void) setAllowDuplicates:(BOOL)newAllowDuplicates
{
    allowDuplicates = newAllowDuplicates;
}

- (void) setAllowEmptyStrings:(BOOL)newAllowEmptyStrings
{
    allowEmptyStrings = newAllowEmptyStrings;
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

- (void) addStringsFromArray:(NSArray *)array
{
    [ lines addObjectsFromArray:array ];
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    [ self clear ];

    int32_t numberOfLines = [ stream readInt32 ];
    for ( int32_t i = 0; i < numberOfLines; i++ )
    {
        [ self addString:[ stream readSUXString ]];
    }

    return YES;
}

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
{
    NSStringEncoding encoding;
    NSString * fileContents = 
        [[ NSString alloc ] initWithContentsOfFile:fileName 
                                      usedEncoding:&encoding
                                             error:error ];

    if ( fileContents == nil )
    {
        return NO;
    }

    [ self clear ];

    NSCharacterSet * newlineSet = [ NSCharacterSet newlineCharacterSet ];
    NSScanner * scanner = [ NSScanner scannerWithString:fileContents ];

    while ( [ scanner isAtEnd ] == NO )
    {
        NSString * string;
        if ( [ scanner scanUpToCharactersFromSet:newlineSet 
                                      intoString:&string ] == YES )
        {
            [ self addString:string ];
        }
    }

    return YES;
}

- (NSString *) description
{
    return [ lines description ];
}

@end
