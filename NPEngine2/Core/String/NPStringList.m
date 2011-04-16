#import <Foundation/NSException.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSScanner.h>
#import "Core/NPEngineCore.h"
#import "Core/File/NPLocalPathManager.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "NPStringList.h"

@implementation NPStringList

+ (id) stringList
{
    return AUTORELEASE([[ NPStringList alloc ] init ]);
}

+ (id) stringListWithStringList:(NPStringList *)stringList
{
    NSRange range;
    range.location = 0;
    range.length = [ stringList count ];

    return [ stringList stringListInRange:range ];
}

+ (id) stringListWithContentsOfFile:(NSString *)fileName
                              error:(NSError **)error
{
    NPStringList * stringList = ([[ NPStringList alloc ] init ]);
    if ( [ stringList loadFromFile:fileName
                         arguments:nil
                             error:error ] == NO )
    {
        DESTROY(stringList);
        return nil;
    }

    return AUTORELEASE(stringList);
}

- (id) init
{
    return [ self initWithName:@"NPStringList" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName
               allowDuplicates:NO
             allowEmptyStrings:NO ];
}

- (id) initWithName:(NSString *)newName
    allowDuplicates:(BOOL)newAllowDuplicates
  allowEmptyStrings:(BOOL)newAllowEmptyStrings
{
    self = [ super initWithName:newName ];

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

- (void) clear
{
    SAFE_DESTROY(file);
    [ strings removeAllObjects ];
}

- (BOOL) allowDuplicates
{
    return allowDuplicates;
}

- (BOOL) allowEmptyStrings
{
    return allowEmptyStrings;
}

- (void) setAllowDuplicates:(BOOL)newAllowDuplicates
{
    allowDuplicates = newAllowDuplicates;
}

- (void) setAllowEmptyStrings:(BOOL)newAllowEmptyStrings
{
    allowEmptyStrings = newAllowEmptyStrings;
}

- (NSUInteger) count
{
    return [ strings count ];
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

- (void) addStrings:(NSArray *)array
{
    NSUInteger numberOfElements = [ array count ];
    for ( NSUInteger i = 0; i < numberOfElements; i++ )
    {
        [ self addString:[ array objectAtIndex:i ]];
    }
}

- (void) addStringList:(NPStringList *)stringList
{
    [ self addStrings:stringList->strings ];
}

- (void) removeStringAtIndex:(NSUInteger)index
{
    [ strings removeObjectAtIndex:index ];
}

- (void) removeStringsAtIndexes:(NSIndexSet *)indexes
{
    [ strings removeObjectsAtIndexes:indexes ];
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
        [ self insertString:[ array objectAtIndex:i ] 
                    atIndex:currentIndex ];

        currentIndex = [ indexes indexGreaterThanIndex:currentIndex ];
    }    
}

- (void) insertStrings:(NSArray *)array atIndex:(NSUInteger)index
{
    NSRange indexRange = NSMakeRange(index, [ array count ]);
    NSIndexSet * indexes = [ NSIndexSet indexSetWithIndexesInRange:indexRange ];
    [ self insertStrings:array atIndexes:indexes ];
}

- (void) insertStringList:(NPStringList *)stringList
                  atIndex:(NSUInteger)index
{
    NSRange indexRange = NSMakeRange(index, [ stringList count ]);
    NSIndexSet * indexes = [ NSIndexSet indexSetWithIndexesInRange:indexRange ];

    [ self insertStrings:stringList->strings atIndexes:indexes ];
}

- (NSString *) stringAtIndex:(NSUInteger)index
{
    return AUTORELEASE([[ strings objectAtIndex:index ] copy ]);
}

- (NPStringList *) stringListInRange:(NSRange)range
{
    NPStringList * result = [ NPStringList stringList ];
    [ result setAllowDuplicates:allowDuplicates ];
    [ result setAllowEmptyStrings:allowEmptyStrings ];
    [ result addStrings:[ strings subarrayWithRange:range ]];

    return result;
}

- (NPStringList *) stringsWithPrefix:(NSString *)prefix
{
    return [ self stringsWithPrefix:prefix
                            indexes:NULL ];
}

- (NPStringList *) stringsWithSuffix:(NSString *)suffix
{
    return [ self stringsWithSuffix:suffix
                            indexes:NULL ];
}

- (NPStringList *) stringsWithPrefix:(NSString *)prefix
                             indexes:(NSIndexSet **)indexes
{
    NSMutableIndexSet * temp = nil;
    if ( indexes != NULL )
    {
        temp = [[ NSMutableIndexSet alloc ] init ];
    }

    NPStringList * result = [ NPStringList stringList ];
    [ result setAllowDuplicates:YES ];
    [ result setAllowEmptyStrings:YES ];

    NSUInteger numberOfStrings = [ strings count ];
    for ( NSUInteger i = 0; i < numberOfStrings; i++ )
    {
        NSString * string = [ strings objectAtIndex:i ];
        if ( [ string hasPrefix:prefix ] == YES )
        {
            [ result addString:string ];

            if ( temp != nil )
            {
                [ temp addIndex:i ];
            }
        }
    }

    if ( indexes != NULL && temp != nil )
    {
        *indexes = [ temp copy ];
        DESTROY(temp);
    }

    return result;
}

- (NPStringList *) stringsWithSuffix:(NSString *)suffix
                             indexes:(NSIndexSet **)indexes
{
    NSMutableIndexSet * temp = nil;
    if ( indexes != NULL )
    {
        temp = [[ NSMutableIndexSet alloc ] init ];
    }

    NPStringList * result = [ NPStringList stringList ];
    [ result setAllowDuplicates:YES ];
    [ result setAllowEmptyStrings:YES ];

    NSUInteger numberOfStrings = [ strings count ];
    for ( NSUInteger i = 0; i < numberOfStrings; i++ )
    {
        NSString * string = [ strings objectAtIndex:i ];
        if ( [ string hasSuffix:suffix ] == YES )
        {
            [ result addString:string ];

            if ( temp != nil )
            {
                [ temp addIndex:i ];
            }
        }
    }

    if ( indexes != NULL && temp != nil )
    {
        *indexes = [ temp copy ];
        DESTROY(temp);
    }

    return result;
}

- (NSUInteger) indexOfFirstStringWithPrefix:(NSString *)prefix
{
    NSUInteger result = NSNotFound;

    NSUInteger numberOfStrings = [ strings count ];
    for ( NSUInteger i = 0; i < numberOfStrings; i++ )
    {
        NSString * string = [ strings objectAtIndex:i ];
        if ( [ string hasPrefix:prefix ] == YES )
        {
            result = i;
            break;
        }
    }

    return result;
}

- (NSUInteger) indexOfFirstStringWithSuffix:(NSString *)suffix
{
    NSUInteger result = NSNotFound;

    NSUInteger numberOfStrings = [ strings count ];
    for ( NSUInteger i = 0; i < numberOfStrings; i++ )
    {
        NSString * string = [ strings objectAtIndex:i ];
        if ( [ string hasSuffix:suffix ] == YES )
        {
            result = i;
            break;
        }
    }

    return result;
}

- (NSUInteger) indexOfLastStringWithPrefix:(NSString *)prefix
{
    NSUInteger result = NSNotFound;

    NSUInteger numberOfStrings = [ strings count ];
    for ( NSUInteger i = 0; i < numberOfStrings; i++ )
    {
        NSString * string = [ strings objectAtIndex:i ];
        if ( [ string hasPrefix:prefix ] == YES )
        {
            result = i;
        }
    }

    return result;
}

- (NSUInteger) indexOfLastStringWithSuffix:(NSString *)suffix
{
    NSUInteger result = NSNotFound;

    NSUInteger numberOfStrings = [ strings count ];
    for ( NSUInteger i = 0; i < numberOfStrings; i++ )
    {
        NSString * string = [ strings objectAtIndex:i ];
        if ( [ string hasSuffix:suffix ] == YES )
        {
            result = i;
        }
    }

    return result;
}

- (NSIndexSet *) indexesOfStringsWithPrefix:(NSString *)prefix
{
    NSIndexSet * result = nil;
    NSMutableIndexSet * temp = [[ NSMutableIndexSet alloc ] init ];

    NSUInteger numberOfStrings = [ strings count ];
    for ( NSUInteger i = 0; i < numberOfStrings; i++ )
    {
        NSString * string = [ strings objectAtIndex:i ];
        if ( [ string hasPrefix:prefix ] == YES )
        {
            [ temp addIndex:i ];
        }
    }

    result = [ temp copy ];
    DESTROY(temp);

    return result;
}

- (NSIndexSet *) indexesOfStringsWithSuffix:(NSString *)suffix
{
    NSIndexSet * result = nil;
    NSMutableIndexSet * temp = [[ NSMutableIndexSet alloc ] init ];

    NSUInteger numberOfStrings = [ strings count ];
    for ( NSUInteger i = 0; i < numberOfStrings; i++ )
    {
        NSString * string = [ strings objectAtIndex:i ];
        if ( [ string hasSuffix:suffix ] == YES )
        {
            [ temp addIndex:i ];
        }
    }

    result = [ temp copy ];
    DESTROY(temp);

    return result;
}


- (void) replaceStringAtIndex:(NSUInteger)index
                   withString:(NSString *)string
{
    [ strings replaceObjectAtIndex:index withObject:string ];
}

- (void) replaceStringsAtIndexes:(NSIndexSet *)indexes
                     withStrings:(NSArray *)array
{
    NSUInteger currentIndex = [ indexes firstIndex ];
    NSUInteger numberOfIndexes = [ indexes count ];

    for (NSUInteger i = 0; i< numberOfIndexes; i++ )
    {
        [ strings replaceObjectAtIndex:currentIndex
                            withObject:[ array objectAtIndex:i ]];

        currentIndex = [ indexes indexGreaterThanIndex:currentIndex ];
    }
}

- (void) replaceStringsAtIndexes:(NSIndexSet *)indexes
                  withStringList:(NPStringList *)stringList
{
    [ self replaceStringsAtIndexes:indexes
                       withStrings:stringList->strings ];
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return YES;
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
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    [ self clear ];

    // check if file is to be found
    NSString * completeFileName
        = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    if ( completeFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    NSStringEncoding encoding;
    NSString * fileContents 
        = [ NSString stringWithContentsOfFile:completeFileName
                                 usedEncoding:&encoding
                                        error:error ];

    // we should check the encoding and convert the string if
    // necessary

    if ( fileContents == nil )
    {
        return NO;
    }

    [ self setName:completeFileName ];
    ASSIGNCOPY(file, completeFileName);

    NSCharacterSet * newlineSet = [ NSCharacterSet newlineCharacterSet ];
    NSScanner * scanner = [ NSScanner scannerWithString:fileContents ];

    // NSScanner is nice and per default skips whitespace and tab,
    // so we do not need to trim the strings as we would have to in case
    // we were using -[NSString componentsSeparatedByCharactersInSet:]
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

