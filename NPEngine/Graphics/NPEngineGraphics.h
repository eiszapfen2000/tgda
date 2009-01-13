#import "npgl.h"

#import "NPEngineGraphicsConstants.h"

#import "Graphics/Camera/NPCamera.h"
#import "Graphics/Camera/NPCameraManager.h"

#import "Graphics/Image/NPImage.h"
#import "Graphics/Image/NPImageManager.h"
#import "Graphics/Image/NPPixelBuffer.h"
#import "Graphics/Image/NPPixelBufferManager.h"

#import "Graphics/Material/NpMaterial.h"

#import "Graphics/Model/NpModel.h"

#import "Graphics/RenderContext/NPOpenGLPixelFormat.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"

#import "Graphics/R2VB/NPR2VBConfiguration.h"
#import "Graphics/R2VB/NPR2VBManager.h"

#import "Graphics/RenderTarget/NPRenderBuffer.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/RenderTarget/NPRenderTargetManager.h"

#import "Graphics/State/NpState.h"

#import "Graphics/Viewport/NPViewport.h"
#import "Graphics/Viewport/NPViewportManager.h"

@interface NPEngineGraphics : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;

    NPOpenGLRenderContextManager * renderContextManager;

    NPViewportManager * viewportManager;
    NPStateConfiguration * stateConfiguration;
    NPStateSetManager * stateSetManager;
    NPModelManager * modelManager;
    NPImageManager * imageManager;
    NPTextureManager * textureManager;
    NPTextureBindingStateManager * textureBindingStateManager;
    NPEffectManager * effectManager;
    NPRenderTargetManager * renderTargetManager;
    NPPixelBufferManager * pixelBufferManager;
    NPR2VBManager * r2vbManager;
    NPCameraManager * cameraManager;

    id window;

    BOOL ready;
}

+ (NPEngineGraphics *) instance;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setupWithViewportSize:(IVector2)viewportSize;

- (NSString *) name;
- (void) setName:(NSString *)newName;
- (NPObject *) parent;
- (void) setParent:(NPObject *)newParent;
- (UInt32) objectID;

- (BOOL) ready;

- (NPOpenGLRenderContextManager *) renderContextManager;
- (NPViewportManager *) viewportManager;
- (NPStateConfiguration *) stateConfiguration;
- (NPStateSetManager *) stateSetManager;
- (NPModelManager *) modelManager;
- (NPImageManager *) imageManager;
- (NPTextureManager *) textureManager;
- (NPTextureBindingStateManager *) textureBindingStateManager;
- (NPEffectManager *) effectManager;
- (NPRenderTargetManager *) renderTargetManager;
- (NPPixelBufferManager *) pixelBufferManager;
- (NPR2VBManager *) r2vbManager;
- (NPCameraManager *) cameraManager;

- (id) window;
- (void) setWindow:(id)newWindow;

- (void) render;

- (void) swapBuffers;

@end
