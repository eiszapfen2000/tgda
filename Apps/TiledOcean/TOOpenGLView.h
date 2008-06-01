#import "Core/Basics/NpBasics.h"
#import "NPOpenGLView.h"

@class TOScene;

@interface TOOpenGLView : NPOpenGLView
{
    NSTimer * timer;
    TOScene * scene;

    BOOL glStateInitialised;

    float rotY;

    NSPoint reference;
}

- (id) initWithFrame:(NSRect)frameRect;

- (void) setup:(NSNotification *)aNot;

- (TOScene *) scene;

- (void) setupGLState;

- (void) buildVBOUsingVertexArray:(Float *)vertexArray
                       indexArray:(Int *)indexArray
                        maxVertex:(Int)maxVertex
                         maxIndex:(Int)maxIndex;

@end
