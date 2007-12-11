#import <AppKit/AppKit.h>

#import "Core/Basics/Types.h"

@interface TORNGWindowController : NSWindowController
{
    NSArray * fixedParameterRNGItemNames;
    NSArray * oneParameterRNGItemNames;

    NSPopUpButton * rngPopUpButtonLeft;
    NSPopUpButton * rngPopUpButtonRight;

    NSTextField * seedTextFieldLeft;
    NSTextField * seedTextFieldRight;
}
- init;

@end
