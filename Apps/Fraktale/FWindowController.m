#import <Foundation/NSString.h>
#import <AppKit/NSPopUpButton.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSTabViewItem.h>
#import <AppKit/NSTabView.h>
#import "NP.h"
#import "FCore.h"
#import "FSceneManager.h"
#import "FScene.h"
#import "FTerrain.h"
#import "FAttractor.h"

@implementation FWindowController

- (id) init
{
    return [ super initWithWindowNibName:@"FAttributesWindow" ];
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
    [ rngOnePopUp addItemWithTitle:NP_RNG_MERSENNE ];
    [ rngTwoPopUp addItemWithTitle:NP_RNG_MERSENNE ];

    [ lodPopUp removeAllItems ];
    [ lodPopUp setPreferredEdge:NSMinYEdge ];

    [ typePopUp removeAllItems ];
    [ typePopUp setPreferredEdge:NSMinYEdge ];
    [ typePopUp addItemWithTitle:@"Lorentz"  ];
    [ typePopUp addItemWithTitle:@"Roessler" ];
}

- (void) awakeFromNib
{
    [ self initPopUpButtons ];
    [ tabView selectFirstTabViewItem:self ];
}

- (void) initialiseSettingsUsingDictionary:(NSDictionary *)dictionary
{
    // Terrain stuff
    NSDictionary * terrainConfig = [ dictionary objectForKey:@"Terrain" ];

    [[ minimumHeightTextfield cell ] setStringValue:[ terrainConfig objectForKey:@"MinimumHeight" ]];
    [[ maximumHeightTextfield cell ] setStringValue:[ terrainConfig objectForKey:@"MaximumHeight" ]];

    [[ sigmaTextfield cell ] setStringValue:[ terrainConfig objectForKey:@"Sigma" ]];
    [[ hTextfield cell ] setStringValue:[ terrainConfig objectForKey:@"H" ]];
    [[ iterationsTextfield cell ] setStringValue:[ terrainConfig objectForKey:@"Iterations" ]];

    NSArray * terrainSizeStrings = [ terrainConfig objectForKey:@"Size" ];
    [[ widthTextfield  cell ] setStringValue:[ terrainSizeStrings objectAtIndex:0 ]];
    [[ lengthTextfield cell ] setStringValue:[ terrainSizeStrings objectAtIndex:1 ]];

    // Attractor stuff
    NSDictionary * attractorConfig = [ dictionary objectForKey:@"Attractor" ];
    NSDictionary * lorentzConfig   = [ attractorConfig objectForKey:@"Lorentz"  ];
    NSDictionary * roesslerConfig  = [ attractorConfig objectForKey:@"Roessler" ];

    [[ attractorSigmaTextfield cell ] setStringValue:[ lorentzConfig objectForKey:@"Sigma" ]];
    [[ rTextfield cell ] setStringValue:[ lorentzConfig objectForKey:@"R" ]];
    [[ bTextfield cell ] setStringValue:[ lorentzConfig objectForKey:@"B" ]];
    bLorentzValue = [[ lorentzConfig objectForKey:@"B" ] doubleValue ];

    [[ aTextfield cell ] setStringValue:[ roesslerConfig objectForKey:@"A" ]];
    [[ bTextfield cell ] setStringValue:[ roesslerConfig objectForKey:@"B" ]];
    [[ cTextfield cell ] setStringValue:[ roesslerConfig objectForKey:@"C" ]];
    bRoesslerValue = [[ roesslerConfig objectForKey:@"B" ] doubleValue ];

    NSArray * startingPointStrings = [ attractorConfig objectForKey:@"StartingPoint" ];
    [[ startingPointXTextfield cell ] setStringValue:[ startingPointStrings objectAtIndex:0 ]];
    [[ startingPointYTextfield cell ] setStringValue:[ startingPointStrings objectAtIndex:1 ]];
    [[ startingPointZTextfield cell ] setStringValue:[ startingPointStrings objectAtIndex:2 ]];

    [[ attractorIterationsTextfield cell ] setStringValue:[ attractorConfig objectForKey:@"Iterations" ]];

    [ typePopUp sendAction:[typePopUp action] to:[typePopUp target]];
    [ tabView selectFirstTabViewItem:self ];
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    id textMovement = [[aNotification userInfo] objectForKey: @"NSTextMovement"];

    if (textMovement)
    {
        switch ([(NSNumber *)textMovement intValue])
        {
            case NSReturnTextMovement:
            {
                break;
            }

            case NSTabTextMovement:
            {
                [[aNotification object] sendAction:[[aNotification object] action] to:[[aNotification object] target]];
                break;
            }

            case NSBacktabTextMovement:
            {
                break;
            }
        }
    }
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ( [[ tabViewItem label ] isEqual:@"Terrain" ] == YES )
    {
        [[[ NP applicationController ] scene ] setActiveScene:FSCENE_DRAW_TERRAIN ];
    }
    else if ( [[ tabViewItem label ] isEqual:@"Attractor" ] == YES )
    {
        [[[ NP applicationController ] scene ] setActiveScene:FSCENE_DRAW_ATTRACTOR ];
    }
    else
    {
        NSLog(@"KABUMM");
    }
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
    [[[[ NP applicationController ] scene ] terrain ] setCurrentLod:[ sender indexOfSelectedItem ]];
}

/*- (void) setWidth:(id)sender
{
    Int32 width = [[ sender cell ] intValue ];

    if ( width < 0 )
    {
        [ sender setBackgroundColor:[NSColor redColor]];
        return;
    }

    [ sender setBackgroundColor:[NSColor whiteColor]];
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setWidth:width ];
}*/

/*- (void) setLength:(id)sender
{
    Int32 length = [[ sender cell ] intValue ];

    if ( length < 0 )
    {
        [ sender setBackgroundColor:[NSColor redColor]];
        return;
    }

    [ sender setBackgroundColor:[NSColor whiteColor]];
    [[[[[ NP applicationController ] sceneManager ] currentScene ] terrain ] setLength:length ];
}*/

/*
- (void) setMaximumHeight:(id)sender
{
}

- (void) setMinimumHeight:(id)sender
{
}
*/

- (void) selectRngOne:(id)sender
{
    [[[[ NP applicationController ] scene ] terrain ] setRngOneUsingName:[sender titleOfSelectedItem]];
}

- (void) selectRngTwo:(id)sender
{
    [[[[ NP applicationController ] scene ] terrain ] setRngTwoUsingName:[sender titleOfSelectedItem]];
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
    [[[[ NP applicationController ] scene ] terrain ] setRngOneSeed:(ULong)seed ];
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
    [[[[ NP applicationController ] scene ] terrain ] setRngTwoSeed:(ULong)seed ];
}

/*
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
}*/

- (void) selectAttractorType:(id)sender
{
    FAttractor * attractor = [[[ NP applicationController ] scene ] attractor ];
    Int32 index = [ sender indexOfSelectedItem];

    if ( index == ATTRACTOR_LORENTZ )
    {
        // Lorentz
        [ aTextfield setEditable:NO ];
        [ cTextfield setEditable:NO ];
        [ aTextfield setBackgroundColor:[NSColor grayColor]];
        [ cTextfield setBackgroundColor:[NSColor grayColor]];

        [ rTextfield setEditable:YES ];
        [ attractorSigmaTextfield setEditable:YES ];
        [ rTextfield setBackgroundColor:[NSColor whiteColor]];
        [ attractorSigmaTextfield setBackgroundColor:[NSColor whiteColor]];

        if ( [ attractor mode ] == ATTRACTOR_ROESSLER )
        {
            bRoesslerValue = [[ bTextfield cell ] doubleValue ];
        }

        [[ bTextfield cell ] setDoubleValue:bLorentzValue ];

        [ attractor setMode:ATTRACTOR_LORENTZ ];
    }

    if ( index == ATTRACTOR_ROESSLER )
    {
        // Rössler
        [ rTextfield setEditable:NO ];
        [ attractorSigmaTextfield setEditable:NO ];
        [ rTextfield setBackgroundColor:[NSColor grayColor]];
        [ attractorSigmaTextfield setBackgroundColor:[NSColor grayColor]];

        [ aTextfield setEditable:YES ];
        [ cTextfield setEditable:YES ];
        [ aTextfield setBackgroundColor:[NSColor whiteColor]];
        [ cTextfield setBackgroundColor:[NSColor whiteColor]];

        if ( [ attractor mode ] == ATTRACTOR_LORENTZ )
        {
            bLorentzValue = [[ bTextfield cell ] doubleValue ];
        }

        [[ bTextfield cell ] setDoubleValue:bRoesslerValue ];

        [ attractor setMode:ATTRACTOR_ROESSLER ];
    }
}

- (void) reset:(id)sender
{
    [[ NP applicationController ] reloadScene ];
}

- (void) generate:(id)sender
{
    NSString * tabViewItemLabel = [[ tabView selectedTabViewItem ] label ];

    if ( [ tabViewItemLabel isEqual:@"Terrain" ] )
    {
        FTerrain * terrain = [[[ NP applicationController ] scene ] terrain ];

        Int32 width  = [ widthTextfield  intValue ];
        Int32 length = [ lengthTextfield intValue ];
        Float sigma = [ sigmaTextfield floatValue];
        Float H = [ hTextfield floatValue];
        Float minimumHeight = [ minimumHeightTextfield floatValue ];
        Float maximumHeight = [ maximumHeightTextfield floatValue ];
        UInt32 numberOfIterations = (UInt32)[ iterationsTextfield intValue ];

        [ terrain updateGeometryUsingSize:(IVector2){width, length}
                              heightRange:(FVector2){minimumHeight, maximumHeight}
                                    sigma:sigma
                                        H:H
                       numberOfIterations:numberOfIterations ];
    }
    // Just to be sure
    else if ( [ tabViewItemLabel isEqual:@"Attractor" ] )
    {
        FAttractor * attractor = [[[ NP applicationController ] scene ] attractor ];

        Int32 type = [ typePopUp indexOfSelectedItem];
        Float sigma = [attractorSigmaTextfield floatValue];
        Float a = [aTextfield floatValue];
        Float b = [bTextfield floatValue];
        Float c = [cTextfield floatValue];
        Float r = [rTextfield floatValue];

        UInt32 numberOfIterations = [ attractorIterationsTextfield intValue ];

        FVector3 startingPoint;
        startingPoint.x = [ startingPointXTextfield floatValue ];
        startingPoint.y = [ startingPointYTextfield floatValue ];
        startingPoint.z = [ startingPointZTextfield floatValue ];

        //NSLog(@"%f %f %f %f %f %u %f %f %f", a, b, c, sigma, r,
        //         numberOfIterations, startingPoint.x, startingPoint.y, startingPoint.z);

        [ attractor generateAttractorOfType:type
                            withParametersA:a
                                          B:b
                                          C:c
                                          R:r
                                      Sigma:sigma
                         numberOfIterations:numberOfIterations
                              startingPoint:startingPoint ];
    }
}

@end

