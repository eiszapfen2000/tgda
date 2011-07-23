#import <Foundation/NSException.h>
#import "ODPerlinNoise.h"

static Vector3 gradients[12] =
{
    {1.0, 1.0, 0.0}, {-1.0,  1.0, 0.0}, {1.0, -1.0,  0.0}, {-1.0, -1.0,  0.0},
    {1.0, 0.0, 1.0}, {-1.0,  0.0, 1.0}, {1.0,  0.0, -1.0}, {-1.0,  0.0, -1.0},
    {0.0, 1.0, 1.0}, { 0.0, -1.0, 1.0}, {0.0,  1.0, -1.0}, { 0.0, -1.0, -1.0}
};

static double fade(const double t)
{
    return t * t * t * (t * (6.0 * t - 15.0) + 10.0);
}

static double lerp(const double a, const double b, const double t)
{
    return a + t * (b - a);
}

static double generate(const uint32_t size, const uint32_t * const permutationTable,
    const Vector3 c)
{
    #warning FIXME fit input coordinates into size

    // grid coordinates
    const double xid = floor(c.x);
    const double yid = floor(c.y);
    const double zid = floor(c.z);

    const int32_t xi = (int32_t)xid;
    const int32_t yi = (int32_t)yid;
    const int32_t zi = (int32_t)zid;

    // fade function
    const double u = fade(c.x - xid);
    const double v = fade(c.y - yid);
    const double w = fade(c.z - zid);

    // gradient lookup indices
    const uint32_t q00  = (permutationTable[xi]     + yi) % size;
    const uint32_t q10  = (permutationTable[xi + 1] + yi) % size;

    const uint32_t q000  = (permutationTable[q00] + zi) % size;
    const uint32_t q100  = (permutationTable[q10] + zi) % size;
    const uint32_t q010  = (permutationTable[q00 + 1] + zi) % size;
    const uint32_t q110  = (permutationTable[q10 + 1] + zi) % size;

    const uint32_t q001 = (permutationTable[q00] + zi + 1) % size;
    const uint32_t q101 = (permutationTable[q10] + zi + 1) % size;
    const uint32_t q011 = (permutationTable[q00 + 1] + zi + 1) % size;
    const uint32_t q111 = (permutationTable[q10 + 1] + zi + 1) % size;

    // gradients
    const Vector3 g000 = gradients[permutationTable[q000] % 12];
    const Vector3 g100 = gradients[permutationTable[q100] % 12];
    const Vector3 g010 = gradients[permutationTable[q010] % 12];
    const Vector3 g110 = gradients[permutationTable[q110] % 12];
    const Vector3 g001 = gradients[permutationTable[q001] % 12];
    const Vector3 g101 = gradients[permutationTable[q101] % 12];
    const Vector3 g011 = gradients[permutationTable[q011] % 12];
    const Vector3 g111 = gradients[permutationTable[q111] % 12];

    // directions to cube corners
    const Vector3 d000 = {c.x - xid,       c.y - yid,       c.z - zid      };
    const Vector3 d100 = {c.x - xid - 1.0, c.y - yid,       c.z - zid      };
    const Vector3 d010 = {c.x - xid,       c.y - yid - 1.0, c.z - zid      };
    const Vector3 d110 = {c.x - xid - 1.0, c.y - yid - 1.0, c.z - zid      };
    const Vector3 d001 = {c.x - xid,       c.y - yid,       c.z - zid - 1.0};
    const Vector3 d101 = {c.x - xid - 1.0, c.y - yid,       c.z - zid - 1.0};
    const Vector3 d011 = {c.x - xid,       c.y - yid - 1.0, c.z - zid - 1.0};
    const Vector3 d111 = {c.x - xid - 1.0, c.y - yid - 1.0, c.z - zid - 1.0};

    return 
        lerp(lerp(lerp(v3_vv_dot_product(&g000, &d000), v3_vv_dot_product(&g100, &d100), u),
                  lerp(v3_vv_dot_product(&g010, &d010), v3_vv_dot_product(&g110, &d110), u),
                  v),
             lerp(lerp(v3_vv_dot_product(&g001, &d001), v3_vv_dot_product(&g101, &d101), u),
                  lerp(v3_vv_dot_product(&g011, &d011), v3_vv_dot_product(&g111, &d111), u),
                  v),
             w);
}

@interface ODPerlinNoise (Private)

- (void) generatePermutationTable;

@end

@implementation ODPerlinNoise (Private)

- (void) generatePermutationTable
{
    SAFE_FREE(permutationTable);
    permutationTable = ALLOC_ARRAY(uint32_t, size);

    for ( uint32_t i = 0; i < size; i++ )
    {
        permutationTable[i] = i;
    }

    for ( uint32_t i = 0; i < size; i++ )
    {
        uint32_t j = (uint32_t)rand() % size;
        uint32_t temp = permutationTable[i];
        permutationTable[i] = permutationTable[j];
        permutationTable[j] = temp;
    }
}

@end

@implementation ODPerlinNoise

- (id) init
{
    return [ self initWithName:@"ODPerlinNoise" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName size:256 ];
}

- (id) initWithName:(NSString *)newName
               size:(const uint32_t)newSize
{
    self =  [ super initWithName:newName ];

    size = newSize;
    [ self generatePermutationTable ];

    return self;
}

- (void) dealloc
{
    SAFE_FREE(permutationTable);

    [ super dealloc ];
}

- (uint32_t) size
{
    return size;
}

- (void) setSize:(const uint32_t)newSize
{
    if ( size != newSize )
    {
        size = newSize;
        [ self generatePermutationTable ];
    }
}

- (void) generate
{
    SAFE_FREE(noise);
    noise = ALLOC_ARRAY(double, 8*8);

    /*
    Vector3 c;

    for ( uint32_t i = 0; i < 8; i++ )
    {
        for ( uint32_t j = 0; j < 8; j++ )
        {
            c.x = i * 0.25;
            c.y = j * 0.35;
            c.z = -1.0;
            noise[i*size+j] = generate(size, permutationTable, c);
            NSLog(@"%f", noise[i*size+j]);
        }
    }
    */
}

@end

