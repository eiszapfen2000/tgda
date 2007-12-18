#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"

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
    Int primitiveType;
    BOOL indexed;
    Float * positions;
    Float * normals;
    Float * colors;
    Float * weights;
    Float * textureCoordinates;
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
    BOOL ready;

    NpVertexBuffer vertexBuffer;
    NpVertices vertices;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (void) loadFromFile:(NPFile *)file;

@end
