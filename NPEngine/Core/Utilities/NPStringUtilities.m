#import "NPStringUtilities.h"

@implementation NSString ( NPEngine )

- (NSString *) removeLeadingAndTrailingQuotes
{
    NSRange range;
    range.location = 0;
    range.length = [ self length ];

    if ( [ self characterAtIndex:0 ] == '"' )
    {
        range.location = 1; //skip first character
        range.length = range.length - 1;
    }

    if ( [ self characterAtIndex:([ self length ] - 1) ] == '"' )
    {
        range.length = range.length - 1; //skip last character
    } 

    return [ self substringWithRange:range ];
}

- (NSArray *) splitUsingCharacterSet:(NSCharacterSet *)characterSet
{
	NSString * temp;
	NSMutableArray * array = [[ NSMutableArray alloc ] init ];
	NSScanner * scanner = [ NSScanner scannerWithString:self ];

	while ( [scanner isAtEnd] == NO )
	{
		if ( [ scanner scanUpToCharactersFromSet:characterSet intoString:&temp ] == YES )
        {
		    [ array addObject:temp ];
        }
	}

	return [ array autorelease ];
}

@end

