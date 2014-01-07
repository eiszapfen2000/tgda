#import <Foundation/NSException.h>
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

    time = 0.0f;
    numberOfHeightElements = 0;
    heights = NULL;

    return self;
}

- (void) dealloc
{
    SAFE_FREE(heights);

    [ super dealloc ];
}

- (void) setTime:(double)newTime
{
    time = newTime;
}

- (void) setHeights:(double *)newHeights
   numberOfElements:(size_t)numberOfElements
{
    heights = newHeights;
    numberOfHeightElements = numberOfElements;    
}

- (BOOL) writeToStream:(id <NPPStream>)stream
                 error:(NSError **)error
{
    NSAssert(heights != NULL, @"Invalid heights array");

    BOOL result = [ stream writeFloat:time ];

    return ( result &&
                [ stream writeElements:heights 
                         elementSize:sizeof(double)
                    numberOfElements:numberOfHeightElements ] );
}

@end
