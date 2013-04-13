#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

typedef struct NpSamplerFilterState
{
	NpTexture2DFilter textureFilter;
	uint32_t anisotropy;
}
NpSamplerFilterState;

typedef struct NpSamplerWrapState
{
	NpTextureWrap wrapS;
	NpTextureWrap wrapT;
    NpTextureWrap wrapR;
}
NpSamplerWrapState;

void reset_sampler_filterstate(NpSamplerFilterState * filterState);
void reset_sampler_wrapstate(NpSamplerWrapState * wrapState);

@interface NPSamplerObject : NPObject
{
    NpSamplerFilterState filterState;
    NpSamplerWrapState wrapState;
    GLuint glID;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (GLuint) glID;

- (void) clear;
- (void) reset;

- (void) setTextureFilter:(NpTexture2DFilter)newTextureFilter;
- (void) setTextureAnisotropy:(uint32_t)newTextureAnisotropy;
- (void) setTextureWrap:(NpSamplerWrapState)newTextureWrap;

@end

