#import "NPSUXModelLod.h"
#import "NP.h"

@implementation NPSUXModelLod

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"SUX Model LOD" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    autoenable = NO;
    minDistance = 0.0f;
    maxDistance = 0.0f;

    boundingBoxMinimum = fv3_alloc_init();
    boundingBoxMaximum = fv3_alloc_init();
    boundingSphereRadius = 0.0f;

    vertexBuffer = nil;

    groupCount = 0;
    groups = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    boundingBoxMinimum = fv3_free(boundingBoxMinimum);
    boundingBoxMaximum = fv3_free(boundingBoxMaximum);

    [ vertexBuffer release ];

    [ groups removeAllObjects ];
    [ groups release ];

    [ super dealloc ];
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

    vertexBuffer = [[ NPVertexBuffer alloc ] initWithParent:self ];

    if ( [ vertexBuffer loadFromFile:file ] == NO )
    {
        return NO;
    }

    [ file readInt32:&groupCount ];
    NPLOG(([NSString stringWithFormat:@"Group Count: %d",groupCount]));

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
}

- (BOOL) saveToFile:(NPFile *)file
{
    if ( ready == NO )
    {
        return NO;
    }

    [ file writeSUXString:name ];
    [ file writeBool:&autoenable ];
    [ file writeFloat:&minDistance ];
    [ file writeFloat:&maxDistance ];
    [ file writeFVector3:boundingBoxMinimum ];
    [ file writeFVector3:boundingBoxMaximum ];
    [ file writeFloat:&boundingSphereRadius ];

    if ( [ vertexBuffer saveToFile:file ] == NO )
    {
        return NO;
    }

    [ file writeInt32:&groupCount ];

    for ( Int i = 0; i < groupCount; i++ )
    {
        NPSUXModelGroup * group = [ groups objectAtIndex:i ];

        if ( [ group saveToFile:file ] == NO )
        {
            return NO;
        }
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

- (NPVertexBuffer *) vertexBuffer
{
    return vertexBuffer;
}

- (void) setVertexBuffer:(NPVertexBuffer *)newVertexBuffer
{
    if ( vertexBuffer != newVertexBuffer )
    {
        [ vertexBuffer release ];
        vertexBuffer = [ newVertexBuffer retain ];
    }
}

- (NSArray *) groups
{
    return groups;
}

- (void) addGroup:(NPSUXModelGroup *)newGroup
{
    [ groups addObject:newGroup ];
    groupCount = [ groups count ];
}

- (void) uploadToGL
{
    if ( ready == NO )
    {
        NPLOG(@"lod not ready");
        return;
    }

    [ vertexBuffer uploadVBOWithUsageHint:NP_GRAPHICS_VBO_UPLOAD_ONCE_RENDER_OFTEN ];
}

- (void) render
{
    if ( ready == NO )
    {
        NPLOG(@"lod not ready");
        return;
    }

    NSEnumerator * enumerator = [ groups objectEnumerator ];
    NPSUXModelGroup * group;

    while ( (group = [ enumerator nextObject ]) )
    {
        [ group render ];
    }
}

@end
