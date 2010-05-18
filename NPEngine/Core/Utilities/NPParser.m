#import "NSString+NPEngine.h"
#import "NPParser.h"
#import "NP.h"

@implementation NPParser

- (id) init
{
    return [ self initWithName:@"NPParser" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    [ self setSeparators:[ NSCharacterSet characterSetWithCharactersInString:@" \t,;" ]];
    [ self setSeparatorsToStoreAsLiterals:[ NSCharacterSet characterSetWithCharactersInString:@":,=()[]{}"]];
    [ self setLongLiteralMarkers:[ NSCharacterSet characterSetWithCharactersInString:@"\""]];
    [ self setIgnoreMarkers:[ NSCharacterSet characterSetWithCharactersInString:@"#"]];

    lines = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ self clear ];

    DESTROY(lines);    

    DESTROY(separators);
    DESTROY(separatorsToStoreAsLiterals);
    DESTROY(longLiteralMarkers);
    DESTROY(ignoreMarkers);

    [ super dealloc ];
}

- (void) clear
{
    TEST_RELEASE(script);

    [ lines removeAllObjects ];
}

- (void) setSeparators:(NSCharacterSet *)newSeparators
{
    ASSIGN(separators, newSeparators);
}

- (void) setSeparatorsToStoreAsLiterals:(NSCharacterSet *)newSeparatorsToStoreAsLiterals
{
    ASSIGN(separatorsToStoreAsLiterals, newSeparatorsToStoreAsLiterals);
}

- (void) setLongLiteralMarkers:(NSCharacterSet *)newLongLiteralMarkers
{
    ASSIGN(longLiteralMarkers, newLongLiteralMarkers);
}

- (void) setIgnoreMarkers:(NSCharacterSet *)newIgnoreMarkers
{
    ASSIGN(ignoreMarkers, newIgnoreMarkers);
}

- (NPStringList *) getTokensForLine:(NSUInteger)lineIndex
{
    NSAssert(lineIndex < [ lines count ], @"Index out of bounds");

    return [ lines objectAtIndex:lineIndex ];
}

- (NSString *) getTokenFromLine:(NSUInteger)lineIndex
                     atPosition:(NSUInteger)tokenIndex
{
    NSAssert(lineIndex < [ lines count ], @"Index out of bounds");

    return [[ lines objectAtIndex:lineIndex ] stringAtIndex:tokenIndex ];
}

- (BOOL) getTokenAsString:(NSString **)string 
                 fromLine:(NSUInteger)lineIndex
               atPosition:(NSUInteger)tokenIndex
{
    NPStringList * tokensForLine = [ self getTokensForLine:lineIndex ];

    if ( tokenIndex < [ tokensForLine count ] )
    {
        *string = [[[ tokensForLine stringAtIndex:tokenIndex ] copy ] autorelease ];
        return YES;
    }

    *string = nil;
    return NO;
}

- (BOOL) getTokenAsLowerCaseString:(NSString **)string
                          fromLine:(NSUInteger)lineIndex
                        atPosition:(NSUInteger)tokenIndex
{
    NPStringList * tokensForLine = [ self getTokensForLine:lineIndex ];

    if ( tokenIndex < [ tokensForLine count ] )
    {
        *string = [[ tokensForLine stringAtIndex:tokenIndex ] lowercaseString ];
        return YES;
    }

    *string = nil;
    return NO;
}

- (BOOL) getTokenAsInt:(int *)intValue
              fromLine:(NSUInteger)lineIndex
            atPosition:(NSUInteger)tokenIndex
{
    NPStringList * tokensForLine = [ self getTokensForLine:lineIndex ];

    if ( tokenIndex < [ tokensForLine count ] )
    {
        const char * cString = [[ tokensForLine stringAtIndex:tokenIndex ] cStringUsingEncoding:NSUTF8StringEncoding ];
        
        if ( sscanf(cString, "%d", intValue) == 1 )
        {
            return YES;
        }
    }

    *intValue = 0;
    return NO;
}

- (BOOL) getTokenAsFloat:(float *)floatValue
                fromLine:(NSUInteger)lineIndex
              atPosition:(NSUInteger)tokenIndex
{
    NPStringList * tokensForLine = [ self getTokensForLine:lineIndex ];

    if ( tokenIndex < [ tokensForLine count ] )
    {
        const char * cString = [[ tokensForLine stringAtIndex:tokenIndex ] cStringUsingEncoding:NSUTF8StringEncoding ];
        
        if ( sscanf(cString, "%f", floatValue) == 1 )
        {
            return YES;
        }
    }

    *floatValue = 0.0f;
    return NO;
}

- (BOOL) getTokenAsBool:(BOOL *)boolValue
               fromLine:(NSUInteger)lineIndex
             atPosition:(NSUInteger)tokenIndex
{
    NPStringList * tokensForLine = [ self getTokensForLine:lineIndex ];

    if ( tokenIndex < [ tokensForLine count ] )
    {
        NSArray * trueArray  = [ NSArray arrayWithObjects:@"on", @"true", @"1", nil ];
        NSArray * falseArray = [ NSArray arrayWithObjects:@"off", @"false", @"0", nil ];

        NSString * token = [ tokensForLine stringAtIndex:tokenIndex ];

        if ( [ trueArray containsObject:token ] == YES )
        {
            *boolValue = YES;
            return YES;
        }

        if ( [ falseArray containsObject:token ] == YES )
        {
            *boolValue = NO;
            return YES;
        }
    }

    *boolValue = NO;
    return NO;    
}

- (BOOL) isTokenFromLine:(NSUInteger)lineIndex
              atPosition:(NSUInteger)tokenIndex
           equalToString:(NSString *)string
{
    NSString * token = nil;

    if ( [ self getTokenAsString:&token fromLine:lineIndex atPosition:tokenIndex ] == YES )
    {
        return [ token isEqual:string ];
    }

    return NO;
}

- (BOOL) isLowerCaseTokenFromLine:(NSUInteger)lineIndex
                       atPosition:(NSUInteger)tokenIndex
                    equalToString:(NSString *)string
{
    NSString * token = nil;

    if ( [ self getTokenAsLowerCaseString:&token fromLine:lineIndex atPosition:tokenIndex ] == YES )
    {
        return [ token isEqual:string ];
    }

    return NO;
}


- (void) parse:(NPStringList *)inputScript
{
    if ( inputScript == nil )
    {
        NPLOG_ERROR(@"parse - No inputScript defined");
        return;
    }

    [ self clear ];

    for ( NSUInteger i = 0; i < [ inputScript count ]; i++ )
    {
        NSString * line = [ inputScript stringAtIndex:i ];

        NSArray * literalsForLine = [ line literalsSeparatedBy:separators
                                   separatorsToStoreAsLiterals:separatorsToStoreAsLiterals
                                            longLiteralMarkers:longLiteralMarkers
                                                 ignoreMarkers:ignoreMarkers ];

        if ( [ literalsForLine count ] > 0 )
        {
            NPStringList * literals = [[ NPStringList alloc ] init ];
            [ literals addStringsFromArray:literalsForLine ];
            [ lines addObject:literals ];
            [ literals release ];
        }
    }

    NSLog([lines description]);
}

- (BOOL) loadFromPath:(NSString *)path
{
    TEST_RELEASE(script);
    script = [[ NPStringList alloc ] init ];
    
    return [ script loadFromPath:path ];
}

@end
