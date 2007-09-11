/* All Rights reserved */

#include <AppKit/AppKit.h>

NSString * TODocumentType = @"TODocumentType";


@interface TODocument : NSDocument
{
}

- (BOOL) loadDataRepresentation:(NSData*)representation ofType:(NSString*)type;

- (NSData*) dataRepresentationOfType: (NSString*)type;

- (void) makeWindowControllers;

@end
