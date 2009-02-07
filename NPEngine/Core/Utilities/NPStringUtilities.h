#import <Foundation/Foundation.h>

@interface NSString ( NPEngine )

- (NSString *) removeLeadingAndTrailingQuotes;
- (NSArray *) splitUsingCharacterSet:(NSCharacterSet *)characterSet;

@end

