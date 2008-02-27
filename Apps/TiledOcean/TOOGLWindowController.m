#import "TOOGLWindowController.h"
#import "TODocument.h"
#import "Core/NPEngineCore.h"

@implementation TOOGLWindowController

- init
{
	return  [ super initWithWindowNibName: @"TODocument" ];
}

- (NPOpenGLView *) openglView;
{
    return openglView;
}

- (void) windowDidLoad
{
//    [ [ NSNotificationCenter defaultCenter ] postNotificationName:@"TOOpenGLWindowContextReady" object:self ];
//    [ [ NSNotificationCenter defaultCenter ] postNotificationName:@"TODocumentCanLoadResources" object:self ];

    if ( [[ NPEngineCore instance ] isReady ] == NO )
    {
        [[ NPEngineCore instance ] setup ];
    }

    [(TODocument *)[ self document ] loadModel ];


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
