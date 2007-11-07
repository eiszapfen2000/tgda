#import "NPObject.h"
#import "NPLogger.h"
#import "NPTimer.h"

@interface NPEngineCore : NPObject
{
    NPLogger * log;
    NPTimer * timer;
}
@end
