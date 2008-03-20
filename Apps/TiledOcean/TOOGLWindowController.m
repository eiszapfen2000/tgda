#import "TOOGLWindowController.h"
#import "TODocument.h"
#import "TOOpenGLView.h"
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

    //[(TODocument *)[ self document ] loadModel ];
    [(TOOpenGLView *)openglView loadModel ];

    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                               target:self
                                             selector:@selector(doDrawingStuff)
                                             userInfo: nil
                                              repeats: YES ];
    NSLog(@"windwodidload");
}

- (void) doDrawingStuff
{
    [ openglView lockFocus ];

    

    [ (TOOpenGLView *)openglView drawModel ];

    [ openglView unlockFocus ];
}

@end
