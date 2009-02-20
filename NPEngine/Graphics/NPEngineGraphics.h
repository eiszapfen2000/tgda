#import "npgl.h"
#import "NPEngineGraphicsConstants.h"
#import "NPOrthographicRendering.h"

#import "Graphics/Camera/NPCamera.h"
#import "Graphics/Camera/NPCameraManager.h"

#import "Graphics/Image/NPImage.h"
#import "Graphics/Image/NPImageManager.h"
#import "Graphics/Image/NPPixelBuffer.h"
#import "Graphics/Image/NPPixelBufferManager.h"

#import "Graphics/Font/NPFont.h"
#import "Graphics/Font/NPFontManager.h"

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

    NPStateConfiguration * stateConfiguration;
    NPStateSetManager    * stateSetManager;

    NPTextureBindingStateManager * textureBindingStateManager;

    NPVertexBufferManager * vertexBufferManager;
    NPImageManager   * imageManager;
    NPTextureManager * textureManager;
    NPEffectManager  * effectManager;
    NPModelManager   * modelManager;
    NPFontManager    * fontManager;

    NPRenderTargetManager * renderTargetManager;
    NPPixelBufferManager  * pixelBufferManager;
    NPR2VBManager         * r2vbManager;

    NPViewportManager * viewportManager;

    NPCameraManager * cameraManager;

    NPOrthographicRendering * orthographicRendering;

    BOOL ready;
}

+ (NPEngineGraphics *) instance;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setupWithViewportSize:(IVector2)viewportSize;

- (NSString *) name;
- (id <NPPObject>) parent;
- (UInt32) objectID;

- (void) setName:(NSString *)newName;
- (void) setParent:(id <NPPObject>)newParent;

- (BOOL) ready;

- (NPOpenGLRenderContextManager *) renderContextManager;
- (NPStateConfiguration *) stateConfiguration;
- (NPStateSetManager *) stateSetManager;
- (NPTextureBindingStateManager *) textureBindingStateManager;
- (NPVertexBufferManager *) vertexBufferManager;
- (NPImageManager *) imageManager;
- (NPTextureManager *) textureManager;
- (NPEffectManager *) effectManager;
- (NPModelManager *) modelManager;
- (NPFontManager *) fontManager;
- (NPRenderTargetManager *) renderTargetManager;
- (NPPixelBufferManager *) pixelBufferManager;
- (NPR2VBManager *) r2vbManager;
- (NPViewportManager *) viewportManager;
- (NPCameraManager *) cameraManager;
- (NPOrthographicRendering *) orthographicRendering;

- (void) render;

- (void) clearFrameBuffer:(BOOL)clearFrameBuffer
              depthBuffer:(BOOL)clearDepthBuffer
            stencilBuffer:(BOOL)clearStencilBuffer
                         ;

- (void) swapBuffers;

@end
