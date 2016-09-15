#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "GL/glew.h"

@class NPEffect;
@class NPEffectTechnique;
@class NPEffectVariableFloat;
@class NPRenderTexture;
@class NPRenderTargetConfiguration;

@interface ODVariance : NPObject
{
    // variance LUT for Ross BRDF
    NSUInteger varianceLUTLastResolutionIndex;
    NSUInteger varianceLUTResolutionIndex;
    NPRenderTargetConfiguration * varianceRTC;
    NPRenderTexture * varianceLUT;
    NPEffect * effect;
    NPEffectTechnique * variance;
    NPEffectVariableFloat * layer;
    NPEffectVariableFloat * varianceTextureResolution;
    NPEffectVariableFloat * deltaVariance;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end
