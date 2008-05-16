//#import <GL/gl.h>
#import "TOOpenGLView.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Camera/NPCamera.h"
#import "Graphics/Camera/NPCameraManager.h"


@implementation TOOpenGLView


- (id)initWithFrame:(NSRect) frameRect
{
    self = [ super initWithFrame:frameRect ];

    glReady = NO;

    rotY = 0.0f;

    return self;
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSLog(@"keydown");

    NSString *theArrow = [theEvent charactersIgnoringModifiers];
    unichar keyChar = 0;

    if ( [theArrow length] == 0 )
        return;

    if ( [theArrow length] == 1 )
    {
        keyChar = [theArrow characterAtIndex:0];

        if ( keyChar == NSLeftArrowFunctionKey )
        {
            NSLog(@"left");
            rotY += 10.0f;
            [[[[ NPEngineCore instance ] cameraManager ] currentActiveCamera ] rotateY:rotY ];
        }

        if ( keyChar == NSRightArrowFunctionKey )
        {
            NSLog(@"right");
        }

        if ( keyChar == NSUpArrowFunctionKey )
        {
            NSLog(@"up");
        }

        if ( keyChar == NSDownArrowFunctionKey )
        {
            NSLog(@"down");
        }
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"mouseDown");
}

- (void)mouseUp:(NSEvent *)theEvent
{
    NSLog(@"mouseUp");
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSLog(@"dragster");
}

- (void) setupGLState
{
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);

    glClearDepth(1.0f);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_DEPTH_TEST);

    glCullFace(GL_BACK);
    glEnable(GL_CULL_FACE);

    glEnable(GL_TEXTURE_2D);

    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);

    glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
}

- (void) drawRect:(NSRect)aRect
{
    NSLog(@"drawrect");
    NPOpenGLRenderContext * ctx = [ self renderContext];

    if( [ ctx context ] != [NSOpenGLContext currentContext] )
    {
        [ renderContext activate ];
    }

    if ( glReady == NO )
    {
        [ self setupGLState ];
        glReady = YES;
    }

    //[ self update ];
    //[ self reshape ];

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [[self renderContext] swap];
}

- (void) reshape
{
    NSRect fr_rect = [self frame];
    GLint height = (GLint)fr_rect.size.height;
    GLint width =  (GLint)fr_rect.size.width;

    glViewport(0, 0, width, height);
}

@end
