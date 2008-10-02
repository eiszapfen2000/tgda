#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

#define NP_VBO_UPLOAD_ONCE_RENDER_OFTEN     0
#define NP_VBO_UPLOAD_ONCE_RENDER_SELDOM    1
#define NP_VBO_UPLOAD_OFTEN_RENDER_OFTEN    2

#define NP_VBO_PRIMITIVES_POINTS            0
#define NP_VBO_PRIMITIVES_LINES             1
#define NP_VBO_PRIMITIVES_LINE_STRIP        3
#define NP_VBO_PRIMITIVES_TRIANGLES         4
#define NP_VBO_PRIMITIVES_TRIANGLE_STRIP    5
#define NP_VBO_PRIMITIVES_QUADS             7
#define NP_VBO_PRIMITIVES_QUAD_STRIP        8

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
void init_empty_npvertices(NpVertices * vertices);

typedef struct NpVertexBuffer
{
    BOOL hasVBO;
    UInt positionsID;
    UInt normalsID;
    UInt colorsID;
    UInt weightsID;
    UInt textureCoordinatesSetID[8];
    UInt indicesID;    
}
NpVertexBuffer;

void reset_npvertexbuffer(NpVertexBuffer * vertex_buffer);
void init_empty_npvertexbuffer(NpVertexBuffer * vertex_buffer);

@interface NPVertexBuffer : NPResource
{
    NpVertexBuffer vertexBuffer;
    NpVertices vertices;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) saveToFile:(NPFile *)file;
- (void) reset;

- (void) uploadVBOWithUsageHint:(NpState)usage;
- (void) deleteVBO;
- (void) render;
- (void) renderWithPrimitiveType:(Int)primitiveType firstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex;
- (void) renderElementWithFirstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex;
- (void) renderElementWithPrimitiveType:(Int)primitiveType firstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex;
- (void) renderFromMemoryWithFirstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex;
- (void) renderFromMemoryWithPrimitiveType:(Int)primitiveType firstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex;

- (Float *) positions;
- (void) setPositions:(Float *)newPositions;
- (void) setPositions:(Float *)newPositions vertexCount:(Int)newVertexCount;

- (Float *) normals;
- (void) setNormals:(Float *)newNormals withElementsForNormal:(Int)newElementsForNormal;

- (Float *) colors;
- (void) setColors:(Float *)newColors withElementsForColor:(Int)newElementsForColor;

- (Float *) weights;
- (void) setWeights:(Float *)newWeights withElementsForWeights:(Int)newElementsForWeights;

- (void) setTextureCoordinates:(Float *)textureCoordinates forSet:(Int)textureCoordinateSet;

- (Int *) indices;
- (void) setIndices:(Int *)newIndices;
- (void) setIndices:(Int *)newIndices indexCount:(Int)newIndexCount;

- (void) setIndexed:(BOOL)newIndexed;
- (void) setMaxVertex:(Int)newMaxVertex;
- (void) setMaxIndex:(Int)newMaxIndex;
- (void) setPrimitiveType:(Int)newPrimitiveType;
- (void) setReady:(BOOL)newReady;

@end
