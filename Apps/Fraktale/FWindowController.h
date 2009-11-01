#import <AppKit/NSWindowController.h>
#import "Core/Basics/NpTypes.h"

@interface FWindowController : NSWindowController
{
    // Terrain Stuff
    id lodPopUp;

    id widthTextfield;
    id lengthTextfield;
    id minimumHeightTextfield;
    id maximumHeightTextfield;

    id rngOnePopUp;
    id rngTwoPopUp;
    id rngOneSeedTextfield;
    id rngTwoSeedTextfield;

    id sigmaTextfield;
    id hTextfield;

    id iterationsTextfield;

    // Attractor stuff
    id typePopUp;

    id aTextfield;
    id bTextfield;
    id cTextfield;
    id rTextfield;
    id attractorSigmaTextfield;

    id startingPointXTextfield;
    id startingPointYTextfield;
    id startingPointZTextfield;

    id attractorIterationsTextfield;

    // Buttons on the bottom
    id resetButton;
    id generateButton;
}

- (void) initPopUpButtons;

// Terrain
- (void) setWidthTextfieldString:(NSString *)newString;
- (void) setLengthTextfieldString:(NSString *)newString;
- (void) setMinimumHeightTextfieldString:(NSString *)newString;
- (void) setMaximumHeightTextfieldString:(NSString *)newString;
- (void) setSigmaTextfieldString:(NSString *)newString;
- (void) setHTextfieldString:(NSString *)newString;
- (void) setIterationsTextfieldString:(NSString *)newString;

- (void) addLodPopUpItemWithNumber:(Int32)number;
- (void) removeLodPopUpItemWithNumber:(Int32)number;
- (void) selectLodPopUpItemWithIndex:(Int32)index;

// Attractor
- (void) setATextfieldString:(NSString *)newString;
- (void) setBTextfieldString:(NSString *)newString;
- (void) setCTextfieldString:(NSString *)newString;
- (void) setRTextfieldString:(NSString *)newString;
- (void) setAttractorSigmaTextfieldString:(NSString *)newString;
- (void) setAttractorIterationsTextfieldString:(NSString *)newString;
- (void) setStartingPointXTextfield:(NSString *)newString;
- (void) setStartingPointYTextfield:(NSString *)newString;
- (void) setStartingPointZTextfield:(NSString *)newString;

// Terrain
- (void) selectLod:(id)sender;
- (void) setWidth:(id)sender;
- (void) setLength:(id)sender;
- (void) setMaximumHeight:(id)sender;
- (void) setMinimumHeight:(id)sender;
- (void) selectRngOne:(id)sender;
- (void) selectRngTwo:(id)sender;
- (void) setRngOneSeed:(id)sender;
- (void) setRngTwoSeed:(id)sender;
- (void) setSigma:(id)sender;
- (void) setH:(id)sender;
- (void) setIterations:(id)sender;

// Attractor
- (void) setA:(id)sender;
- (void) setB:(id)sender;
- (void) setC:(id)sender;
- (void) setR:(id)sender;
- (void) setLorentzSigma:(id)sender;
- (void) setStartingPointX:(id)sender;
- (void) setStartingPointY:(id)sender;
- (void) setStartingPointZ:(id)sender;
- (void) setNumberOfIterations:(id)sender;

// Buttons
- (void) reset:(id)sender;
- (void) generate:(id)sender;

@end
