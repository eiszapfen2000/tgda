#import <Foundation/NSScanner.h>
#import "NSString+NPEngine.h"

@implementation NSString ( NPEngine )

- (NSString *) stringByRemovingLeadingAndTrailingQuotes
{
    NSCharacterSet * set = [ NSCharacterSet characterSetWithCharactersInString:@"\"" ];
    
    return [ self stringByTrimmingCharactersInSet:set ];
}

- (NSArray *) literals
{
    NSCharacterSet * empty = [ NSCharacterSet characterSetWithCharactersInString:@"" ];
    NSCharacterSet * separators = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];
    NSCharacterSet * longLiteralMarker = [ NSCharacterSet characterSetWithCharactersInString:@"\"" ];

    return [ self literalsSeparatedBy:separators
          separatorsToStoreAsLiterals:empty
                   longLiteralMarkers:longLiteralMarker
                        ignoreMarkers:empty ];
}

- (NSArray *) literalsSeparatedBy:(NSCharacterSet *)separators
      separatorsToStoreAsLiterals:(NSCharacterSet *)separatorsToStore
               longLiteralMarkers:(NSCharacterSet *)longLiteralMarkers
                    ignoreMarkers:(NSCharacterSet *)ignoreMarkers
{
    NSMutableArray * array = [ NSMutableArray array ];

    NSUInteger stringLength = [ self length ];
    if ( stringLength < 1 )
    {
        return array;
    }

    BOOL separator;
    BOOL separatorToStore;
    BOOL longLiteralMarker;
    BOOL ignoreMarker;
    BOOL insideLongLiteral = NO;
    NSMutableString * currentString = [ NSMutableString string ];
    [ currentString setString:@"" ];
    NSUInteger i = 0;

    do
    {
        unichar character = [ self characterAtIndex:i ];

        separator = [ separators characterIsMember:character ];
        separatorToStore = [ separatorsToStore characterIsMember:character ];
        longLiteralMarker = [ longLiteralMarkers characterIsMember:character ];
        ignoreMarker = [ ignoreMarkers characterIsMember:character ];

        if ( ignoreMarker == YES )
        {
            break;
        }

        if ( longLiteralMarker == YES )
        {
            if ( [ currentString length ] > 0 )
            {
                [ array addObject:[NSString stringWithString:currentString] ];
            }

            [ currentString setString:@"" ];
            insideLongLiteral = !insideLongLiteral;
            separator = YES;
            separatorToStore = NO;
        }

        if ( insideLongLiteral == NO )
        {
            if ((separator == YES) || (separatorToStore == YES))
            {
                if ( [ currentString length ] > 0 )
                {
                    [ array addObject:[NSString stringWithString:currentString] ];
                }

                [ currentString setString:@"" ];
                
                if ( separatorToStore == YES )
                {
                    [ array addObject:[NSString stringWithFormat:@"%C", character] ];
                }
            }
            else
            {
                [ currentString appendFormat:@"%C", character ];
            }
        }
        else
        {
            if ( longLiteralMarker == NO )
            {
                [ currentString appendFormat:@"%C", character ];
            }
        }

        i++;
    }
    while ( i < stringLength );

    if ( [ currentString length ] > 0 )
    {
        [ array addObject:[NSString stringWithString:currentString] ];
    }

    return array;
}

@end

