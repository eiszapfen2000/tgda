#import <Foundation/NSArray.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSString.h>

@interface NSString ( NPEngine )

- (NSString *) removeLeadingAndTrailingQuotes;
- (NSArray *) splitUsingCharacterSet:(NSCharacterSet *)characterSet;

@end

