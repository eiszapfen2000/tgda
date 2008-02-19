#ifndef GLEW_MX
    #define GLEW_MX
#endif

#import "GL/glew.h"

#import <AppKit/NSOpenGL.h>

#import "Core/NPObject/NPObject.h"
#import "NPOpenGLPixelFormat.h"

@interface NPOpenGLRenderContext : NPObject
{
    BOOL ready;
    BOOL active;
    BOOL glewInitialised;
    NSOpenGLContext * context;
    GLEWContext glewContext;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NSOpenGLContext *)context;

- (BOOL) setupWithPixelFormat:(NPOpenGLPixelFormat *)pixelFormat;

- (void) connectToView:(NSView *)view;
- (void) disconnectFromView;
- (NSView *)view;

- (void) setupGLEW;

- (void) activate;
- (void) deactivate;
- (BOOL) isActive;
- (BOOL) isReady;
- (void) update;
- (void) swap;

@end
