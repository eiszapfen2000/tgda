#import "ODOpenGLView.h"

#import "Core/NPEngineCore.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"

@implementation ODOpenGLView

-(id) initWithFrame:(NSRect)frameRect
{
    [ super initWithFrame: frameRect ];

    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) setup
{
    NSDictionary * settings = [ NSDictionary dictionaryWithContentsOfFile:@"settings.plist" ];
    Int sampleCount = [[ settings objectForKey:@"FSAA" ] intValue ];

    NPOpenGLPixelFormat * pixelFormat = [[ NPOpenGLPixelFormat alloc ] init ];
    [ pixelFormat setSampleCount:sampleCount ];

    renderContext = [[[[ NPEngineCore instance ] renderContextManager ] createRenderContextWithPixelFormat:pixelFormat andName:@"NPOpenGLViewRC" ] retain ];
    [ renderContext connectToView:self ];
    [ renderContext activate ];
    [ renderContext setupGLEW ];

    [ pixelFormat release ];

    [[ NPEngineCore instance ] setup ];
}

- (void) shutdown
{
    NSLog(@"shutdown");
    [ renderContext deactivate ];
    [ renderContext disconnectFromView ];
    [ renderContext release ];
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (void) reshape
{
}

- (void) update
{
    [ renderContext update ];
}

- (void) updateAndRender:(NSNotification *)aNotification
{
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT );

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glBegin(GL_TRIANGLES);
        glColor3f(1.0f,0.0f,0.0f);
        //glTexCoord2f(0.0f,0.0f);
        glVertex2f(-1.0f,0.0f);
        //glTexCoord2f(1.0f,0.0f);
        glVertex2f(1.0f,0.0f);
        //glTexCoord2f(0.5f,1.0f);
        glVertex2f(0.0f,1.0f);
    glEnd();

    [ renderContext swap ];
}

/*- (void) frameChanged:(NSNotification *)aNot
{
    NSLog(@"framchanged");
    if( [ renderContext context ] != [NSOpenGLContext currentContext] )
    {
        [ renderContext activate ];
        [ self reshape ];
        [ self update ];
    }
    else
    {
        [ self reshape ];
        [ self update ];
    }
}*/

- (void) drawRect:(NSRect)aRect
{
}

@end
