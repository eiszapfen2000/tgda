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
@class NPFullscreenQuad;
@class NPRenderTexture;
@class NPRenderTargetConfiguration;
@class NPEffect;
@class NPEffectVariableInt;
@class NPEffectVariableFloat2;

@interface ODIWave : NPObject
{
    IVector2 lastResolution;
    IVector2 resolution;

    float alpha;
    double accumulatedDeltaTime;

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

    NPFullscreenQuad * fullscreenQuad;

    NPEffect * effect;
    NPEffectTechnique * addSourceObstructionT;
    NPEffectTechnique * convolutionT;
    NPEffectTechnique * propagationT;
    NPEffectVariableInt * kernelRadiusV;
    NPEffectVariableFloat2 * dtAlphaV;

    NPBufferObject * xzStream;
    NPBufferObject * yStream;
    NPBufferObject * indexStream;
    NPVertexArray * mesh;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) start;
- (void) stop;

- (NPTexture2D *) sourceTexture;
- (NPTexture2D *) obstructionTexture;
- (NPTexture2D *) derivativeTexture;
- (NPTexture2D *) heightTexture;
- (NPTexture2D *) prevHeightTexture;

- (void) update:(const double)frameTime;
- (void) render;

@end

