#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPPTexture.h"

typedef struct NpTexture2DFilterState
{
	BOOL mipmaps;
	NpTexture2DFilter textureFilter;
	int32_t anisotropy;
}
NpTexture2DFilterState;

typedef struct NpTexture2DWrapState
{
	NpTextureWrap wrapS;
	NpTextureWrap wrapT;
}
NpTexture2DWrapState;

void reset_texture2d_filterstate(NpTexture2DFilterState * filterState);
void reset_texture2d_wrapstate(NpTexture2DWrapState * wrapState);

@class NSData;

@interface NPTexture2D : NPObject < NPPPersistentObject, NPPTexture >
{
    NSString * file;
    BOOL ready;

    uint32_t width;
    uint32_t height;

    NpTextureDataFormat dataFormat;
    NpTexturePixelFormat pixelFormat;
    NpTexture2DFilterState filterState;
    NpTexture2DWrapState wrapState;

    GLuint glID;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) clear;
- (void) reset;

- (void) uploadToGLWithoutData;
- (void) uploadToGLWithData:(NSData *)data;

@end

