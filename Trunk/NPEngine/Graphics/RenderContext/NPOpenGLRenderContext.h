#import <AppKit/NSOpenGL.h>

#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"
#import "NPOpenGLPixelFormat.h"

@interface NPOpenGLRenderContext : NPObject
{
    BOOL ready;
    BOOL active;
    BOOL glewInitialised;
    NSOpenGLContext * context;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NSOpenGLContext *)context;

- (BOOL) setupWithPixelFormat:(NPOpenGLPixelFormat *)pixelFormat;

- (void) connectToView:(NSView *)view;
- (void) disconnectFromView;
- (NSView *)view;

- (void) setupGLEW;

- (void) activate;
- (void) deactivate;
- (BOOL) active;
- (BOOL) ready;
- (void) update;
- (void) swap;

- (BOOL) isExtensionSupported:(NSString *)extensionString;

@end
