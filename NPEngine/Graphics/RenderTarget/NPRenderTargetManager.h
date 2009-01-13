#import "Core/NPObject/NPObject.h"

@interface NPRenderTargetManager : NPObject
{
    Int colorBufferCount;
    Int maxRenderBufferSize;
    id renderTargetConfigurations;
    id currentRenderTargetConfiguration;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (Int) colorBufferCount;
- (id) currentRenderTargetConfiguration;
- (void) setCurrentRenderTargetConfiguration:(id)newRenderTargetConfiguration;

@end
