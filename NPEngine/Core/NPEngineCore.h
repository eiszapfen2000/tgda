#import "Core/NPObject/NPObject.h"
#import "Core/Log/NPLogger.h"
#import "Core/Timer/NPTimer.h"

@interface NPEngineCore : NPObject
{
    NPLogger * logger;
    NPTimer * timer;
}

+ (NPEngineCore *)instance;

@end
