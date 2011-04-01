#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import "Core/File/NPFile.h"
#import "OBOceanSurfaceSlice.h"
#import "OBOceanSurface.h"

@implementation OBOceanSurface

- (id) init
{
    return [ self initWithName:@"Ocean Surface" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    resolution.x = resolution.y = 0;
    size.x = size.y = 0.0f;
    windDirection.x = windDirection.y = 0.0f;

    slices = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ slices removeAllObjects ];
    DESTROY(slices);

    [ super dealloc ];
}

- (void) setResolution:(const IVector2)newResolution
{
    resolution = newResolution;
}

- (void) setSize:(const FVector2)newSize
{
    size = newSize;
}

- (void) setWindDirection:(const FVector2)newWindDirection
{
    windDirection = newWindDirection;
}

- (void) addSlice:(OBOceanSurfaceSlice *)slice
{
    [ slices addObject:slice ];
    //[ slice setParent:self ];
}

- (void) saveToFile:(NPFile *)file
{
    [ file writeSUXString:@"OceanSurface" ];

    NSUInteger numberOfSlices = [ slices count ];
    NSAssert(numberOfSlices > 0, @"No Slices");

    BOOL animated = NO;
    if ( numberOfSlices > 1 )
    {
        animated = YES;
    }

    [ file writeBool:animated ];

    [ file writeIVector2:resolution ];
    [ file writeFVector2:size ];
    [ file writeFVector2:windDirection ];

    if ( animated == NO )
    {
        [[ slices objectAtIndex:0 ] saveToFile:file ];
    }
    else
    {
        [ file writeUInt32:(uint32_t)numberOfSlices ];

        NSEnumerator * sliceEnumerator = [ slices objectEnumerator ];
        OBOceanSurfaceSlice * slice;

        while (( slice = [ sliceEnumerator nextObject ] ))
        {
            uint32_t index = [ slices indexOfObject:slice ];
            [ file writeUInt32:index ];

            [ slice saveToFile:file ];
        }
    }
}

@end
