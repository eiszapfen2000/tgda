#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "NPSUX2ModelGroup.h"
#import "NPSUX2ModelLOD.h"

@implementation NPSUX2ModelLOD

- (id) init
{
    return [ self initWithName:@"SUX2 Model LOD" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    file = nil;
    ready = NO;

    autoenable = NO;
    minDistance = 0.0f;
    maxDistance = 0.0f;

    fv3_v_init_with_zeros(&boundingBoxMinimum);
    fv3_v_init_with_zeros(&boundingBoxMaximum);
    boundingSphereRadius = 0.0f;

    vertexBuffer = nil;
    groups = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ groups removeAllObjects ];
    SAFE_DESTROY(groups);
    SAFE_DESTROY(vertexBuffer);

    [ super dealloc ];
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return ready;
}

- (NPSUX2VertexBuffer *) vertexBuffer
{
    return vertexBuffer;
}

- (NPSUX2Model *) model
{
    return model;
}

- (NPSUX2ModelGroup *) groupAtIndex:(const NSUInteger)index
{
    return [ groups objectAtIndex:index ];
}

- (void) setModel:(NPSUX2Model *)newModel
{
    // weak reference
    model = newModel;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    NSString * lodName;
    [ stream readSUXString:&lodName ];
    [ self setName: lodName ];
    NPLOG(@"LOD Name: %@", lodName);

    [ stream readBool:&autoenable ];
    [ stream readFloat:&minDistance ];
    [ stream readFloat:&maxDistance ];
    NPLOG(@"Min Distance:%f Max Distance %f", minDistance, maxDistance);

    [ stream readFVector3:&boundingBoxMinimum ];
    [ stream readFVector3:&boundingBoxMaximum ];

    const char * minString = fv3_v_to_string(&boundingBoxMinimum);
    const char * maxString = fv3_v_to_string(&boundingBoxMaximum);

    NPLOG(@"BBox Min %s", minString);
    NPLOG(@"BBox Max %s", maxString);

    SAFE_FREE(minString);
    SAFE_FREE(maxString);

    [ stream readFloat:&boundingSphereRadius ];
    NPLOG(@"Bounding Sphere %f", boundingSphereRadius);

    SAFE_DESTROY(vertexBuffer);

    vertexBuffer = [[ NPSUX2VertexBuffer alloc ] init ];

    if ( [ vertexBuffer loadFromStream:stream error:error ] == NO )
    {
        return NO;
    }

    int32_t numberOfGroups = 0;
    [ stream readInt32:&numberOfGroups ];
    NPLOG(@"Group Count: %d", numberOfGroups);

    for ( int32_t i = 0; i < numberOfGroups; i++ )
    {
        NPSUX2ModelGroup * group = [[ NPSUX2ModelGroup alloc ] init ];
        [ group setLod:self ];

        if ( [ group loadFromStream:stream error:NULL ] == YES )
        {
            [ groups addObject:group ];
        }

        DESTROY(group);
    }

    ready = ([ groups count ] != 0);

    return YES;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    return NO;
}

- (void) render
{
    [ self renderWithMaterial:YES ];
}

- (void) renderWithMaterial:(BOOL)renderMaterial
{
    if ( ready == NO )
    {
        NPLOG(@"LOD not ready");
        return;
    }

    NSUInteger numberOfGroups = [ groups count ];
    for ( NSUInteger i = 0; i < numberOfGroups; i++ )
    {
        [[ groups objectAtIndex:i ] renderWithMaterial:renderMaterial ];
    }
}

@end
