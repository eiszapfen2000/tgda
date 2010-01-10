#import "Application/NpApplication.h"
#import "Core/NPEngineCore.h"
#import "Graphics/NPEngineGraphics.h"
#import "Input/NPEngineInput.h"
#import "Sound/NPEngineSound.h"

@interface NP : NSObject

+ (id) Core;
+ (id) Graphics;
+ (id) Input;
+ (id) Sound;

@end

#define NPLOG(_logmessage,args...)         [[[ NP Core ] logger ] write:       [ NSString stringWithFormat:_logmessage, ## args]]
#define NPLOG_WARNING(_logmessage,args...) [[[ NP Core ] logger ] writeWarning:[ NSString stringWithFormat:_logmessage, ## args]]
#define NPLOG_ERROR(_logmessage,args...)   [[[ NP Core ] logger ] writeError:  [ NSString stringWithFormat:_logmessage, ## args]]

