#import "GL/glew.h"
#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"

@class NPSamplerObject;

@interface NPTextureSamplingState : NPObject
{
	uint32_t numberOfSuppertedTexelUnits;

	BOOL locked;

	GLuint * currentSamplerIndices;
	GLuint * boundSamplerIndices;
	BOOL * lockedSamplers;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) startup;
- (void) shutdown;

- (void) lock;
- (void) unlock;


- (void) clear;
- (void) reset;

- (void) lockSamplerAtTexelUnit:(const uint32_t)texelUnit;
- (void) unlockSamplerAtTexelUnit:(const uint32_t)texelUnit;

- (void) setSampler:(NPSamplerObject *)sampler texelUnit:(const uint32_t)texelUnit;

- (void) activate;
- (void) activate:(BOOL)force;

@end

