#import <AppKit/AppKit.h>

#import "Core/NPObject/NPObject.h"

@interface NPOpenGLRenderContext : NPObject
{
    NSOpenGLContext * context;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

@end
