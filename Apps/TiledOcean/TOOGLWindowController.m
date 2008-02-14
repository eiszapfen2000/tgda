#import "TOOGLWindowController.h"

@implementation TOOGLWindowController

- init
{
	return  [ super initWithWindowNibName: @"TODocument" ];
}

- (void) windowDidLoad
{
    NSLog(@"didload");

      timer = [NSTimer scheduledTimerWithTimeInterval:0.015
                                               target:self
                                             selector:@selector(doDrawingStuff)
                                             userInfo: nil
                                              repeats: YES ];
}

- (void) doDrawingStuff
{
    [ openglView lockFocus ];
//    [ openglView display ];
    [ openglView drawRect:[openglView frame] ];
    [ openglView unlockFocus ];
}

@end
