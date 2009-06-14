#import "NP.h"
#import "RTVCore.h"
#import "RTVArbitraryBoundaries.h"

@implementation RTVArbitraryBoundaries

- (id) init
{
    return [ self initWithName:@"ArbitraryBoundaries" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    currentResolution   = iv2_alloc_init();
    resolutionLastFrame = iv2_alloc_init();

    innerQuadUpperLeft  = fv2_alloc_init();
    innerQuadLowerRight = fv2_alloc_init();
    pixelSize = fv2_alloc_init();

    arbitraryBoundariesEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Advection.cgfx" ];
    arbitraryBoundariesRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"ArbitraryBoundariesRT" parent:self ];

    [ self setupScaleAndOffsetTextures ];

    return self;
}

- (void) dealloc
{
    iv2_free(currentResolution);
    iv2_free(resolutionLastFrame);

    fv2_free(innerQuadUpperLeft);
    fv2_free(innerQuadUpperLeft);
    fv2_free(pixelSize);

    [ arbitraryBoundariesRenderTargetConfiguration clear ];
    [ arbitraryBoundariesRenderTargetConfiguration release ];

    [ super dealloc ];
}

- (void) setupScaleAndOffsetTextures
{
    if ( velocityScaleAndOffset != nil )
    {
        DESTROY(velocityScaleAndOffset);
    }

    if ( pressureScaleAndOffset != nil )
    {
        DESTROY(pressureScaleAndOffset);
    }

    velocityScaleAndOffset = [[[ NP Graphics ] textureManager ] createTextureWithName:@"VelScaleOffset"
                                                                                width:34
                                                                                height:1
                                                                            dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                                           pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ];

    pressureScaleAndOffset = [[[ NP Graphics ] textureManager ] createTextureWithName:@"PreScaleOffset"
                                                                                width:34
                                                                                height:1
                                                                            dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                                           pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ];

    [ velocityScaleAndOffset setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [ velocityScaleAndOffset setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [ velocityScaleAndOffset setTextureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];
    [ velocityScaleAndOffset setTextureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    [ pressureScaleAndOffset setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [ pressureScaleAndOffset setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [ pressureScaleAndOffset setTextureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];
    [ pressureScaleAndOffset setTextureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    Float velocityData[136] = 
    {
     // This cell is a fluid cell
     1,  0,  1,  0,   // Free (no neighboring boundaries)
     0,  0, -1,  1,   // East (a boundary to the east)
     1,  0,  1,  0,   // Unused
     1,  0,  0,  0,   // North
     0,  0,  0,  0,   // Northeast
     1,  0,  1,  0,   // South
     0,  0,  1,  0,   // Southeast
     1,  0,  1,  0,   // West
     1,  0,  1,  0,   // Unused
     0,  0,  0,  0,   // surrounded (3 neighbors)
     1,  0,  0,  0,   // Northwest
     0,  0,  0,  0,   // surrounded (3 neighbors)
     1,  0,  1,  0,   // Southwest 
     0,  0,  0,  0,   // surrounded (3 neighbors)
     0,  0,  0,  0,   // Unused
     0,  0,  0,  0,   // surrounded (3 neighbors)
     0,  0,  0,  0,   // surrounded (4 neighbors)
     // This cell is a boundary cell (the inverse of above!)
     1,  0,  1,  0,   // No neighboring boundaries (Error)
     0,  0,  0,  0,   // Unused
     0,  0,  0,  0,   // Unused
     0,  0,  0,  0,   // Unused
    -1, -1, -1, -1,   // Southwest 
     0,  0,  0,  0,   // Unused
    -1,  1,  0,  0,   // Northwest
     0,  0,  0,  0,   // Unused
     0,  0,  0,  0,   // Unused
     0,  0, -1, -1,   // West
     0,  0, -1,  1,   // Southeast
    -1, -1,  0,  0,   // South
     0,  0,  0,  0,   // Northeast
    -1,  1,  0,  0,   // North
     0,  0,  0,  0,   // Unused
     0,  0, -1,  1,   // East (a boundary to the east)
     0,  0,  0,  0    // Unused
    };

    [ velocityScaleAndOffset uploadToGLWithData:[NSData dataWithBytesNoCopy:velocityData length:sizeof(velocityData) freeWhenDone:NO ]];

    Float pressureData[136] = 
    {
    // This cell is a fluid cell
     0,  0,  0,  0,   // Free (no neighboring boundaries)
     0,  0,  0,  0,   // East (a boundary to the east)
     0,  0,  0,  0,   // Unused
     0,  0,  0,  0,   // North
     0,  0,  0,  0,   // Northeast
     0,  0,  0,  0,   // South
     0,  0,  0,  0,   // Southeast
     0,  0,  0,  0,   // West
     0,  0,  0,  0,   // Unused
     0,  0,  0,  0,   // Landlocked (3 neighbors)
     0,  0,  0,  0,   // Northwest
     0,  0,  0,  0,   // Landlocked (3 neighbors)
     0,  0,  0,  0,   // Southwest 
     0,  0,  0,  0,   // Landlocked (3 neighbors)
     0,  0,  0,  0,   // Unused
     0,  0,  0,  0,   // Landlocked (3 neighbors)
     0,  0,  0,  0,   // Landlocked (4 neighbors)
     // This cell is a boundary cell (the inverse of above!)
     0,  0,  0,  0,   // no neighboring boundaries
     0,  0,  0,  0,   // unused
     0,  0,  0,  0,   // unused
     0,  0,  0,  0,   // unused
    -1,  0,  0, -1,   // Southwest 
     0,  0,  0,  0,   // unused
    -1,  0,  0,  1,   // Northwest
     0,  0,  0,  0,   // Unused
     0,  0,  0,  0,   // Unused
    -1,  0, -1,  0,   // West
     0, -1,  1,  0,   // Southeast
     0, -1,  0, -1,   // South
     0,  1,  1,  0,   // Northeast
     0,  1,  0,  1,   // North
     0,  0,  0,  0,   // Unused
     1,  0,  1,  0,   // East (a boundary to the east)
     0,  0,  0,  0   // Unused
    };

    [ pressureScaleAndOffset uploadToGLWithData:[NSData dataWithBytesNoCopy:pressureData length:sizeof(pressureData) freeWhenDone:NO ]];
}

- (IVector2) resolution
{
    return *currentResolution;
}

- (void) setResolution:(IVector2)newResolution
{
    currentResolution->x = newResolution.x;
    currentResolution->y = newResolution.y;
}

- (void) updateInnerQuadCoordinates
{
    pixelSize->x = 1.0f/(Float)(currentResolution->x);
    pixelSize->y = 1.0f/(Float)(currentResolution->y);

    innerQuadUpperLeft->x  = pixelSize->x;
    innerQuadUpperLeft->y  = 1.0f - pixelSize->y;
    innerQuadLowerRight->x = 1.0f - pixelSize->x;
    innerQuadLowerRight->y = pixelSize->y;
}

- (void) update:(Float)frameTime
{
    if ( (currentResolution->x != resolutionLastFrame->x) || (currentResolution->y != resolutionLastFrame->y) )
    {
        [ self updateInnerQuadCoordinates ];

        [ arbitraryBoundariesRenderTargetConfiguration setWidth :currentResolution->x ];
        [ arbitraryBoundariesRenderTargetConfiguration setHeight:currentResolution->y ];

        resolutionLastFrame->x = currentResolution->x;
        resolutionLastFrame->y = currentResolution->y;
    }
}

- (void) render
{

}

@end
