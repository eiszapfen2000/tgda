#import "Core/NPObject/NPObject.h"
#import "Core/Log/NPLogger.h"

@class NPTimer;
@class NPObjectManager;
@class NPPathManager;
@class NPTransformationStateManager;
@class NPModelManager;
@class NPImageManager;
@class NPTextureManager;
@class NPEffectManager;
@class NPOpenGLRenderContextManager;
@class NPCameraManager;

@interface NPEngineCore : NPObject
{
    NPLogger * logger;
    NPTimer * timer;
    NPObjectManager * objectManager;
    NPPathManager * pathManager;

    NPTransformationStateManager * transformationStateManager;

    NPOpenGLRenderContextManager * renderContextManager;

    NPModelManager * modelManager;
    NPImageManager * imageManager;
    NPTextureManager * textureManager;
    NPEffectManager * effectManager;

    NPCameraManager * cameraManager;

    BOOL ready;
}

+ (NPEngineCore *)instance;

- (void)setup;

- (BOOL)isReady;
- (NPLogger *)logger;
- (NPTimer *)timer;
- (NPObjectManager *)objectManager;
- (NPPathManager *)pathManager;
- (NPTransformationStateManager *)transformationStateManager;
- (NPOpenGLRenderContextManager *)renderContextManager;
- (NPModelManager *)modelManager;
- (NPImageManager *)imageManager;
- (NPTextureManager *)textureManager;
- (NPEffectManager *)effectManager;
- (NPCameraManager *)cameraManager;

@end

#define NPLOG(_logmessage)  [[[ NPEngineCore instance ] logger ] write:(_logmessage)]
#define NPLOG_WARNING(_warning)  [[[ NPEngineCore instance ] logger ] writeWarning:(_warning)]
#define NPLOG_ERROR(_error)  [[[ NPEngineCore instance ] logger ] writeError:(_error)]
