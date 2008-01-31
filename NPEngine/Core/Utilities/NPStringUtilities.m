#import "NPStringUtilities.h"

NSMutableArray * splitStringUsingCharacterSet(NSString * string, NSCharacterSet * characterset)
{
	NSMutableArray * array = [ [ NSMutableArray alloc ] init ];

	NSString * temp;
	NSScanner * scanner = [ NSScanner scannerWithString:string ];


	while ( [scanner isAtEnd] == NO )
	{
		[ scanner scanUpToCharactersFromSet:characterset intoString:&temp ];
		[ array addObject:temp ];
//		NSLog(temp);
	}

	return array;
}
