#import <Foundation/NSException.h>
#import "Core/Container/NPAssetArray.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Geometry/NPIMRendering.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/Texture/NPTexture2DArray.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Texture/NPTextureBuffer.h"
#import "NP.h"
#import "Entities/ODOceanEntity.h"
#import "ODVariance.h"

static const NSUInteger defaultVarianceLUTResolutionIndex = 0;
static const uint32_t varianceLUTResolutions[4] = {4, 8, 12, 16};

@interface ODVariance (Private)

- (BOOL) generateVarianceLUTRenderTarget:(uint32_t)resolution
                                   error:(NSError **)error
                                   		;

- (void) updateSlopeVarianceLUT:(uint32_t)resolution;

@end

@implementation ODVariance (Private)

- (BOOL) generateVarianceLUTRenderTarget:(uint32_t)resolution
                                   error:(NSError **)error
{
    return
        [ varianceLUT generate3D:NpRenderTargetColor
                           width:resolution
                          height:resolution
                           depth:resolution
                     pixelFormat:NpTexturePixelFormatRG
                      dataFormat:NpTextureDataFormatFloat16
                   mipmapStorage:NO
                           error:error ];
}

- (void) updateSlopeVarianceLUT:(uint32_t)resolution
{
    const float baseSpectrumDeltaVariance
      = useDeltaVariance ? [ ocean baseSpectrumDeltaVariance ] / 2.0f : 0.0f;

    [ varianceTextureResolution setFValue:(float)resolution ];
    [ deltaVariance setFValue:baseSpectrumDeltaVariance ];

    [[[ NP Graphics ] textureBindingState ] clear ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean baseSpectrum ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean sizes ]        texelUnit:1 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    FRectangle vertices;
    FRectangle texcoords;

    frectangle_rssss_init_with_min_max(&vertices, -1.0f, -1.0f, 1.0f, 1.0f);
    frectangle_rssss_init_with_min_max(&texcoords, 0.0f, 0.0f, resolution, resolution);

    [ varianceRTC bindFBO ];
    [ varianceRTC activateViewport ];

    for ( uint32_t c = 0; c < resolution; c++ )
    {
        [ varianceLUT attachLevel:0
                            layer:c
        renderTargetConfiguration:varianceRTC
                 colorBufferIndex:0
                          bindFBO:NO ];

        if ( c == 0 )
        {
            [ varianceRTC activateDrawBuffers ];
        }

        [ layer setFValue:(float)c ];
        [ variance activate ];
        [ NPIMRendering renderFRectangle:vertices
                               texCoords:texcoords
                           primitiveType:NpPrimitiveQuads ];
    }

    [ varianceRTC deactivate ];
}

@end

@implementation ODVariance

- (id) init
{
    return [ self initWithName:@"ODVariance" ];
}

- (id) initWithName:(NSString *)newName
{
	return [ self initWithName:newName ocean:nil ];
}

- (id) initWithName:(NSString *)newName
			  ocean:(ODOceanEntity *)newOcean
{
	self = [ super initWithName:newName ];

	ocean = newOcean;
	ASSERT_RETAIN(ocean);

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

  useDeltaVariance = lastUseDeltaVariance = NO;

  return self;
}

- (void) dealloc
{
	DESTROY(variance);
	DESTROY(effect);

	DESTROY(varianceLUT);
	DESTROY(varianceRTC);

	DESTROY(ocean);

	[ super dealloc ];
}

- (id < NPPTexture >) texture
{
	return [ varianceLUT texture ];
}

- (void) update
{
	    // update slope variance LUT resolution if necessary
    BOOL forceSlopeVarianceUpdate = NO;
    const uint32_t varianceLUTResolution
        = varianceLUTResolutions[varianceLUTResolutionIndex];

    if ((varianceLUTResolutionIndex != varianceLUTLastResolutionIndex)
        || (useDeltaVariance != lastUseDeltaVariance))
    {
        [ varianceRTC setWidth:varianceLUTResolution ];
        [ varianceRTC setHeight:varianceLUTResolution ];

        NSAssert(
            ([ self
                generateVarianceLUTRenderTarget:varianceLUTResolution
                                          error:NULL ] == YES), @""
            );

        varianceLUTLastResolutionIndex = varianceLUTResolutionIndex;
        lastUseDeltaVariance = useDeltaVariance;
        forceSlopeVarianceUpdate = YES;
    }

    // update slope variance LUT
    if ( [ ocean updateSlopeVariance ] == YES || forceSlopeVarianceUpdate == YES )
    {
        [ self updateSlopeVarianceLUT:varianceLUTResolution ];
    }
}

@end
