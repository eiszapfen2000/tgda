#import "Core/File/NPFile.h"
#import "OBOceanSurface.h"
#import "OBOceanSurfaceSlice.h"

@implementation OBOceanSurface

- (id) init
{
    return [ self initWithName:@"Ocean Surface" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    resolution = iv2_alloc_init();
    size = fv2_alloc_init();
    windDirection = fv2_alloc_init();
    slices = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ slices removeAllObjects ];
    [ slices release ];

    iv2_free(resolution);

    [ super dealloc ];
}

- (void) setResolution:(IVector2 *)newResolution
{
    *resolution = *newResolution;
}

- (void) setSize:(FVector2 *)newSize
{
    *size = *newSize;
}

- (void) setWindDirection:(FVector2 *)newWindDirection
{
    *windDirection = *newWindDirection;
}

- (void) addSlice:(OBOceanSurfaceSlice *)slice
{
    [ slices addObject:slice ];
    [ slice setParent:self ];
}

- (void) saveToFile:(NPFile *)file
{
    [ file writeSUXString:@"OceanSurface" ];

    UInt32 numberOfSlices = [ slices count ];
    NSAssert(numberOfSlices > 0, @"No Slices");

    BOOL animated = NO;
    if ( numberOfSlices > 1 )
    {
        animated = YES;
    }

    [ file writeBool:&animated ];

    [ file writeIVector2:resolution ];
    [ file writeFVector2:size ];
    [ file writeFVector2:windDirection ];

    if ( animated == NO )
    {
        [[ slices objectAtIndex:0 ] saveToFile:file ];
    }
    else
    {
        [ file writeUInt32:&numberOfSlices ];

        NSEnumerator * sliceEnumerator = [ slices objectEnumerator ];
        OBOceanSurfaceSlice * slice;

        while (( slice = [ sliceEnumerator nextObject ] ))
        {
            UInt32 index = [ slices indexOfObject:slice ];
            [ file writeUInt32:&index ];

            [ slice saveToFile:file ];
        }
    }
}

@end
