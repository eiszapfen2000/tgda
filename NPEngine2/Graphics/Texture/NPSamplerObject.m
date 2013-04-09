#import "NPSamplerObject.h"

void reset_sampler2d_filterstate(NpSampler2DFilterState * filterState)
{
    filterState->textureFilter = NpTexture2DFilterNearest;
    filterState->anisotropy = 1;
}

void reset_sampler2d_wrapstate(NpSampler2DWrapState * wrapState)
{
    wrapState->wrapS = NpTextureWrapToEdge;
    wrapState->wrapT = NpTextureWrapToEdge;
}

@implementation NPSamplerObject

- (id) init
{
    return [ self initWithName:@"Sampler Object" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

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

- (void) clear
{
    [ self reset ];
}

- (void) reset
{
    reset_sampler2d_filterstate(&filterState);
    reset_sampler2d_wrapstate(&wrapState);
}

@end

