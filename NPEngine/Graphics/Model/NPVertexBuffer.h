#import "Core/NPObject/NPObject.h"

typedef struct NpVertexFormat
{
    Int elementsForNormal;
    Int elementsForColor;
    Int elementsForWeights;
    Int elementsForTextureCoordinateSet[8];
    Int maxTextureCoordinateSet;
}
NpVertexFormat;

typedef struct NpVertices
{
    NpVertexFormat format;
    Float * positions;
    Float * normals;
    Float * colors;
    Float * weights;
    Float ** textureCoordinates;
    Int * indices;
    Int maxVertex;
    Int maxIndex;
}
NpVertices;

typedef struct NpVertexBuffer
{
    UInt positionsID;
    UInt normalsID;
    UInt colorsID;
    UInt weightsID;
    UInt textureCoordinatesSetID[8];
    UInt indicesID;    
}
NpVertexBuffer;

@interface NPVertexBuffer : NPObject
{
    NpVertexBuffer vertexBuffer;
    NpVertices vertices;
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

@end
