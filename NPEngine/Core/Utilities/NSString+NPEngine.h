#import <Foundation/NSArray.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSString.h>

@interface NSString ( NPEngine )

- (NSString *) stringByRemovingLeadingAndTrailingQuotes;

- (NSArray *) literals;
- (NSArray *) literalsSeparatedBy:(NSCharacterSet *)separators
      separatorsToStoreAsLiterals:(NSCharacterSet *)separatorsToStore
               longLiteralMarkers:(NSCharacterSet *)longLiteralMarkers
                    ignoreMarkers:(NSCharacterSet *)ignoreMarkers
                                 ;

@end

