#import <AppKit/AppKit.h>

@class TOScene;
@class TOOceanSurface;

@interface TODocument : NSDocument
{
    id glWindowController;
    id rngWindowController;

    TOOceanSurface * oceanSurface;
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

- (TOOceanSurface *) oceanSurface;
- (TOScene *)scene;

@end
