#import "Core/Basics/NpBasics.h"
#import "NPOpenGLView.h"

@class TOScene;
@class NPRenderBuffer;
@class NPRenderTexture;
@class NPRenderTargetConfiguration;

@interface TOOpenGLView : NPOpenGLView
{
    NSTimer * timer;
    TOScene * scene;

    BOOL glStateInitialised;

    float rotY;
    float rotz;

    NSPoint reference;

    NPRenderBuffer * renderBuffer;
    NPRenderTexture * renderTexture;
    NPRenderTargetConfiguration * renderTargetConfiguration;
}

- (id) initWithFrame:(NSRect)frameRect;
- (void) dealloc;

- (void) setup:(NSNotification *)aNot;

- (TOScene *) scene;

- (void) setupGLState;

- (void) buildVBOUsingVertexArray:(Float *)vertexArray
                       indexArray:(Int *)indexArray
                        maxVertex:(Int)maxVertex
                         maxIndex:(Int)maxIndex;

@end
