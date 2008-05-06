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

    numberOfThreadsNegative = [[ NSAlert alloc ] init ];
    [ numberOfThreadsNegative setAlertStyle:NSWarningAlertStyle ];
    [ numberOfThreadsNegative setMessageText:@"Number of Threads must be positive" ];
    [ numberOfThreadsNegative addButtonWithTitle:@"OK" ];

    parametersMissing = [[ NSAlert alloc ] init ];
    [ parametersMissing setAlertStyle:NSWarningAlertStyle ];
    [ parametersMissing setMessageText:@"There are parameters missing" ];
    [ parametersMissing addButtonWithTitle:@"OK" ];

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

- (void) commitFSGType:(id)sender
{
    NSLog([ sender titleOfSelectedItem ]);
    [ oceanSurfaceGenerator setCurrentFSGTypeName:[ sender titleOfSelectedItem ] ];
}

- (void) commitWindX:(id)sender
{
    [ oceanSurfaceGenerator setWindX:[sender doubleValue] ];    
}

- (void) commitWindY:(id)sender
{
    [ oceanSurfaceGenerator setWindY:[sender doubleValue] ];
}

- (void) commitNumberOfThreads:(id)sender
{
    NSLog(@"not");
    Int value = [sender intValue];

    if ( value < 1 )
    {
        [ numberOfThreadsNegative runModal ];
        [ numberOfThreadsTextField setStringValue:@"" ];

        return;
    }

    [ oceanSurfaceGenerator setNumberOfThreads:value ];    
}

- (void) generate:(id)sender
{
    if ( [ oceanSurfaceGenerator ready ] == NO )
    {
        [ parametersMissing runModal ];
        return;
    }

    [ oceanSurfaceGenerator generateHeightfield ];
}

@end
