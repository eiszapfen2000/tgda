#import "npgl.h"

#import "Graphics/Camera/NPCamera.h"
#import "Graphics/Camera/NPCameraManager.h"

#import "Graphics/Image/NPImage.h"
#import "Graphics/Image/NPImageManager.h"

#import "Graphics/Material/NpMaterial.h"

#import "Graphics/Model/NpModel.h"

#import "Graphics/RenderContext/NPOpenGLPixelFormat.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"

#import "Graphics/RenderTarget/NPRenderBuffer.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"

#import "Graphics/State/NpState.h"

@interface NPEngineGraphics : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;

    NPOpenGLRenderContextManager * renderContextManager;

    NPStateConfiguration * stateConfiguration;
    NPStateSetManager * stateSetManager;
    NPModelManager * modelManager;
    NPImageManager * imageManager;
    NPTextureManager * textureManager;
    NPTextureBindingStateManager * textureBindingStateManager;
    NPEffectManager * effectManager;
    NPCameraManager * cameraManager;

    BOOL ready;
}

+ (NPEngineGraphics *) instance;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (NSString *) name;
- (void) setName:(NSString *)newName;

- (NPObject *) parent;
- (void) setParent:(NPObject *)newParent;

- (UInt32) objectID;

- (BOOL) ready;

- (NPOpenGLRenderContextManager *) renderContextManager;
- (NPStateConfiguration *) stateConfiguration;
- (NPStateSetManager *) stateSetManager;
- (NPModelManager *) modelManager;
- (NPImageManager *) imageManager;
- (NPTextureManager *) textureManager;
- (NPTextureBindingStateManager *) textureBindingStateManager;
- (NPEffectManager *) effectManager;
- (NPCameraManager *) cameraManager;

- (void) swapBuffers;

@end
