#import <AppKit/NSWindowController.h>
#import "Core/Basics/NpTypes.h"

@interface FWindowController : NSWindowController
{
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

    id generateButton;
}

- (void) setWidthTextfieldString:(NSString *)newString;
- (void) setLengthTextfieldString:(NSString *)newString;
- (void) setMinimumHeightTextfieldString:(NSString *)newString;
- (void) setMaximumHeightTextfieldString:(NSString *)newString;
- (void) setSigmaTextfieldString:(NSString *)newString;
- (void) setHTextfieldString:(NSString *)newString;
- (void) setIterationsTextfieldString:(NSString *)newString;

- (void) addLodPopUpItemWithNumber:(Int32)number;
- (void) selectLodPopUpItemWithIndex:(Int32)index;

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
- (void) generate:(id)sender;

@end
