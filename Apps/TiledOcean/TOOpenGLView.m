/* All Rights reserved */

#import <AppKit/AppKit.h>
#import <GL/gl.h>

#import "TOOpenGLView.h"
#import "Core/NPEngineCore.h"
#import "Graphics/RenderContext/NPOpenGLPixelFormat.h"
#import "Graphics/Model/NPSUXModel.h"
#import "Cg/cg.h"
#import "Cg/cgGL.h"

@implementation TOOpenGLView

- (id)initWithFrame:(NSRect) frameRect
{

    //[ [ NPEngineCore instance ] setup ];

	//NPSUXModel * model = [ [ NPSUXModel alloc ] init ];
	//NPFile * file = [ [ NPFile alloc ] initWithName:@"fgeug" parent:nil fileName:@"/home/icicle/Desktop/DA-Plunder/airconditioner.model" ];

	//[ model loadFromFile:file ];

    NSOpenGLPixelFormat * pixelFormat;

    /*NSOpenGLPixelFormatAttribute attributes[] =
    {
        NSOpenGLPFAWindow,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize, 8,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAStencilSize, 8,
        0
    };

    pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes: attributes];*/

    NPOpenGLPixelFormat * nppf = [ [ NPOpenGLPixelFormat alloc ] init ];
    [ nppf setup ];
    pixelFormat = [ nppf pixelFormat ];

    if(!pixelFormat)
    {
        NSLog(@"Invalid format... terminating.");

        return nil;
    }

    self = [super initWithFrame:frameRect pixelFormat: pixelFormat];

    //[pixelFormat release];

    // If there was an error, we again should probably send an error message to the user
    if(!self)
    {
        NSLog(@"Self not created... terminating.");

        return nil;
    }

    // Finally, we call the initGL method (no need to make this method too long or complex)
    [self initGL];

    return self;
}

- (void)initGL
{
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);

    glClearDepth(1.0f);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_DEPTH_TEST);

    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);

    glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
}

- (void) drawRect: (NSRect) aRect
{
    NSOpenGLContext * ctx;

    ctx = [self openGLContext];

    if( ctx != [NSOpenGLContext currentContext] )
    {
        NS_DURING
            [ctx makeCurrentContext];
            [self reshape];
        NS_HANDLER
            NSLog(@"Exception");
            NS_VOIDRETURN;
        NS_ENDHANDLER
    }

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glTranslatef(-1.5f,0.0f,-2.0f);

    glBegin(GL_TRIANGLES);
        glColor3f(1.0f,0.0f,0.0f);
        glVertex3f( 0.0f, 1.0f, 0.0f);
        glColor3f(0.0f,1.0f,0.0f);
        glVertex3f(-1.0f,-1.0f, 0.0f);
        glColor3f(0.0f,0.0f,1.0f);
        glVertex3f( 1.0f,-1.0f, 0.0f);
    glEnd();

    [[self openGLContext] flushBuffer];
}

- (void) reshape
{
   NSRect fr_rect = [self frame];
   GLint height = (GLint) fr_rect.size.height;
   GLint width =  (GLint) fr_rect.size.width;
   GLfloat h = (GLfloat) height / (GLfloat) width;

   glViewport(0, 0, (GLint) width, (GLint) height);
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   /* fit width and height */
   if (h >= 1.0)
     glFrustum(-1.0, 1.0, -h, h, 1.0, 100.0);
   else
     glFrustum(-1.0/h, 1.0/h, -1.0, 1.0, 1.0, 100.0);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   //glTranslatef(0.0, 0.0, -40.0);
}

@end
