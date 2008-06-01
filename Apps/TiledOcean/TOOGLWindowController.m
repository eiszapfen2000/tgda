#import "TOOGLWindowController.h"
#import "TODocument.h"
#import "TOOpenGLView.h"
#import "Core/NPEngineCore.h"
#import "Core/Math/NpMath.h"

@implementation TOOGLWindowController

- init
{
	return  [ super initWithWindowNibName: @"TODocument" ];
}

- (TOOpenGLView *) openglView;
{
    return openglView;
}

- (void) windowDidLoad
{
    [[ NSNotificationCenter defaultCenter ] postNotificationName:@"TOOpenGLWindowContextReady" object:self ];
    [[ NSNotificationCenter defaultCenter ] postNotificationName:@"TODocumentCanLoadResources" object:self ];
    //[(TODocument *)[ self document ] setup ];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{

}

@end
