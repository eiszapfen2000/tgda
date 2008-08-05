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

@interface NPEngineCore : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;

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

+ (NPEngineCore *) instance;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

- (NSString *) name;
- (void) setName:(NSString *)newName;

- (NPObject *) parent;
- (void) setParent:(NPObject *)newParent;

- (UInt32) objectID;

- (BOOL) ready;
- (NPLogger *) logger;
- (NPTimer *) timer;
- (NPObjectManager *) objectManager;
- (NPPathManager *) pathManager;
- (NPRandomNumberGeneratorManager *) randomNumberGeneratorManager;
- (NPTransformationStateManager *) transformationStateManager;
- (NPOpenGLRenderContextManager *) renderContextManager;
- (NPModelManager *) modelManager;
- (NPImageManager *) imageManager;
- (NPTextureManager *) textureManager;
- (NPTextureBindingStateManager *) textureBindingStateManager;
- (NPEffectManager *) effectManager;
- (NPCameraManager *) cameraManager;

@end

#define NPLOG(_logmessage)  [[[ NPEngineCore instance ] logger ] write:(_logmessage)]
#define NPLOG_WARNING(_warning)  [[[ NPEngineCore instance ] logger ] writeWarning:(_warning)]
#define NPLOG_ERROR(_error)  [[[ NPEngineCore instance ] logger ] writeError:(_error)]
