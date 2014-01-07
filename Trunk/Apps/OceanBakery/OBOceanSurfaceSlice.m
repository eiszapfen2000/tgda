#import "OBOceanSurfaceSlice.h"
#import "Core/File/NPFile.h"

@implementation OBOceanSurfaceSlice

- (id) init
{
    return [ self initWithName:@"Ocean Surface Slice" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

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

- (void) setTime:(Float)newTime
{
    time = newTime;
}

- (void) setHeights:(Float *)newHeights elementCount:(UInt)count
{
    heights = newHeights;
    elementCount = count;    
}

- (void) saveToFile:(NPFile *)file
{
    if ( heights != NULL )
    {
        [ file writeFloat:&time ];
        [ file writeFloats:heights withLength:elementCount ];
    }
}

@end
