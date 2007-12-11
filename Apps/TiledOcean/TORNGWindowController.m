#import "TORNGWindowController.h"
#import "Core/File/NPURLDownload.h"

@implementation TORNGWindowController

- init
{
	self = [ super initWithWindowNibName: @"TORNGSettingsWindow" ];

    fixedParameterRNGItemNames = [ [ NSArray alloc ] initWithObjects: @"TT800", @"CTG", @"MRG", @"CMRG", nil ];
    oneParameterRNGItemNames = [ [ NSArray alloc ] initWithObjects: @"Mersenne Twister", nil ];

    return self;
}

- (void) deactivateSeed: (id) sender
{
    if ( [ rngPopUpButtonLeft menu ] == [ sender menu ] )
    {
        [ seedTextFieldLeft setSelectable: NO ];
        [ seedTextFieldLeft setEditable: NO ];
        [ seedTextFieldLeft setTextColor: [ NSColor grayColor ] ];
    }
    else if ( [ rngPopUpButtonRight menu ] == [ sender menu ] )
    {
        [ seedTextFieldRight setSelectable: NO ];
        [ seedTextFieldRight setEditable: NO ];
        [ seedTextFieldRight setTextColor: [ NSColor grayColor ] ];
    }
}

- (void) activateSeed: (id) sender
{
    if ( [ rngPopUpButtonLeft menu ] == [ sender menu ] )
    {
        [ seedTextFieldLeft setSelectable: YES ];
        [ seedTextFieldLeft setEditable: YES ];
        [ seedTextFieldLeft setTextColor: [ NSColor blackColor ] ]; 
    }
    else if ( [ rngPopUpButtonRight menu ] == [ sender menu ] )
    {
        [ seedTextFieldRight setSelectable: YES ];
        [ seedTextFieldRight setEditable: YES ];
        [ seedTextFieldRight setTextColor: [ NSColor blackColor ] ];
    }
}

- (void) addItemsToPopUpButton: (id) popUpButton
{
    NSMenuItem * item;

    for ( UInt i = 0; i < [ fixedParameterRNGItemNames count ]; i++ )
    {
        [ popUpButton addItemWithTitle: [ fixedParameterRNGItemNames objectAtIndex: i ] ];

        item = [ popUpButton itemWithTitle: [ fixedParameterRNGItemNames objectAtIndex: i ] ];

        [ item setTarget: self ];
        [ item setAction: @selector(deactivateSeed:) ];
    }

    for ( UInt i = 0; i < [ oneParameterRNGItemNames count ]; i++ )
    {
        [ popUpButton addItemWithTitle: [ oneParameterRNGItemNames objectAtIndex: i ] ];

        item = [ popUpButton itemWithTitle: [ oneParameterRNGItemNames objectAtIndex: i ] ];

        [ item setTarget: self ];
        [ item setAction: @selector(activateSeed:) ];
    }

    
}

- (void) windowDidLoad
{
    [ rngPopUpButtonLeft removeAllItems ];

    [ self addItemsToPopUpButton: rngPopUpButtonLeft ];

    [ rngPopUpButtonRight removeAllItems ];

    [ self addItemsToPopUpButton: rngPopUpButtonRight ];
}

@end
