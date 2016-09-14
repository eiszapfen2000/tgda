#import "Graphics/Texture/NPSamplerObject.h"
#import "Graphics/Texture/NPTextureSamplingState.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPEffectTechniqueVariable.h"
#import "NPEffectVariableSampler.h"

@implementation NPEffectVariableSampler

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
          texelUnit:(uint32_t)newTexelUnit
{
    self = [ super initWithName:newName
                   variableType:NpEffectVariableTypeSampler ];

    texelUnit = newTexelUnit;

    reset_sampler_filterstate(&filterState);
    reset_sampler_wrapstate(&wrapState);

    samplerObject = [[ NPSamplerObject alloc ] initWithName:newName ];

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(samplerObject);

    [ super dealloc ];
}

- (uint32_t) texelUnit
{
    return texelUnit;
}

- (NpSamplerFilterState) filterState
{
    return filterState;
}

- (NpSamplerWrapState) wrapState
{
    return wrapState;
}

- (NPSamplerObject *) samplerObject
{
    return samplerObject;
}

- (void) setFilterState:(NpSamplerFilterState)newFilterState
{
    filterState = newFilterState;

    if ( samplerObject != nil )
    {
        [ samplerObject setTextureFilter:filterState ];
    }
}

- (void) setWrapState:(NpSamplerWrapState)newWrapState
{
    wrapState = newWrapState;

    if ( samplerObject != nil )
    {
        [ samplerObject setTextureWrap:wrapState ];
    }
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    GLint location = [ variable location ];
    glUniform1i(location, (GLint)texelUnit);

    if ( samplerObject != nil )
    {
        [[[ NPEngineGraphics instance ]
                textureSamplingState ] setSampler:samplerObject texelUnit:texelUnit ];
    }
}

@end
