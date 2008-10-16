#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"

#import "Core/NPObject/NPObject.h"
#import "Core/NPObject/NPObjectManager.h"

#import "Core/File/NpFile.h"

#import "Core/Log/NPLogger.h"

#import "Core/RandomNumbers/NPRandomNumberGenerator.h"
#import "Core/RandomNumbers/NPGaussianRandomNumberGenerator.h"
#import "Core/RandomNumbers/NPRandomNumberGeneratorManager.h"

#import "Core/Resource/NPResource.h"

#import "Core/Timer/NPTimer.h"

#import "Core/Utilities/NPStringUtilities.h"

#import "Core/World/NPTransformationState.h"
#import "Core/World/NPTransformationStateManager.h"

//@class NPTimer;
//@class NPObjectManager;
//@class NPPathManager;
//@class NPRandomNumberGeneratorManager;
//@class NPTransformationStateManager;
@class NPModelManager;
@class NPImageManager;
@class NPTextureManager;
@class NPTextureBindingStateManager;
@class NPEffectManager;
@class NPOpenGLRenderContextManager;
@class NPCameraManager;
@class NPStateConfiguration;

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

    NPStateConfiguration * stateConfiguration;
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
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
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
- (NPStateConfiguration *) stateConfiguration;
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
