/* All Rights reserved */

#import <AppKit/AppKit.h>
#import <GL/gl.h>

#import "TOOpenGLView.h"
#import "Core/NPEngineCore.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"

@implementation TOOpenGLView


- (id)initWithFrame:(NSRect) frameRect
{
    self = [ super initWithFrame:frameRect ];

    if(!self)
    {
        NSLog(@"Self not created... terminating.");
        return nil;
    }

    // Finally, we call the initGL method (no need to make this method too long or complex)
    //[self initGL];

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
    NPOpenGLRenderContext * ctx;

    ctx = [ self renderContext];

    if( [ ctx context ] != [NSOpenGLContext currentContext] )
    {
        NS_DURING
            [renderContext activate];
            [ self initGL ];
            NSLog(@"fuck");
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

    [[self renderContext] swap];
}

- (void) reshape
{
    if( [ renderContext context ] != [NSOpenGLContext currentContext] )
    {
        NSLog(@"reshape: BRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAK");
    }

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
