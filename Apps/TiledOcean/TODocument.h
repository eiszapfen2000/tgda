#import <AppKit/AppKit.h>

@class TOScene;
@class TOOceanSurfaceGenerator;

@interface TODocument : NSDocument
{
    id glWindowController;
    id oceanSurfaceGeneratorSettingsWindowController;

    TOOceanSurfaceGenerator * oceanSurfaceGenerator;
    TOScene * scene;
}

- (id) init;
- (void) dealloc;

- (BOOL) loadDataRepresentation:(NSData*)representation ofType:(NSString*)type;
- (NSData*) dataRepresentationOfType: (NSString*)type;

- (void) setup;

- (void) makeWindowControllers;
- (id) glWindowController;
- (id) oceanSurfaceGeneratorSettingsWindowController;

- (TOOceanSurfaceGenerator *) oceanSurfaceGenerator;
- (TOScene *)scene;

- (void) oceanSurfaceGenerationDidEnd:(NSNotification *)aNot;

@end
