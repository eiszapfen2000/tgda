#import "NPStringUtilities.h"

NSString * removeLeadingAndTrailingQuotes(NSString * string)
{
    NSRange range;
    range.location = 0;
    range.length = [ string length ];

    if ( [ string characterAtIndex:0 ] == '"' )
    {
        range.location = 1; //skip first character
        range.length = range.length - 1;
    }

    if ( [ string characterAtIndex:([ string length ] - 1) ] == '"' )
    {
        range.length = range.length - 1; //skip last character
    } 

    return [ string substringWithRange:range ];
}

NSMutableArray * splitStringUsingCharacterSet(NSString * string, NSCharacterSet * characterset)
{
	NSString * temp;
	NSMutableArray * array = [ [ NSMutableArray alloc ] init ];
	NSScanner * scanner = [ NSScanner scannerWithString:string ];

	while ( [scanner isAtEnd] == NO )
	{
		if ( [ scanner scanUpToCharactersFromSet:characterset intoString:&temp ] == YES )
        {
		    [ array addObject:temp ];
        }
	}

	return [ array autorelease ];
}
