#import "Core/NPObject/NPObject.h"
#import "Core/Log/NPLogger.h"

@class NPTimer;
@class NPObjectManager;
@class NPPathManager;
@class NPModelManager;
@class NPEffectManager;
@class NPOpenGLRenderContextManager;

@interface NPEngineCore : NPObject
{
    NPLogger * logger;
    NPTimer * timer;
    NPObjectManager * objectManager;
    NPPathManager * pathManager;
    NPModelManager * modelManager;
    NPEffectManager * effectManager;
    NPOpenGLRenderContextManager * renderContextManager;

    BOOL ready;
}

+ (NPEngineCore *)instance;

- (void)setup;

- (BOOL)isReady;
- (NPLogger *)logger;
- (NPTimer *)timer;
- (NPObjectManager *)objectManager;
- (NPPathManager *)pathManager;
- (NPModelManager *)modelManager;
- (NPEffectManager *)effectManager;
- (NPOpenGLRenderContextManager *)renderContextManager;

@end

#define NPLOG(_logmessage)  [[[ NPEngineCore instance ] logger ] write:(_logmessage)]
#define NPLOG_WARNING(_warning)  [[[ NPEngineCore instance ] logger ] writeWarning:(_warning)]
#define NPLOG_ERROR(_error)  [[[ NPEngineCore instance ] logger ] writeError:(_error)]
