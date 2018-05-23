#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "GL/glew.h"

@class NPEffect;
@class NPEffectTechnique;
@class NPEffectVariableFloat;
@class NPRenderTexture;
@class NPRenderTargetConfiguration;
@class ODOceanEntity;

@interface ODVariance : NPObject
{
	ODOceanEntity* ocean;
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
    BOOL useDeltaVariance;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
			  ocean:(ODOceanEntity *)newOcean
			  	   ;
- (void) dealloc;

- (id < NPPTexture >) texture;

- (void) update;

@end
