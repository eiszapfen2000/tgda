#import <AppKit/AppKit.h>

#import "TOOceanSurface.h"

//NSString * TODocumentType = @"TODocumentType";


@interface TODocument : NSDocument
{
	id mOceanSurface;

    id glWindowController;
    id rngWindowController;
}

- (id) init;

- (BOOL) loadDataRepresentation:(NSData*)representation ofType:(NSString*)type;
- (NSData*) dataRepresentationOfType: (NSString*)type;

- (void) makeWindowControllers;
- (id) glWindowController;
- (id) rngWindowController;

@end
