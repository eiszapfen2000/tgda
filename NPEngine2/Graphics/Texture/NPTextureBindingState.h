#import "GL/glew.h"
#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "NPPTexture.h"

@interface NPTextureBindingState : NPObject
{
	uint32_t numberOfSuppertedTexelUnits;
	uint32_t maximumNumberOfVertexTexelUnits;

	BOOL locked;

	GLuint* currentTextureIndices;
	GLenum* currentTextureTypes;
	GLuint* boundTextureIndices;
	GLenum* boundTextureTypes;
	BOOL* lockedTexelUnits;
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

- (void) lockTexelUnit:(const uint32_t)texelUnit;
- (void) unlockTexelUnit:(const uint32_t)texelUnit;

- (void) setNoTexture:(const uint32_t)texelUnit;
- (void) setTexture:(id <NPPTexture>)texture texelUnit:(const uint32_t)texelUnit;
- (void) setTextureImmediately:(id <NPPTexture>)texture;
- (void) restoreOriginalTextureImmediately;

- (void) activate;
- (void) activate:(BOOL)force;

@end

