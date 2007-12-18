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

- (void) loadFromFile:(NPFile *)file
{
    NSString * lodName = [ file readSUXString ];
    [ self setName: lodName ];
    [ lodName release ];
    NSLog(@"LOD Name: %@",lodName);

    [ file readBool:&autoenable ];
    [ file readFloat:&minDistance ];
    [ file readFloat:&maxDistance ];
    NSLog(@"Min Distance:%f Max Distance %f",minDistance,maxDistance);

    boundingBoxMinimum = [ file readFVector3 ];
    boundingBoxMaximum = [ file readFVector3 ];
    [ file readFloat:&boundingSphereRadius ];
    NSLog(@"Bounding Sphere %f",boundingSphereRadius);

    [ vertexBuffer loadFromFile:file ];

    [ file readInt32:&groupCount ];
    NSLog(@"Group Count: %d",groupCount);

    for ( Int i = 0; i < groupCount; i++ )
    {
        NPSUXModelGroup * group = [ [ NPSUXModelGroup alloc ] init ];
        [ group loadFromFile:file ];
        [ groups addObject:group ];
        [ group release ];
    }
}

@end
