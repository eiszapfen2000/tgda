#import "NPOpenGLView.h"

@class NPSUXModel;
@class NPEffect;
@class NPTexture;

@interface TOOpenGLView : NPOpenGLView
{
    BOOL glReady;
}

- (id) initWithFrame:(NSRect)frameRect;

- (void) setupGLState;

@end
