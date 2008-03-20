#import "NPOpenGLView.h"

@class NPSUXModel;
@class NPEffect;
@class NPTexture;

@interface TOOpenGLView : NPOpenGLView
{
    NPSUXModel * model;
    NPEffect * effect;
    NPTexture * texture;
}

- (id)initWithFrame:(NSRect) frameRect;
- (void)initGL;

- (void) loadModel;
- (void) drawModel;

@end
