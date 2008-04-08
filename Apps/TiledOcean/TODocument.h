#import <AppKit/AppKit.h>

//#import "TOOceanSurface.h"

@class NPSUXModel;

@interface TODocument : NSDocument
{
    id glWindowController;
    id rngWindowController;

    BOOL modelLoaded;
    NPSUXModel * model;
}

- (id) init;

- (BOOL) loadDataRepresentation:(NSData*)representation ofType:(NSString*)type;
- (NSData*) dataRepresentationOfType: (NSString*)type;

- (void) makeWindowControllers;
- (id) glWindowController;
- (id) rngWindowController;

- (void) loadModel:(NSNotification *)aNot;
- (void) loadModel;

@end
