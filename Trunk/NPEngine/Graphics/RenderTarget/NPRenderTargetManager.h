#import "Core/NPObject/NPObject.h"

@class NPRenderTargetConfiguration;

@interface NPRenderTargetManager : NPObject
{
    Int colorBufferCount;
    Int maxRenderBufferSize;
    NSMutableArray * renderTargetConfigurations;
    NPRenderTargetConfiguration * currentRenderTargetConfiguration;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (Int) colorBufferCount;
- (NPRenderTargetConfiguration *) currentRenderTargetConfiguration;
- (void) setCurrentRenderTargetConfiguration:(NPRenderTargetConfiguration *)newRenderTargetConfiguration;

@end
