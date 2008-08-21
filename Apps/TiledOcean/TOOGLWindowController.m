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

- (void) dealloc
{
    NSLog(@"oglcontroller dealloc");

    [ super dealloc ];
}

- (TOOpenGLView *) openglView;
{
    return openglView;
}

- (void) windowDidLoad
{
    [[ NSNotificationCenter defaultCenter ] postNotificationName:@"TOOpenGLWindowContextReady" object:self ];
    [[ NSNotificationCenter defaultCenter ] postNotificationName:@"TODocumentCanLoadResources" object:self ];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{

}

@end
