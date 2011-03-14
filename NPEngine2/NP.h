#import "Log/NPLog.h"
#import "Core/NPEngineCore.h"
#import "Graphics/NPEngineGraphics.h"
#import "Input/NPEngineInput.h"
#import "Sound/NPEngineSound.h"

@interface NP : NSObject

+ (NPLog *) Log;
+ (NPEngineCore *) Core;
+ (NPEngineGraphics *) Graphics;
+ (NPEngineInput *) Input;
+ (NPEngineSound *) Sound;

@end
