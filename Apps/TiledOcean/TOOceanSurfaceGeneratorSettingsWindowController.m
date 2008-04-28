#import "Core/Math/NpMath.h"

#import "TOOceanSurfaceGeneratorSettingsWindowController.h"
#import "TOOceanSurfaceGenerator.h"
#import "TODocument.h"


@implementation TOOceanSurfaceGeneratorSettingsWindowController

- init
{
	self = [ super initWithWindowNibName: @"TOOceanSurfaceGeneratorSettingsWindow" ];

    surfaceGeneratorTypeNames = [[ NSArray alloc ] initWithObjects:@"Phillips", @"SWOP", @"Piersmos", @"JONSWAP", nil ];
    rngTypeNames = [[ NSArray alloc ] initWithObjects:@"TT800", @"CTG", @"MRG", @"CMRG", nil ];

    resolutionNotPowerOfTwo = [[ NSAlert alloc ] init ];
    [ resolutionNotPowerOfTwo setAlertStyle:NSWarningAlertStyle ];
    [ resolutionNotPowerOfTwo setMessageText:@"Resolution must be a power of 2" ];
    [ resolutionNotPowerOfTwo addButtonWithTitle:@"OK" ];

    sizeNegative = [[ NSAlert alloc ] init ];
    [ sizeNegative setAlertStyle:NSWarningAlertStyle ];
    [ sizeNegative setMessageText:@"Size must be positive" ];
    [ sizeNegative addButtonWithTitle:@"OK" ];

    oceanSurfaceGenerator = nil;

    return self;
}

- (void) setOceanSurfaceGenerator:(TOOceanSurfaceGenerator *)newOceanSurfaceGenerator
{
    if ( oceanSurfaceGenerator != newOceanSurfaceGenerator )
    {
        [ oceanSurfaceGenerator release ];
        oceanSurfaceGenerator = [ newOceanSurfaceGenerator retain ];
    }
}

- (void) addItems:(NSArray *)itemNames toPopUpButton:(id)popUpButton
{
    NSEnumerator * itemNamesEnumerator = [ itemNames objectEnumerator ];
    NSString * itemName;

    while ( ( itemName = [ itemNamesEnumerator nextObject ] ) )
    {
        [ popUpButton addItemWithTitle:itemName ];
    }    
}

- (void) windowDidLoad
{
    [ surfaceGeneratorTypePopUpButton removeAllItems ];
    [ rng1TypePopUpButton removeAllItems ];
    [ rng2TypePopUpButton removeAllItems ];

    [ self addItems:surfaceGeneratorTypeNames toPopUpButton:surfaceGeneratorTypePopUpButton ];
    [ self addItems:rngTypeNames toPopUpButton:rng1TypePopUpButton ];
    [ self addItems:rngTypeNames toPopUpButton:rng2TypePopUpButton ];

    [ surfaceGeneratorTypePopUpButton setPreferredEdge:NSMinYEdge ];
    [ rng1TypePopUpButton setPreferredEdge:NSMinYEdge ];
    [ rng2TypePopUpButton setPreferredEdge:NSMinYEdge ];

    //[[ resolutionXTextField cell ] setSendsActionOnEndEditing:YES ];
    //[[ resolutionYTextField cell ]setSendsActionOnEndEditing:YES ];
    //[[ sizeXTextField cell ] setSendsActionOnEndEditing:YES ];
    //[[ sizeYTextField cell ]setSendsActionOnEndEditing:YES ];

    [ resolutionXTextField setDelegate:self ];
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    NSLog(@"juhu");

    id textMovement;

    textMovement = [[aNotification userInfo] objectForKey: @"NSTextMovement"];

    if (textMovement)
    {
        switch ([(NSNumber *)textMovement intValue])
        {
            case NSReturnTextMovement:
            break;
            case NSTabTextMovement:
            [[aNotification object] sendAction: [[aNotification object] action] to: [[aNotification object] target]];
            break;
            case NSBacktabTextMovement:
            break;
        }
    }
}

- (void) commitResolutionX:(id)sender
{
    Int value = [sender intValue];

    if ( !(IS_INT32_POWER_OF_2(value)) )
    {
        [ resolutionNotPowerOfTwo runModal ];
        [ resolutionXTextField setStringValue:@"" ];

        return;
    }

    [ oceanSurfaceGenerator setResX:value ];
}

- (void) commitResolutionY:(id)sender
{
    Int value = [sender intValue];

    if ( !(IS_INT32_POWER_OF_2(value)) )
    {
        [ resolutionNotPowerOfTwo runModal ];
        [ resolutionYTextField setStringValue:@"" ];

        return;
    }

    [ oceanSurfaceGenerator setResY:value ];
}

- (void) commitSizeX:(id)sender
{
    Int value = [sender intValue];

    if ( value < 0 )
    {
        [ sizeNegative runModal ];
        [ sizeXTextField setStringValue:@"" ];

        return;
    }

    [ oceanSurfaceGenerator setLength:value ];
}

- (void) commitSizeY:(id)sender
{
    Int value = [sender intValue];

    if ( value < 0 )
    {
        [ sizeNegative runModal ];
        [ sizeYTextField setStringValue:@"" ];

        return;
    }

    [ oceanSurfaceGenerator setWidth:value ];
}

- (void) generate:(id)sender
{
    NSLog(@"did it");
    [ oceanSurfaceGenerator generateHeightfield ];
}

@end
