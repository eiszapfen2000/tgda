#import <Foundation/Foundation.h>
#import "Core/NPEngineCore.h"
#import "Graphics/NPEngineGraphics.h"

@interface NP : NSObject

+ (id) Core;
+ (id) Graphics;

@end

#define NPLOG(_logmessage)       [[[ NP Core ] logger ] write:(_logmessage)]
#define NPLOG_WARNING(_warning)  [[[ NP Core ] logger ] writeWarning:(_warning)]
#define NPLOG_ERROR(_error)      [[[ NP Core ] logger ] writeError:(_error)]
