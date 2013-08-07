#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NSCondition;
@class NSLock;
@class NSMutableArray;
@class NSPointerArray;
@class NSThread;
@class NPTimer;
@class NPTexture2D;
@class NPTextureBuffer;
@class NPBufferObject;
@class NPVertexArray;
@class NPRenderTexture;
@class NPRenderTargetConfiguration;

@interface ODIWave : NPObject
{
    IVector2 lastResolution;
    IVector2 resolution;

    int32_t lastKernelRadius;
    int32_t kernelRadius;
    float * kernel;

    float * source;
    float * obstruction;
    float * depth;

    NPBufferObject  * kernelBuffer;
    NPTextureBuffer * kernelTexture;

    NPTexture2D * sourceTexture;
    NPTexture2D * obstructionTexture;
    NPTexture2D * depthTexture;

    NPRenderTexture * heightsTarget;
    NPRenderTexture * prevHeightsTarget;
    NPRenderTexture * depthDerivativeTarget;
    NPRenderTexture * derivativeTarget;
    NPRenderTexture * tempTarget;
    NPRenderTargetConfiguration * rtc;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) start;
- (void) stop;

- (void) update:(const double)frameTime;
- (void) render;

@end

