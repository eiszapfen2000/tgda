#import "Log/NPLog.h"
#import "Core/NPEngineCore.h"
#import "Graphics/NPEngineGraphics.h"
#import "Sound/NPEngineSound.h"

@interface NP : NSObject

+ (NPLog *) Log;
+ (NPEngineCore *) Core;
+ (NPEngineGraphics *) Graphics;
+ (NPEngineSound *) Sound;

@end
