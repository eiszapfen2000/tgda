#import <AppKit/AppKit.h>

#import "Core/NPObject/NPObject.h"
#import "NPOpenGLPixelFormat.h"

@interface NPOpenGLRenderContext : NPObject
{
    BOOL active;
    NSOpenGLContext * context;
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

- (void) activate;
- (void) deactivate;
- (BOOL) isActive;
- (void) update;
- (void) swap;

@end
