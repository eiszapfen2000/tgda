#import <Foundation/NSString.h>
#import <AppKit/NSPopUpButton.h>
#import <AppKit/NSTextField.h>
#import "NP.h"
#import "FCore.h"
#import "FSceneManager.h"
#import "FScene.h"
#import "FTerrain.h"

@implementation FWindowController

- (id) init
{
    return  [ super initWithWindowNibName: @"FAttributesWindow" ];
}

- (void) initPopUpButtons
{
    [ rngOnePopUp removeAllItems ];
    [ rngTwoPopUp removeAllItems ];

    [ rngOnePopUp addItemWithTitle:NP_RNG_TT800 ];
    [ rngTwoPopUp addItemWithTitle:NP_RNG_TT800 ];
    [ rngOnePopUp addItemWithTitle:NP_RNG_CTG ];
    [ rngTwoPopUp addItemWithTitle:NP_RNG_CTG ];
    [ rngOnePopUp addItemWithTitle:NP_RNG_MRG ];
    [ rngTwoPopUp addItemWithTitle:NP_RNG_MRG ];
    [ rngOnePopUp addItemWithTitle:NP_RNG_CMRG ];
    [ rngTwoPopUp addItemWithTitle:NP_RNG_CMRG ];
    [ rngOnePopUp addItemWithTitle:@"mersenne" ];
    [ rngTwoPopUp addItemWithTitle:@"mersenne" ];

    [ lodPopUp removeAllItems ];
    [ lodPopUp setPreferredEdge:NSMinYEdge ];
}

- (void) windowDidLoad
{
    [ self initPopUpButtons ];
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    id textMovement;

    textMovement = [[aNotification userInfo] objectForKey: @"NSTextMovement"];

    if (textMovement)
    {
        switch ([(NSNumber *)textMovement intValue])
        {
            case NSReturnTextMovement:
            break;
            case NSTabTextMovement:
            [[aNotification object] sendAction:[[aNotification object] action] to:[[aNotification object] target]];
            break;
            case NSBacktabTextMovement:
            break;
        }
    }
}

- (void) setWidthTextfieldString:(NSString *)newString
{
    [[ widthTextfield cell ] setStringValue:newString ];
}

- (void) setLengthTextfieldString:(NSString *)newString
{
    [[ lengthTextfield cell ] setStringValue:newString ];
}

- (void) setMinimumHeightTextfieldString:(NSString *)newString
{
    [[ minimumHeightTextfield cell ] setStringValue:newString ];
}

- (void) setMaximumHeightTextfieldString:(NSString *)newString
{
    [[ maximumHeightTextfield cell ] setStringValue:newString ];
}

- (void) setSigmaTextfieldString:(NSString *)newString
{
    [[ sigmaTextfield cell ] setStringValue:newString ];
}

- (void) setHTextfieldString:(NSString *)newString
{
    [[ hTextfield cell ] setStringValue:newString ];
}

- (void) setIterationsTextfieldString:(NSString *)newString
{
    [[ iterationsTextfield cell ] setStringValue:newString ];
}

- (void) addLodPopUpItemWithNumber:(Int32)number
{
    [ lodPopUp addItemWithTitle:[NSString stringWithFormat:@"LOD%d",number]];
}

- (void) removeLodPopUpItemWithNumber:(Int32)number
{
    [ lodPopUp removeItemAtIndex:number ];
}

- (void) selectLodPopUpItemWithIndex:(Int32)index
{
   [ lodPopUp selectItemAtIndex:index ]; 
}

- (void) selectLod:(id)sender
{
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setCurrentLod:[ sender indexOfSelectedItem]];
}

- (void) setWidth:(id)sender
{
    Int32 width = [[ sender cell ] intValue ];

    if ( width < 0 )
    {
        [ sender setBackgroundColor:[NSColor redColor]];
        return;
    }

    [ sender setBackgroundColor:[NSColor whiteColor]];
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setWidth:width ];
}

- (void) setLength:(id)sender
{
    Int32 length = [[ sender cell ] intValue ];

    if ( length < 0 )
    {
        [ sender setBackgroundColor:[NSColor redColor]];
        return;
    }

    [ sender setBackgroundColor:[NSColor whiteColor]];
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setLength:length ];
}

- (void) setMaximumHeight:(id)sender
{
}

- (void) setMinimumHeight:(id)sender
{
}

- (void) selectRngOne:(id)sender
{
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setRngOneUsingName:[sender titleOfSelectedItem]];
}

- (void) selectRngTwo:(id)sender
{
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setRngTwoUsingName:[sender titleOfSelectedItem]];
}

- (void) setRngOneSeed:(id)sender
{
    Int32 seed = [[ sender cell ] intValue ];

    if ( seed < 0 )
    {
        [ sender setBackgroundColor:[NSColor redColor]];
        return;
    }

    [ sender setBackgroundColor:[NSColor whiteColor]];
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setRngOneSeed:(ULong)seed ];
}

- (void) setRngTwoSeed:(id)sender
{
    Int32 seed = [[ sender cell ] intValue ];

    if ( seed < 0 )
    {
        [ sender setBackgroundColor:[NSColor redColor]];
        return;
    }

    [ sender setBackgroundColor:[NSColor whiteColor]];
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setRngTwoSeed:(ULong)seed ];
}

- (void) setSigma:(id)sender
{
    Float sigma = [[ sender cell ] floatValue ];

    if ( sigma <= 0.0f )
    {
        [ sender setBackgroundColor:[NSColor redColor]];
        return;
    }

    [ sender setBackgroundColor:[NSColor whiteColor]];
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setSigma:sigma ];
}

- (void) setH:(id)sender
{
    Float H = [[ sender cell ] floatValue ];

    if ( H <= 0.0f || H > 1.0f )
    {
        [ sender setBackgroundColor:[NSColor redColor]];
        return;
    }

    [ sender setBackgroundColor:[NSColor whiteColor]];
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setH:H ];
}

- (void) setIterations:(id)sender
{
    Int32 iterations = [[ sender cell ] intValue ];

    if ( iterations < 1 )
    {
        [ sender setBackgroundColor:[NSColor redColor]];
        return;
    }

    [ sender setBackgroundColor:[NSColor whiteColor]];
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setIterationsToDo:iterations ];
}

- (void) reset:(id)sender
{
    //NSLog(@"reset");
    [[ NP applicationController ] reloadScene ];
}

- (void) generate:(id)sender
{
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] updateGeometry ];
}

@end

