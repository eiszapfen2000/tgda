#import "Core/NPObject/NPObject.h"
#import "Core/NPObject/NPObjectManager.h"
#import "Core/NPObject/NPPCoreProtocols.h"
#import "Core/Log/NPLogger.h"
#import "Core/Timer/NPTimer.h"

@interface NPEngineCore : NPObject < NPPInitialStateSetup >
{
    NPLogger * logger;
    NPTimer * timer;
    NPObjectManager * objectManager;
}

+ (NPEngineCore *)instance;

- (NPLogger *)logger;
- (NPTimer *)timer;
- (NPObjectManager *)objectManager;

@end

#define NPLOG(_logmessage)  [[[ NPEngineCore instance ] logger ] write:(_logmessage)]
#define NPLOG_WARNING(_warning)  [[[ NPEngineCore instance ] logger ] writeWarning:(_warning)]
#define NPLOG_ERROR(_error)  [[[ NPEngineCore instance ] logger ] writeError:(_error)]
