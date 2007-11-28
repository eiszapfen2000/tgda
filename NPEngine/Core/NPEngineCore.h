#import "Core/NPObject/NPObject.h"
#import "Core/NPObject/NPObjectManager.h"
#import "Core/Log/NPLogger.h"
#import "Core/Timer/NPTimer.h"

@interface NPEngineCore : NPObject
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
