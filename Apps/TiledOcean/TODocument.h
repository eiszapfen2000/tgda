#import <AppKit/AppKit.h>

#import "TOOceanSurface.h"

NSString * TODocumentType = @"TODocumentType";


@interface TODocument : NSDocument
{
	id mOceanSurface;
}

- (BOOL) loadDataRepresentation:(NSData*)representation ofType:(NSString*)type;

- (NSData*) dataRepresentationOfType: (NSString*)type;

- (void) makeWindowControllers;

@end
