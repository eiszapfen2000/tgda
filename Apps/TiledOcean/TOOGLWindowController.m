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

    /*
    FMatrix2 * m2 = fm2_alloc_init();
    NPLOG(([NSString stringWithFormat:@"%s",fm2_m_to_string(m2)]));

    FMatrix3 * m3 = fm3_alloc_init();
    NPLOG(([NSString stringWithFormat:@"%s",fm3_m_to_string(m3)]));

    FMatrix4 * m4 = fm4_alloc_init();
    NPLOG(([NSString stringWithFormat:@"%s",fm4_m_to_string(m4)]));

    FVector2 * v2 = fv2_alloc_init();
    NPLOG(([NSString stringWithFormat:@"%s",fv2_v_to_string(v2)]));

    FVector3 * v3 = fv3_alloc_init();
    NPLOG(([NSString stringWithFormat:@"%s",fv3_v_to_string(v3)]));

    FVector4 * v4 = fv4_alloc_init();
    NPLOG(([NSString stringWithFormat:@"%s",fv4_v_to_string(v4)]));

    Quaternion * q = quat_alloc_init();
    NPLOG(([NSString stringWithFormat:@"%s",quat_q_to_string(q)]));
    */

    timer = [NSTimer scheduledTimerWithTimeInterval:0.2
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
