#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NpTextureSamplerParameter.h"

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

- (void) setTextureFilter:(NpSamplerFilterState)newTextureFilter;
- (void) setTextureAnisotropy:(uint32_t)newTextureAnisotropy;
- (void) setTextureWrap:(NpSamplerWrapState)newTextureWrap;

@end

