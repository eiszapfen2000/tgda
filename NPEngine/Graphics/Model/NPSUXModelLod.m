#import "NPSUXModelLod.h"
#import "NPSUXModelGroup.h"
#import "NPVertexBuffer.h"
#import "Core/NPEngineCore.h"

@implementation NPSUXModelLod

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"SUX Model LOD" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    autoenable = NO;
    minDistance = 0;
    maxDistance = 0;

    boundingBoxMinimum = NULL;
    boundingBoxMaximum = NULL;
    boundingSphereRadius = 0;

    vertexBuffer = nil;

    groupCount = 0;
    groups = [ [ NSMutableArray alloc ] init ];

    return self;
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    NSString * lodName = [ file readSUXString ];
    [ self setName: lodName ];
    [ lodName release ];
    NPLOG(([NSString stringWithFormat:@"LOD Name: %@", lodName]));

    [ file readBool:&autoenable ];
    [ file readFloat:&minDistance ];
    [ file readFloat:&maxDistance ];
    NPLOG(([NSString stringWithFormat:@"Min Distance:%f Max Distance %f",minDistance,maxDistance]));

    boundingBoxMinimum = [ file readFVector3 ];
    boundingBoxMaximum = [ file readFVector3 ];
    [ file readFloat:&boundingSphereRadius ];
    NPLOG(([NSString stringWithFormat:@"Bounding Sphere %f",boundingSphereRadius]));

    vertexBuffer = [ [ NPVertexBuffer alloc ] initWithParent:self ];

    if ( [ vertexBuffer loadFromFile:file ] == NO )
    {
        return NO;
    }

    [ file readInt32:&groupCount ];
    NPLOG(([NSString stringWithFormat:@"Group Count: %d",groupCount]));

    for ( Int i = 0; i < groupCount; i++ )
    {
        NPSUXModelGroup * group = [ [ NPSUXModelGroup alloc ] initWithParent:self ];

        if ( [ group loadFromFile:file ] == YES )
        {
            [ groups addObject:group ];
        }

        [ group release ];
    }

    return YES;
}

- (void) reset
{
    [ vertexBuffer release ];
    [ groups removeAllObjects ];

    autoenable = NO;
    minDistance = 0;
    maxDistance = 0;

    FREE(boundingBoxMinimum);
    FREE(boundingBoxMaximum);
    boundingSphereRadius = 0;
    groupCount = 0;

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}

- (NPVertexBuffer *) vertexBuffer
{
    return vertexBuffer;
}

- (void) uploadToGL
{
    [ vertexBuffer uploadVBOWithUsageHint:NP_VBO_UPLOAD_ONCE_RENDER_OFTEN ];
}

- (void) render
{
    NSEnumerator * enumerator = [ groups objectEnumerator ];
    NPSUXModelGroup * group;

    while ( group = [ enumerator nextObject ] )
    {
        [ group render ];
    }
}

@end
