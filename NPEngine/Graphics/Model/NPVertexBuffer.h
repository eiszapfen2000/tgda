#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"

@class NPFile;

typedef struct NpVertexFormat
{
    NpState positionsDataFormat; // SUX Models use Float
    NpState normalsDataFormat;   // SUX Models use Float
    NpState colorsDataFormat;    // SUX Models use Float
    NpState weightsDataFormat;   // SUX Models use Float
    NpState textureCoordinatesDataFormat[8];  // SUX Models use Float

    Int elementsForPosition; // SUX Models use 3
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

    // These will only be used if we load a SUX model, otherwise they should be NULL
    Float * positions;
    Float * normals;
    Float * colors;
    Float * weights;
    Float * textureCoordinates[8];

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
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) saveToFile:(NPFile *)file;
- (void) reset;

- (void) uploadVBOWithUsageHint:(NpState)usage;
- (void) deleteVBO;

- (void) render;
- (void) renderWithPrimitiveType:(NpState)primitiveType;
- (void) renderWithPrimitiveType:(NpState)primitiveType firstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex;
- (void) renderElementWithPrimitiveType:(NpState)primitiveType firstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex;
- (void) renderFromMemoryWithPrimitiveType:(NpState)primitiveType firstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex;

- (BOOL) hasVBO;
- (NpVertexFormat *) vertexFormat;
- (NpVertexBuffer *) vertexBuffer;
- (Int) vertexCount;
- (Float *) positions;
- (Float *) normals;
- (Float *) colors;
- (Float *) weights;
- (Int *) indices;

- (void) setVertexFormat:(NpVertexFormat *)newVertexFormat;
- (void) setVertexCount:(Int)newVertexCount;

- (void) setPositions:(Float *)newPositions elementsForPosition:(Int)newElementsForPosition vertexCount:(Int)newVertexCount;
- (void) setNormals:(Float *)newNormals withElementsForNormal:(Int)newElementsForNormal;
- (void) setColors:(Float *)newColors withElementsForColor:(Int)newElementsForColor;
- (void) setWeights:(Float *)newWeights withElementsForWeights:(Int)newElementsForWeights;
- (void) setTextureCoordinates:(Float *)textureCoordinates forSet:(Int)textureCoordinateSet;
- (void) setIndices:(Int *)newIndices indexCount:(Int)newIndexCount;

@end
