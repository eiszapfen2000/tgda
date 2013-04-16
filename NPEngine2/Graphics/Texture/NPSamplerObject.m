#import "Graphics/NPEngineGraphics.h"
#import "NpTextureSamplerParameter.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPSamplerObject.h"

void reset_sampler_filterstate(NpSamplerFilterState * filterState)
{
    filterState->minFilter = NpTextureMinFilterNearest;
    filterState->magFilter = NpTextureMagFilterNearest;
    filterState->anisotropy = 1;
}

void reset_sampler_wrapstate(NpSamplerWrapState * wrapState)
{
    wrapState->wrapS = NpTextureWrapToEdge;
    wrapState->wrapT = NpTextureWrapToEdge;
    wrapState->wrapR = NpTextureWrapToEdge;
}

@implementation NPSamplerObject

- (id) init
{
    return [ self initWithName:@"Sampler Object" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    if ( [[ NPEngineGraphics instance ] supportsSamplerObjects ] == NO )
    {
        RELEASE(self);
        return nil;
    }

    glGenSamplers(1, &glID);
    [ self reset ];

    return self;
}

- (void) dealloc
{
    if (glID > 0 )
    {
        glDeleteSamplers(1, &glID);
        glID = 0;
    }

    [ super dealloc ];
}

- (GLuint) glID
{
    return glID;
}

- (void) clear
{
    [ self reset ];
}

- (void) reset
{
    reset_sampler_filterstate(&filterState);
    reset_sampler_wrapstate(&wrapState);

    set_sampler_filter(glID, filterState.minFilter, filterState.magFilter);
    set_sampler_anisotropy(glID, filterState.anisotropy);
    set_sampler_wrap(glID, wrapState.wrapS, wrapState.wrapT, wrapState.wrapR);
}

- (void) setTextureFilter:(NpSamplerFilterState)newTextureFilter
{
    if ( filterState.minFilter != newTextureFilter.minFilter
         || filterState.magFilter != newTextureFilter.magFilter
         || filterState.anisotropy != newTextureFilter.anisotropy )
    {
        filterState = newTextureFilter;
        set_sampler_filter(glID, filterState.minFilter, filterState.magFilter);
    }
}

- (void) setTextureWrap:(NpSamplerWrapState)newTextureWrap
{
    if ( wrapState.wrapS != newTextureWrap.wrapS
         || wrapState.wrapT != newTextureWrap.wrapT
         || wrapState.wrapR != newTextureWrap.wrapR)
    {
        wrapState = newTextureWrap;
        set_sampler_wrap(glID, wrapState.wrapS, wrapState.wrapT, wrapState.wrapR);
    }
}

- (void) setTextureAnisotropy:(uint32_t)newTextureAnisotropy
{
    filterState.anisotropy
        = MAX(1, MIN(newTextureAnisotropy,
                         (uint32_t)[[ NPEngineGraphics instance ] maximumAnisotropy ]));

    set_sampler_anisotropy(glID, filterState.anisotropy);
}

@end

