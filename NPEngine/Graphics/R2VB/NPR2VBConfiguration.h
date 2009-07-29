#import "Core/NPObject/NPObject.h"

#define NP_READ_BUFFER_FRAMEBUFFER_BACK         0
#define NP_READ_BUFFER_FRAMEBUFFER_LEFT_BACK    1
#define NP_READ_BUFFER_FRAMEBUFFER_RIGHT_BACK   2
#define NP_READ_BUFFER_FRAMEBUFFER_FRONT        3
#define NP_READ_BUFFER_FRAMEBUFFER_LEFT_FRONT   4
#define NP_READ_BUFFER_FRAMEBUFFER_RIGHT_FRONT  5

#define NP_READ_BUFFER_COLORBUFFER_0    0
#define NP_READ_BUFFER_COLORBUFFER_1    1
#define NP_READ_BUFFER_COLORBUFFER_2    2
#define NP_READ_BUFFER_COLORBUFFER_3    3
#define NP_READ_BUFFER_COLORBUFFER_4    4
#define NP_READ_BUFFER_COLORBUFFER_5    5
#define NP_READ_BUFFER_COLORBUFFER_6    6
#define NP_READ_BUFFER_COLORBUFFER_7    7

#define NP_GRAPHICS_R2VB_FRAMEBUFFER_MODE   0
#define NP_GRAPHICS_R2VB_RENDERTEXTURE_MODE 1

@class NPVertexBuffer;
@class NPRenderTexture;

@interface NPR2VBConfiguration : NPObject
{
    NpState mode;
    NSMutableDictionary * sources;
    NSMutableDictionary * targets;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) clear;

- (void) setTarget:(NPVertexBuffer *)newTarget;
- (void) setRenderTextureSource:(NPRenderTexture *)renderTexture forTargetBuffer:(NSString *)targetBuffer;

- (void) copyBuffers;

@end
