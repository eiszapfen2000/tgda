#import <Foundation/NSException.h>
#import <Foundation/NSIndexSet.h>
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

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
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

    file = nil;
    strings = [[ NSMutableArray alloc ] init ];

    allowDuplicates = newAllowDuplicates;
    allowEmptyStrings = newAllowEmptyStrings;

    return self;
}

- (void) dealloc
{
    [ self clear ];
    DESTROY(strings);

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
    return [ strings count ];
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return YES;
}

- (NSString *) stringAtIndex:(NSUInteger)index
{
    return AUTORELEASE([[ strings objectAtIndex:index ] copy ]);
}

- (NPStringList *) stringListWithRange:(NSRange)range
{
    NPStringList * result = AUTORELEASE([[ NPStringList alloc ] init ]);
    [ result addStringsFromArray:[ strings subarrayWithRange:range ]];

    return result;
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
    SAFE_DESTROY(file);
    [ strings removeAllObjects ];
}

- (void) addString:(NSString *)string
{
    if ( allowDuplicates == NO &&
         [ strings containsObject:string ] == YES )
    {
        return;
    }

    if ( allowEmptyStrings == NO &&
         [ string length ] == 0 )
    {
        return;
    }

    [ strings addObject:string ];
}

- (void) addStringsFromArray:(NSArray *)array
{
    NSUInteger numberOfElements = [ array count ];
    for ( NSUInteger i = 0; i < numberOfElements; i++ )
    {
        [ self addString:[ array objectAtIndex:i ]];
    }
}


- (void) insertString:(NSString *)string atIndex:(NSUInteger)index
{
    if ( allowDuplicates == NO &&
         [ strings containsObject:string ] == YES )
    {
        return;
    }

    if ( allowEmptyStrings == NO &&
         [ string length ] == 0 )
    {
        return;
    }

    [ strings insertObject:string atIndex:index ];
}

- (void) insertStrings:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    NSUInteger currentIndex = [ indexes firstIndex ];
    NSUInteger numberOfIndexes = [ indexes count ];

    for (NSUInteger i = 0; i< numberOfIndexes; i++ )
    {
        [ self insertString:[ array objectAtIndex:i ] atIndex:currentIndex ];
        currentIndex = [ indexes indexGreaterThanIndex:currentIndex ];
    }    
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    [ self clear ];

    int32_t numberOfLines = 0;
    BOOL result = [ stream readInt32:&numberOfLines ];

    if ( result == NO )
    {
        return NO;
    }

    result = YES;
    NSString * line = nil;

    for ( int32_t i = 0; i < numberOfLines; i++ )
    {
        if ( [ stream readSUXString:&line ] == NO )
        {
            result = NO;
            break;
        }
 
        [ self addString:line ];
        line = nil;
    }

    return result;
}

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
{
    NSStringEncoding encoding;
    NSString * fileContents 
        = [ NSString stringWithContentsOfFile:fileName
                                 usedEncoding:&encoding
                                        error:error ];

    if ( fileContents == nil )
    {
        return NO;
    }

    [ self clear ];
    ASSIGNCOPY(file, fileName);

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
    return [ strings description ];
}

@end
