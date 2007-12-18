#import "NPVertexBuffer.h"
#import "Core/Basics/Memory.h"

@implementation NPVertexBuffer

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPVertexBuffer" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    ready = NO;

    return self;
}

- (void) loadFromFile:(NPFile *)file
{
    Int indexCount;
    Int vertexCount;

    [ file readInt32:&(vertices.format.elementsForNormal) ];
    NSLog(@"Elements for Normal: %d",vertices.format.elementsForNormal);
    [ file readInt32:&(vertices.format.elementsForColor) ];
    NSLog(@"Elements for Color: %d",vertices.format.elementsForColor);
    [ file readInt32:&(vertices.format.elementsForWeights) ];
    NSLog(@"Elements for Weights: %d",vertices.format.elementsForWeights);

    for ( Int i = 0; i < 8; i++ )
    {
        [ file readInt32:&(vertices.format.elementsForTextureCoordinateSet[i]) ];
        NSLog(@"Elements for Texture Coordinate %d: %d",i,vertices.format.elementsForTextureCoordinateSet[i]);
    }

    [ file readInt32:&(vertices.format.maxTextureCoordinateSet) ];
    NSLog(@"Max Texture Coordinate Set: %d",vertices.format.maxTextureCoordinateSet);

    [ file readBool:&(vertices.indexed) ];
    [ file readInt32:&vertexCount ];
    NSLog(@"Vertex Count: %d",vertexCount);

    if ( vertices.indexed == YES )
    {
        NSLog(@"indexed");
        
        [ file readInt32:&indexCount ];
        NSLog(@"Index count: %d",indexCount);
    }

    vertices.positions = ALLOC_ARRAY(Float,(vertexCount*3));
    [ file readFloats:vertices.positions withLength:(vertexCount*3) ];

    if ( vertices.format.elementsForNormal > 0 )
    {
        vertices.normals = ALLOC_ARRAY(Float,vertexCount*vertices.format.elementsForNormal);
        [ file readFloats:vertices.normals withLength:(vertexCount*vertices.format.elementsForNormal) ];
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        vertices.colors = ALLOC_ARRAY(Float,vertexCount*vertices.format.elementsForColor);
        [ file readFloats:vertices.colors withLength:(vertexCount*vertices.format.elementsForColor) ];
    }

    if ( vertices.format.elementsForWeights > 0 )
    {
        vertices.weights = ALLOC_ARRAY(Float,vertexCount*vertices.format.elementsForWeights);
        [ file readFloats:vertices.weights withLength:(vertexCount*vertices.format.elementsForWeights) ];
    }

    Int textureCoordinatesCount = 0;

    for ( Int i = 0; i < 8; i++ )
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            textureCoordinatesCount += (vertexCount * vertices.format.elementsForTextureCoordinateSet[i]);
        }
    }

    NSLog(@"texcoord count: %d",textureCoordinatesCount);

    if ( textureCoordinatesCount > 0 )
    {
        vertices.textureCoordinates = ALLOC_ARRAY(Float,textureCoordinatesCount);
        Float * texCoordPointer = vertices.textureCoordinates;

        for ( Int i = 0; i < 8; i++ )
        {
            if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
            {
                [ file readFloats:texCoordPointer withLength:(vertexCount * vertices.format.elementsForTextureCoordinateSet[i]) ];
                texCoordPointer += (vertexCount * vertices.format.elementsForTextureCoordinateSet[i]);
            }
        }        
    }

    if ( vertices.indexed == YES )
    {
        vertices.indices = ALLOC_ARRAY(Int,indexCount);
        [ file readInt32s:vertices.indices withLength:(UInt)indexCount ];
    }
}

@end
