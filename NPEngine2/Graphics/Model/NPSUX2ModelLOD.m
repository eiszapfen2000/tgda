#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
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

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
/*
    [ self setFileName:[ file fileName ] ];

    NSString * lodName = [ file readSUXString ];
    [ self setName: lodName ];
    NPLOG(@"LOD Name: %@", lodName);

    [ file readBool:&autoenable ];
    [ file readFloat:&minDistance ];
    [ file readFloat:&maxDistance ];
    NPLOG(@"Min Distance:%f Max Distance %f",minDistance,maxDistance);

    boundingBoxMinimum = [ file readFVector3 ];
    boundingBoxMaximum = [ file readFVector3 ];
    [ file readFloat:&boundingSphereRadius ];
    NPLOG(@"Bounding Sphere %f",boundingSphereRadius);

    vertexBuffer = [[ NPVertexBuffer alloc ] initWithParent:self ];

    if ( [ vertexBuffer loadFromFile:file ] == NO )
    {
        return NO;
    }

    [ file readInt32:&groupCount ];
    NPLOG(@"Group Count: %d",groupCount);

    for ( Int i = 0; i < groupCount; i++ )
    {
        NPSUXModelGroup * group = [[ NPSUXModelGroup alloc ] initWithParent:self ];

        if ( [ group loadFromFile:file ] == YES )
        {
            [ groups addObject:group ];
        }

        [ group release ];
    }

    ready = YES;

    return YES;
*/

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

    vertexBuffer = [[ NPSUX2VertexBuffer alloc ] init ];

    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    return NO;
}

@end
