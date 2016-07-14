#import "Graphics/Texture/NpTextureSamplerParameter.h"
#import "NPEffectVariable.h"

@class NPSamplerObject;

@interface NPEffectVariableSampler : NPEffectVariable
{
    uint32_t texelUnit;

    NpSamplerFilterState filterState;
    NpSamplerWrapState wrapState;
    NPSamplerObject * samplerObject;
}

- (id) initWithName:(NSString *)newName
          texelUnit:(uint32_t)newTexelUnit
                   ;

- (uint32_t) texelUnit;
- (NpSamplerFilterState) filterState;
- (NpSamplerWrapState) wrapState;
- (NPSamplerObject *) samplerObject;

- (void) setFilterState:(NpSamplerFilterState)newFilterState;
- (void) setWrapState:(NpSamplerWrapState)newWrapState;

@end
