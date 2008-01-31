#import "NPSUXModelLod.h"
#import "NPSUXModelGroup.h"

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

    vertexBuffer = [ [ NPVertexBuffer alloc ] initWithParent:self ];

    groupCount = 0;
    groups = [ [ NSMutableArray alloc ] init ];

    return self;
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    NSString * lodName = [ file readSUXString ];

    if ( lodName == nil )
    {
        return NO;
    }

    [ self setName: lodName ];
    [ lodName release ];
    NSLog(@"LOD Name: %@",lodName);

    [ file readBool:&autoenable ];
    [ file readFloat:&minDistance ];
    [ file readFloat:&maxDistance ];
    NSLog(@"Min Distance:%f Max Distance %f",minDistance,maxDistance);

    boundingBoxMinimum = [ file readFVector3 ];
	NSLog(@"%f %f %f",FV_X(*boundingBoxMinimum),FV_Y(*boundingBoxMinimum),FV_Z(*boundingBoxMinimum));
    boundingBoxMaximum = [ file readFVector3 ];
    [ file readFloat:&boundingSphereRadius ];
    NSLog(@"Bounding Sphere %f",boundingSphereRadius);

    if ( [ vertexBuffer loadFromFile:file ] == NO )
    {
        return NO;
    }

    [ file readInt32:&groupCount ];
    NSLog(@"Group Count: %d",groupCount);

    for ( Int i = 0; i < groupCount; i++ )
    {
        NPSUXModelGroup * group = [ [ NPSUXModelGroup alloc ] init ];

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

@end
