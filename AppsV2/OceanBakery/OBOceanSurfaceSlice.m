#import "Core/File/NPFile.h"
#import "OBOceanSurfaceSlice.h"

@implementation OBOceanSurfaceSlice

- (id) init
{
    return [ self initWithName:@"OB Surface Slice" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    elementCount = 0;
    time = 0.0f;
    heights = NULL;

    return self;
}

- (void) dealloc
{
    SAFE_FREE(heights);

    [ super dealloc ];
}

- (void) setTime:(float)newTime
{
    time = newTime;
}

- (void) setHeights:(float *)newHeights
       elementCount:(uint32_t)count
{
    heights = newHeights;
    elementCount = count;    
}

- (void) saveToFile:(NPFile *)file
{
    if ( heights != NULL )
    {
        [ file writeFloat:time ];

        #warning FIXME write array to stream
        //[ file writeFloats:heights withLength:elementCount ];
    }
}

@end
