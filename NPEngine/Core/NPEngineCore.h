#import "Core/NPObject/NPObject.h"
#import "Core/Log/NPLogger.h"

@class NPTimer;
@class NPObjectManager;
@class NPPathManager;
@class NPRandomNumberGeneratorManager;
@class NPTransformationStateManager;
@class NPModelManager;
@class NPImageManager;
@class NPTextureManager;
@class NPTextureBindingStateManager;
@class NPEffectManager;
@class NPOpenGLRenderContextManager;
@class NPCameraManager;

@interface NPEngineCore : NPObject
{
    NPLogger * logger;
    NPTimer * timer;
    NPObjectManager * objectManager;
    NPPathManager * pathManager;

    NPRandomNumberGeneratorManager * randomNumberGeneratorManager;

    NPTransformationStateManager * transformationStateManager;

    NPOpenGLRenderContextManager * renderContextManager;

    NPModelManager * modelManager;
    NPImageManager * imageManager;
    NPTextureManager * textureManager;
    NPTextureBindingStateManager * textureBindingStateManager;
    NPEffectManager * effectManager;

    NPCameraManager * cameraManager;

    BOOL ready;
}

+ (NPEngineCore *)instance;

- (void) dealloc;

- (void)setup;

- (BOOL)isReady;
- (NPLogger *)logger;
- (NPTimer *)timer;
- (NPObjectManager *)objectManager;
- (NPPathManager *)pathManager;
- (NPRandomNumberGeneratorManager *) randomNumberGeneratorManager;
- (NPTransformationStateManager *)transformationStateManager;
- (NPOpenGLRenderContextManager *)renderContextManager;
- (NPModelManager *)modelManager;
- (NPImageManager *)imageManager;
- (NPTextureManager *)textureManager;
- (NPTextureBindingStateManager *)textureBindingStateManager;
- (NPEffectManager *)effectManager;
- (NPCameraManager *)cameraManager;

@end

#define NPLOG(_logmessage)  [[[ NPEngineCore instance ] logger ] write:(_logmessage)]
#define NPLOG_WARNING(_warning)  [[[ NPEngineCore instance ] logger ] writeWarning:(_warning)]
#define NPLOG_ERROR(_error)  [[[ NPEngineCore instance ] logger ] writeError:(_error)]

#define glewGetContext() [[[[ NPEngineCore instance ] renderContextManager ] currentlyActiveRenderContext ] glewContext ]
