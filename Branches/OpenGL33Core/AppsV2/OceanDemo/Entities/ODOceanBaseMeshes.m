#import "Foundation/NSArray.h"
#import "Foundation/NSException.h"
#import "ODOceanBaseMesh.h"
#import "ODOceanBaseMeshes.h"

@implementation ODOceanBaseMeshes

- (id) init
{
    return [ self initWithName:@"ODOceanBaseMeshes" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    meshes = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ meshes removeAllObjects ];
    DESTROY(meshes);

    [ super dealloc ];
}

- (ODOceanBaseMesh *) meshAtIndex:(NSUInteger)index
{
    return [ meshes objectAtIndex:index ];
}

- (BOOL) generateWithResolutions:(const int32_t *)resolutions
             numberOfResolutions:(int32_t)numberOfResolutions
{
    NSAssert(resolutions != NULL, @"");
    NSAssert(numberOfResolutions > 0, @"");

    BOOL success = YES;

    for ( int32_t i = 0; i < numberOfResolutions; i++ )
    {
        ODOceanBaseMesh * mesh = [[ ODOceanBaseMesh alloc ] init ];
        success = success && [ mesh generateWithResolution:resolutions[i] ];
        [ meshes addObject:mesh ];
        DESTROY(mesh);
    }

    return success;
}

- (void) updateMeshAtIndex:(NSUInteger)index
                 withYData:(NSData *)yData
          supplementalData:(NSData *)supplementalData
{
    [[ meshes objectAtIndex:index ] updateYStream:yData supplementalStream:supplementalData ];
}

- (void) renderMeshAtIndex:(NSUInteger)index
{
    [[ meshes objectAtIndex:index ] render ];
}

@end

