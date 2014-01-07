#import "ODOceanTile.h"
#import "NP.h"

@implementation ODOceanTile

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

    resolution = NULL;
    size = windDirection = NULL;

    return self;
}

- (void) dealloc
{
    [ texture release ];

    resolution = iv2_free(resolution);
    size = fv2_free(size);
    windDirection = fv2_free(windDirection);

    [ super dealloc ];
}

- (NPTexture *) texture
{
    return texture;
}

- (BOOL) loadFromFile:(NPFile *)file
{
    resolution    = [ file readIVector2 ];
    size          = [ file readFVector2 ];
    windDirection = [ file readFVector2 ];

    NPLOG(@"Resolution: %d x %d", resolution->x, resolution->y);
    NPLOG(@"Size: %f km x %f km", size->x, size->y);
    NPLOG(@"Wind: ( %f , %f )", windDirection->x, windDirection->y);

    Float time;
    [ file readFloat:&time ];

    UInt elementCount = resolution->x * resolution->y;
    heights = ALLOC_ARRAY(Float, elementCount);
    [ file readFloats:heights withLength:elementCount ];

    texture = [[ NPTexture alloc ] initWithName:@"Heights" parent:self ];

    //[ texture setResolution:resolution ];
    [ texture setWidth:resolution->x ];
    [ texture setHeight:resolution->y ];
    [ texture setDataFormat   :NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT ];
    [ texture setPixelFormat  :NP_GRAPHICS_TEXTURE_PIXELFORMAT_R ];
    [ texture setMipMapping   :NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_INACTIVE ];
    [ texture setTextureFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
    [ texture setTextureWrap  :NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT ];

    NSData * data = [ NSData dataWithBytesNoCopy:heights
                                          length:sizeof(Float)*resolution->x*resolution->y
                                    freeWhenDone:NO ];

    [ texture uploadToGLWithData:data ];

    return YES;
}

@end
