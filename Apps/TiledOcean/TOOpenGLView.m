//#import <GL/gl.h>
#import "TOOpenGLView.h"
#import "Graphics/Material/NPTexture.h"
#import "Graphics/Material/NPTextureManager.h"
#import "Graphics/Material/NPTextureBindingState.h"
#import "Graphics/Material/NPTextureBindingStateManager.h"
#import "Graphics/Model/NPSUXModel.h"
#import "Graphics/Model/NPModelManager.h"
#import "Graphics/Camera/NPCamera.h"
#import "Graphics/Camera/NPCameraManager.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Material/NPEffect.h"
#import "Graphics/Material/NPEffectManager.h"


@implementation TOOpenGLView


- (id)initWithFrame:(NSRect) frameRect
{
    self = [ super initWithFrame:frameRect ];

    if(!self)
    {
        NSLog(@"Self not created... terminating.");
        return nil;
    }

    return self;
}

- (void)initGL
{
    NSLog(@"initgl");
    glClearColor(0.0f, 1.0f, 0.0f, 0.0f);

    glClearDepth(1.0f);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);

    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);

    glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
}

- (void) drawRect:(NSRect) aRect
{
    /*NSLog(@"draw");

    NPOpenGLRenderContext * ctx;

    ctx = [ self renderContext];

    if( [ ctx context ] != [NSOpenGLContext currentContext] )
    {
        [renderContext activate];
    }

    [ self initGL ];
    [ self update ];
    [self reshape];

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

    [[self renderContext] swap];*/
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
   /*if (h >= 1.0)
     glFrustum(-1.0, 1.0, -h, h, 1.0, 100.0);
   else
     glFrustum(-1.0/h, 1.0/h, -1.0, 1.0, 1.0, 100.0);*/
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   //glTranslatef(0.0, 0.0, -40.0);
}

- (void) loadModel
{
    [[self renderContext ] activate ];

    //model = [[[ NPEngineCore instance ] modelManager ] loadModelFromPath:@"camera.model" ];

    //[ model uploadToGL ];

    effect = [[[ NPEngineCore instance ] effectManager ] loadEffectFromPath:@"camera.cgfx" ];
    texture = [[[ NPEngineCore instance ] textureManager ] loadTextureFromPath:@"editorobjects.jpg" ];
    glBindTexture(GL_TEXTURE_2D,[texture textureID]);
    [ texture setTextureMinFilter:NP_TEXTURE_FILTER_LINEAR ];
    [ texture setTextureMaxFilter:NP_TEXTURE_FILTER_LINEAR ];
    [ texture uploadToGL ];
    glBindTexture(GL_TEXTURE_2D,0);

    GLenum glError = glGetError();

    if (glError != GL_NO_ERROR)
	{NPLOG(([NSString stringWithFormat:@"%s",gluErrorString(glError)]));}
}

- (void) drawModel
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    //NPTextureBindingState * t = [[[ NPEngineCore instance ] textureBindingStateManager ] currentTextureBindingState ];
    //[ t setTexture:texture forKey:@"NPCOLORMAP0" ];

    [ effect uploadSampler2DWithParameterName:@"colormap" andID:[texture textureID] ];

    /*NPCamera * camera = [[[ NPEngineCore instance ] cameraManager ] currentActiveCamera ];

    FVector3 pos;
    FV_Z(pos) = 10.0f;

    [ camera setPosition:&pos ];
    [ camera rotateY:10.0f ];
    [ camera update ];

    [ camera render ];
    [ model render ];*/

    CGpass pass;
    pass = cgGetFirstPass([effect defaultTechnique]);
    while (pass) {
    cgSetPassState(pass);

    glRectf(-1,-1,1,1);

    cgResetPassState(pass);
    pass = cgGetNextPass(pass);
    }

    GLenum glError = glGetError();

    if (glError != GL_NO_ERROR)
	{NPLOG(([NSString stringWithFormat:@"%s",gluErrorString(glError)]));}

    [[self renderContext] swap];
}


@end
