#import "ODOceanAnimatedTile.h"
#import "NP.h"

@implementation ODOceanAnimatedTile

- (id) init
{
    return [ self initWithName:@"ODOceanTile" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    resolution = iv2_alloc_init();
    size = fv2_alloc_init();
    windDirection = fv2_alloc_init();

    textures2D = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ textures2D removeAllObjects ];
    [ textures2D release ];

    resolution = iv2_free(resolution);
    size = fv2_free(size);
    windDirection = fv2_free(windDirection);

    [ super dealloc ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    resolution = [ file readIVector2 ];
    size = [ file readFVector2 ];
    windDirection = [ file readFVector2 ];

    [ file readUInt32:&numberOfSlices ];

    NPLOG(@"Resolution: %d x %d", resolution->x, resolution->y);
    NPLOG(@"Size: %f km x %f km", size->x, size->y);
    NPLOG(@"Wind: ( %f , %f )", windDirection->x, windDirection->y);
    NPLOG(@"Number of slices: %u", numberOfSlices);

    times   = ALLOC_ARRAY(Float  , numberOfSlices);
    heights = ALLOC_ARRAY(Float *, numberOfSlices);

    UInt elementCount = resolution->x * resolution->y;

    for ( UInt i = 0; i < numberOfSlices; i++ )
    {
        heights[i] = ALLOC_ARRAY(Float, elementCount);
        UInt32 slice;
        [ file readUInt32:&slice ];
        [ file readFloat:&(times[i]) ];
        [ file readFloats:heights[i] withLength:elementCount ];
    }

    for ( UInt i = 0; i < numberOfSlices; i++ )
    {
        NPTexture * texture = [[ NPTexture alloc ] initWithName:[NSString stringWithFormat:@"Slice%d", i]
                                                         parent:self ];
        [ texture setResolution:resolution ];
        [ texture setDataFormat   :NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT ];
        [ texture setPixelFormat  :NP_GRAPHICS_TEXTURE_PIXELFORMAT_R ];
        [ texture setMipMapping   :NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_INACTIVE ];
        [ texture setTextureFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
        [ texture setTextureWrap  :NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT ];

        NSData * data = [ NSData dataWithBytesNoCopy:heights[i] 
                                              length:sizeof(Float)*resolution->x*resolution->y
                                        freeWhenDone:NO ];

        [ texture uploadToGLWithData:data ];
        [ textures2D addObject:texture ];
        [ texture release ];
    }

    return YES;
}

@end
