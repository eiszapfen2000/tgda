#import "Graphics/NPEngineGraphics.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPSamplerObject.h"

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

    set_sampler_filterstate(glID, filterState);
    set_sampler_wrapstate(glID, wrapState);
}

- (void) setTextureFilter:(NpSamplerFilterState)newTextureFilter
{
    if ( filterState.minFilter != newTextureFilter.minFilter
         || filterState.magFilter != newTextureFilter.magFilter
         || filterState.anisotropy != newTextureFilter.anisotropy )
    {
        filterState = newTextureFilter;
        set_sampler_filterstate(glID, filterState);;
    }
}

- (void) setTextureWrap:(NpSamplerWrapState)newTextureWrap
{
    if ( wrapState.wrapS != newTextureWrap.wrapS
         || wrapState.wrapT != newTextureWrap.wrapT
         || wrapState.wrapR != newTextureWrap.wrapR)
    {
        wrapState = newTextureWrap;
        set_sampler_wrapstate(glID, wrapState);;
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

