#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;

typedef struct NpVertexFormat
{
    Int elementsForNormal;
    Int elementsForColor;
    Int elementsForWeights;
    Int elementsForTextureCoordinateSet[8];
    Int maxTextureCoordinateSet;
}
NpVertexFormat;

void reset_npvertexformat(NpVertexFormat * vertex_format);

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

void reset_npvertices(NpVertices * vertices);

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

void reset_npvertexbuffer(NpVertexBuffer * vertex_buffer);

@interface NPVertexBuffer : NPResource < NPPResource >
{
    NpVertexBuffer vertexBuffer;
    NpVertices vertices;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;
- (BOOL) isReady;

@end
