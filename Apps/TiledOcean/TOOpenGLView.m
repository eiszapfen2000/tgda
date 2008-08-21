#import "TOOpenGLView.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"
#import "Graphics/Model/NPVertexBuffer.h"
#import "Graphics/RenderTarget/NPRenderBuffer.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/Material/NPTexture.h"
#import "Core/NPEngineCore.h"
#import "TOCamera.h"
#import "TOScene.h"

#import <GNUstepGUI/GSDisplayServer.h>

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
    rotz = 0.2f;

    reference.x = reference.y = 0.0f;

    return self;
}

- (void) dealloc
{
    NSLog(@"glview dealloc");
    [ scene release ];

    [ super dealloc ];
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
    NPOpenGLRenderContext * ctx = [ self renderContext];

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    /*glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glRotatef(rotz,0.0f,0.0f,1.0f);

    glBegin(GL_TRIANGLES);
        glColor3f(1.0f,0.0f,0.0f);
        //glTexCoord2f(0.0f,0.0f);
        glVertex2f(-1.0f,0.0f);
        //glTexCoord2f(1.0f,0.0f);
        glVertex2f(1.0f,0.0f);
        //glTexCoord2f(0.5f,1.0f);
        glVertex2f(0.0f,1.0f);
    glEnd();

    rotz += 0.2f;*/

    [ scene update ];
    [ scene render ];

    GLenum error = glGetError();

    if ( error != GL_NO_ERROR )
    {NSLog(@"%s",gluErrorString(error));}

    [ ctx swap ];
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
    glXSwapIntervalSGI(1);

    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);

    glClearDepth(1.0f);
    glDepthFunc(GL_LEQUAL);
    //glEnable(GL_DEPTH_TEST);

    //glCullFace(GL_BACK);
    //glEnable(GL_CULL_FACE);

    glEnable(GL_TEXTURE_2D);
    glEnable(GL_MULTISAMPLE_ARB);

    //glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);

    [ self reshape ];
}

- (void) drawRect:(NSRect)aRect
{
    NSLog(@"drawrect");
    NPOpenGLRenderContext * ctx = [ self renderContext];

    if ( glStateInitialised == NO )
    {
        [ self setupGLState ];
        glStateInitialised = YES;
    }
}

- (void) reshape
{
    NSLog(@"reshape");
    NSRect fr_rect = [self frame];
    GLint height = (GLint)fr_rect.size.height;
    GLint width =  (GLint)fr_rect.size.width;

    NSLog(@"%d %d",width,height);

    Float aspectRatio = (Float)width/(Float)height;
    //[[ scene camera ] setAspectRatio:aspectRatio ];

    glViewport(0, 0, width, height);

    NSWindow * brak = [ self window ];
    GSDisplayServer * server = GSServerForWindow(brak);
    NSRect bounds = [ server windowbounds:[brak windowNumber ]];
    NSLog(@"%f %f %f %f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);

    NSRect rect;
    if ([server handlesWindowDecorations] == YES)
    {
      /* The window manager handles window decorations, so the
       * the parent X window is equal to the content view and
       * we must therefore use content view coordinates.
       */
      rect = [self convertRect: [self bounds]
                   toView: [[self window] contentView]];
    }
    else
    {
      /* The GUI library handles window decorations, so the
       * the parent X window is equal to the NSWindow frame
       * and we can use window base coordinates.
       */
      rect = [self convertRect: [self bounds] toView: nil];
    }

    NSLog(@"%f %f %f %f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);

    //gswindow_device_t *win_info = [server _windowWithTag:[brak windowNumber]];
    float x = NSMinX(rect);
    //float y = NSHeight(win_info->xframe) - NSMaxY(rect);
    float xwidth = NSWidth(rect);
    float xheight = NSHeight(rect);
    NSLog(@"%f %f %f",x,xwidth,xheight);
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
