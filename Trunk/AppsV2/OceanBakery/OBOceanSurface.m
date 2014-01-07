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
    size.x = size.y = 0.0;
    windDirection.x = windDirection.y = 0.0;

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

- (void) setSize:(const Vector2)newSize
{
    size = newSize;
}

- (void) setWindDirection:(const Vector2)newWindDirection
{
    windDirection = newWindDirection;
}

- (void) addSlice:(OBOceanSurfaceSlice *)slice
{
    [ slices addObject:slice ];
}

- (BOOL) writeToStream:(id <NPPStream>)stream
                 error:(NSError **)error
{
    NSUInteger numberOfSlices = [ slices count ];
    NSAssert(numberOfSlices > 0, @"No Slices");

    BOOL result = [ stream writeSUXString:@"OceanSurface" ];
    result = result && [ stream writeIVector2:resolution ];
    result = result && [ stream writeVector2:size ];
    result = result && [ stream writeVector2:windDirection ];

    if ( result == NO )
    {
        fprintf(stdout, "Error writing file header\n");
        return NO;
    }

    result = YES;

    for ( NSUInteger i = 0; (i < numberOfSlices) && (result == YES); i++ )
    {
        result = result && [ stream writeUInt32:i ];
        result = result &&
                    [[ slices objectAtIndex:i ]
                              writeToStream:stream
                                      error:error ];
    }

    if ( result == NO )
    {
        fprintf(stdout, "Error writing heightfield data\n");
    }

    return result;
}

@end
