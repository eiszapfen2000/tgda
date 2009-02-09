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
    IVector2 tmp = { 0, 0 };

    return [ self initWithName:newName parent:newParent resolution:&tmp ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent resolution:(IVector2 *)newResolution
{
    self = [ super initWithName:newName parent:newParent ];

    resolution = iv2_alloc_init_with_iv2(newResolution);
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

- (void) addSlice:(OBOceanSurfaceSlice *)slice
{
    [ slices addObject:slice ];
    [ slice setParent:self ];
}

- (void) saveToFile:(NPFile *)file
{
    [ file writeSUXString:@"OceanSurface" ];
    [ file writeInt32:&(resolution->x) ];
    [ file writeInt32:&(resolution->y) ];

    UInt32 numberOfSlices = [ slices count ];
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

@end
