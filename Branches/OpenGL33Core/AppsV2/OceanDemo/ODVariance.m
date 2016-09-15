#import <Foundation/NSException.h>
#import "Core/Container/NPAssetArray.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "NP.h"
#import "ODVariance.h"

static const NSUInteger defaultVarianceLUTResolutionIndex = 0;
static const uint32_t varianceLUTResolutions[4] = {4, 8, 12, 16};

@implementation ODVariance

- (id) init
{
    return [ self initWithName:@"ODVariance" ];
}

- (id) initWithName:(NSString *)newName
{
	self = [ super initWithName:newName ];

    varianceLUTLastResolutionIndex = ULONG_MAX;
    varianceLUTResolutionIndex = defaultVarianceLUTResolutionIndex;
    varianceRTC = [[ NPRenderTargetConfiguration alloc ] initWithName:@"Variance RTC" ];
    varianceLUT = [[ NPRenderTexture alloc ] initWithName:@"Variance LUT" ];

    effect = [[[ NP Graphics ] effects ] getAssetWithFileName:@"variance.effect" ];
	ASSERT_RETAIN(effect);

    variance = [ effect techniqueWithName:@"variance" ];
    ASSERT_RETAIN(variance);

    layer         = [ effect variableWithName:@"layer" ];
    deltaVariance = [ effect variableWithName:@"deltaVariance" ];

    varianceTextureResolution
    	= [ effect variableWithName:@"varianceTextureResolution" ];

    NSAssert(layer != nil && deltaVariance != nil
             && varianceTextureResolution != nil, @"");

	return self;
}

- (void) dealloc
{
	DESTROY(variance);
	DESTROY(effect);

	DESTROY(varianceLUT);
	DESTROY(varianceRTC);

	[ super dealloc ];
}

@end
