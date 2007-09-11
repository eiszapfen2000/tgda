#import <AppKit/AppKit.h>

#import "TODocument.h"
#import "TORNGWindowController.h"
#import "TOOGLWindowController.h"


@implementation TODocument

- (BOOL) loadDataRepresentation:(NSData*)representation ofType:(NSString*)type
{
    return NO;
}

- (NSData*) dataRepresentationOfType:(NSString*)type
{
    return nil;
}

- (void) makeWindowControllers
{
	[ self addWindowController: [ [ TOOGLWindowController alloc ] init ] ];

	[ self addWindowController: [ [ TORNGWindowController alloc ] init ] ];
}

@end
