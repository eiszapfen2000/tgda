#import "Core/NPObject/NPObject.h"
#import "Core/Log/NPLogger.h"

@class NPTimer;
@class NPObjectManager;
@class NPPathManager;
@class NPOpenGLRenderContextManager;

@interface NPEngineCore : NPObject
{
    NPLogger * logger;
    NPTimer * timer;
    NPObjectManager * objectManager;
    NPPathManager * pathManager;
    NPOpenGLRenderContextManager * renderContextManager;
}

+ (NPEngineCore *)instance;

- (NPLogger *)logger;
- (NPTimer *)timer;
- (NPObjectManager *)objectManager;
- (NPPathManager *)pathManager;
- (NPOpenGLRenderContextManager *)renderContextManager;

- (void) setup;

@end

#define NPLOG(_logmessage)  [[[ NPEngineCore instance ] logger ] write:(_logmessage)]
#define NPLOG_WARNING(_warning)  [[[ NPEngineCore instance ] logger ] writeWarning:(_warning)]
#define NPLOG_ERROR(_error)  [[[ NPEngineCore instance ] logger ] writeError:(_error)]
