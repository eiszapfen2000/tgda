#import "TOOGLWindowController.h"

@implementation TOOGLWindowController

- init
{
	return  [ super initWithWindowNibName: @"TODocument" ];
}

- (void) windowDidLoad
{
    NSLog(@"didload");

    [ [ NSNotificationCenter defaultCenter ] postNotificationName:@"TOOpenGLWindowContextReady" object:self ];

/*      timer = [NSTimer scheduledTimerWithTimeInterval:0.015
                                               target:self
                                             selector:@selector(doDrawingStuff)
                                             userInfo: nil
                                              repeats: YES ];*/
}

- (void) doDrawingStuff
{
    [ openglView lockFocus ];
    [ openglView drawRect:[openglView frame] ];
    [ openglView unlockFocus ];
}

@end
