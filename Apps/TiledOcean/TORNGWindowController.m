#import "TORNGWindowController.h"

@implementation TORNGWindowController

- init
{
	self = [ super initWithWindowNibName: @"TORNGSettingsWindow" ];

    fixedParameterItemNames = [ [ NSArray alloc ] initWithObjects: @"TT800", @"CTG", @"MRG", @"CMRG", nil ];

    return self;
}

- (void) deactivateSeed: (id) sender
{
    NSView * cView = [ [ self window ] contentView ];

    NSView * text = [ cView viewWithTag: 4 ];

    [ text setHidden: YES ];
    [ text setNeedsDisplay: YES ];

    if ( [ text isHidden ] )
    {
            NSLog(@"fgdslfc<");
    }
    
}

- (void) activateSeed: (id) sender
{
    NSLog(@"gga");
}

- (void) addItemsToPopUpButton: (id) popUpButton
{
    NSMenuItem * item;

    for ( UInt i = 0; i < [ fixedParameterItemNames count ]; i++ )
    {
        [ popUpButton addItemWithTitle: [ fixedParameterItemNames objectAtIndex: i ] ];

        item = [ popUpButton itemWithTitle: [ fixedParameterItemNames objectAtIndex: i ] ];

        [ item setTarget: self ];
        [ item setAction: @selector(deactivateSeed:) ];
    }
}

- (void) windowDidLoad
{
    NSView * cView = [ [ self window ] contentView];

    NSPopUpButton * pButton = [ cView viewWithTag: 1 ];

    [ pButton removeAllItems ];

    [ self addItemsToPopUpButton: pButton ];

    pButton = [ cView viewWithTag: 2 ];

    [ pButton removeAllItems ];

    [ self addItemsToPopUpButton: pButton ];
}

@end
