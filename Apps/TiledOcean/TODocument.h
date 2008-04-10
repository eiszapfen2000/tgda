#import <AppKit/AppKit.h>

//#import "TOOceanSurface.h"

@class TOScene;

@interface TODocument : NSDocument
{
    id glWindowController;
    id rngWindowController;

    TOScene * scene;
}

- (id) init;
- (void) dealloc;

- (BOOL) loadDataRepresentation:(NSData*)representation ofType:(NSString*)type;
- (NSData*) dataRepresentationOfType: (NSString*)type;

- (void) setup;

- (void) makeWindowControllers;
- (id) glWindowController;
- (id) rngWindowController;

- (TOScene *)scene;

@end
