#import <AppKit/AppKit.h>

@class TOOceanSurfaceGenerator;

@interface TOOceanSurfaceGeneratorSettingsWindowController : NSWindowController
{
    id resolutionXTextField;
    id resolutionYTextField;
    id sizeXTextField;
    id sizeYTextField;

    id surfaceGeneratorTypePopUpButton;

    id windXTextField;
    id windYTextField;

    id numberOfThreadsTextField;
    id useCUDARadioButton;

    id rng1TypePopUpButton;
    id rng2TypePopUpButton;
    id rng1SeedTextField;
    id rng2SeedTextField;

    id generateButton;
    id resetButton;

    NSArray * surfaceGeneratorTypeNames;
    NSArray * rngTypeNames;

    NSAlert * resolutionNotPowerOfTwo;
    NSAlert * sizeNegative;
    NSAlert * numberOfThreadsNegative;
    NSAlert * parametersMissing;

    TOOceanSurfaceGenerator * oceanSurfaceGenerator;
}

- init;

- (void) setOceanSurfaceGenerator:(TOOceanSurfaceGenerator *)newOceanSurfaceGenerator;

//actions
- (void) commitResolutionX:(id)sender;
- (void) commitResolutionY:(id)sender;
- (void) commitSizeX:(id)sender;
- (void) commitSizeY:(id)sender;
- (void) commitFSGType:(id)sender;
- (void) commitWindX:(id)sender;
- (void) commitWindY:(id)sender;
- (void) commitFSGType:(id)sender;
- (void) commitNumberOfThreads:(id)sender;

- (void) generate:(id)sender;

@end
