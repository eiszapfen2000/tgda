//#import <GL/gl.h>
#import "TOOpenGLView.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"
#import "Graphics/Model/NPVertexBuffer.h"
#import "Core/NPEngineCore.h"
//#import "Graphics/Camera/NPCamera.h"
//#import "Graphics/Camera/NPCameraManager.h"
#import "TOCamera.h"
#import "TOScene.h"


@implementation TOOpenGLView


- (id)initWithFrame:(NSRect) frameRect
{
    self = [ super initWithFrame:frameRect ];

    [[ NSNotificationCenter defaultCenter ] addObserver:self
                                               selector:@selector(setup:)
                                                   name:@"TODocumentCanLoadResources"
                                                 object:nil];

    scene = [[ TOScene alloc ] init ];

    glStateInitialised = NO;
    rotY = 0.0f;

    reference.x = reference.y = 0.0f;

    return self;
}

- (void) setup:(NSNotification *)aNot
{
    [ scene setup ];

    timer = [ NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                              target:self
                                            selector:@selector(updateAndRender:)
                                            userInfo:nil
                                             repeats:YES ];
}

- (void) updateAndRender:(NSTimer *)theTimer
{
    [ scene update ];

    NPOpenGLRenderContext * ctx = [ self renderContext];

    /*if( [ ctx context ] != [NSOpenGLContext currentContext] )
    {
        [ renderContext activate ];
    }*/

    [ scene render ];

    GLenum error = glGetError();

    if ( error != GL_NO_ERROR )
    {NSLog(@"%s",gluErrorString(error));}

    [ ctx swap ];
    //NSLog(@"swap");
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
            [[scene camera] cameraRotateUsingYaw:0.2 andPitch:0.0];
        }

        if ( keyChar == NSRightArrowFunctionKey )
        {
            [[scene camera] cameraRotateUsingYaw:-0.2 andPitch:0.0];
        }

        if ( keyChar == NSUpArrowFunctionKey )
        {
            [[scene camera] moveForward ];
        }

        if ( keyChar == NSDownArrowFunctionKey )
        {
            [[scene camera] moveBackward ];
        }
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"mouseDown");

    if ( [ theEvent type ] == NSLeftMouseDown )
    {
        NSPoint eventLocation = [theEvent locationInWindow];
        reference = [self convertPoint:eventLocation fromView:nil];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    NSLog(@"mouseUp");
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if ( [ theEvent type ] == NSLeftMouseDragged )
    {
        //NSLog(@"dragster");
        NSPoint event_location = [theEvent locationInWindow];
        NSPoint local_point = [self convertPoint:event_location fromView:nil];
        //NSLog(@"%f %f",local_point.x,local_point.y);

        Float deltaX = local_point.x - reference.x;
        Float deltaY = local_point.y - reference.y;

        NSLog(@"%f %f",deltaX,deltaY);

        //[[scene camera] rotateY:deltaX*0.2 ];
        //[[ scene camera ] rotateX:deltaY*0.2 ];
        [[scene camera] cameraRotateUsingYaw:-deltaX*0.2 andPitch:deltaY*0.2];

        reference = local_point;
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	NSLog(@"mouse moved");
}

- (void) setupGLState
{
    glClearColor(0.0f, 1.0f, 0.0f, 0.0f);

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

    /*if( [ ctx context ] != [NSOpenGLContext currentContext] )
    {
        [ renderContext activate ];
    }*/

    if ( glStateInitialised == NO )
    {
        [ self setupGLState ];
        glStateInitialised = YES;
    }

    //[ self update ];
    //[ self reshape ];

    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //[[self renderContext] swap];
}

- (void) reshape
{
    NSLog(@"reshape");
    NSRect fr_rect = [self frame];
    GLint height = (GLint)fr_rect.size.height;
    GLint width =  (GLint)fr_rect.size.width;

    Float aspectRatio = (Float)width/(Float)height;
    [[ scene camera ] setAspectRatio:aspectRatio ];

    glViewport(0, 0, width, height);
}

- (TOScene *) scene
{
    return scene;
}

- (void) buildVBOUsingVertexArray:(Float *)vertexArray
                       indexArray:(Int *)indexArray
                        maxVertex:(Int)maxVertex
                         maxIndex:(Int)maxIndex
{
    NPVertexBuffer * vbo = [ scene surfaceVBO ];
    [ vbo setPositions:vertexArray ];
    [ vbo setIndices:indexArray ];
    [ vbo setIndexed:YES ];
    [ vbo setMaxVertex:maxVertex ];
    [ vbo setMaxIndex:maxIndex ];
    [ vbo setPrimitiveType:NP_VBO_PRIMITIVES_TRIANGLES ];
    [ vbo setReady:YES ];

    [ vbo uploadVBOWithUsageHint:NP_VBO_UPLOAD_ONCE_RENDER_OFTEN ];
}

@end
