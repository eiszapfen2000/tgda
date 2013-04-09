#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

typedef struct NpSampler2DFilterState
{
	NpTexture2DFilter textureFilter;
	uint32_t anisotropy;
}
NpSampler2DFilterState;

typedef struct NpSampler2DWrapState
{
	NpTextureWrap wrapS;
	NpTextureWrap wrapT;
}
NpSampler2DWrapState;

void reset_sampler2d_filterstate(NpSampler2DFilterState * filterState);
void reset_sampler2d_wrapstate(NpSampler2DWrapState * wrapState);

@interface NPSamplerObject : NPObject
{
    NpSampler2DFilterState filterState;
    NpSampler2DWrapState wrapState;
    GLuint glID;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) clear;
- (void) reset;

@end

