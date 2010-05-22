#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Graphics/NPEngineGraphicsConstants.h"
#import "Graphics/npgl.h"

@class NPFile;

typedef struct NpVertexFormat
{
    NpState positionsDataFormat; // SUX Models use Float
    NpState normalsDataFormat;   // SUX Models use Float
    NpState colorsDataFormat;    // SUX Models use Float
    NpState weightsDataFormat;   // SUX Models use Float
    NpState textureCoordinatesDataFormat[NP_GRAPHICS_SAMPLER_COUNT];  // SUX Models use Float

    Int elementsForPosition; // SUX Models use 3
    Int elementsForNormal;
    Int elementsForColor;
    Int elementsForWeights;
    Int elementsForTextureCoordinateSet[NP_GRAPHICS_SAMPLER_COUNT];

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
    Float * textureCoordinates[NP_GRAPHICS_SAMPLER_COUNT];

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
    UInt textureCoordinatesSetID[NP_GRAPHICS_SAMPLER_COUNT];
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

+ (GLenum) computeGLUsage:(NpState)bufferUsage;
+ (Int32) computeDataFormatByteCount:(NpState)dataFormat;

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

- (void) setPositions:(Float *)newPositions
  elementsForPosition:(Int)newElementsForPosition
           dataFormat:(NpState)newDataFormat
          vertexCount:(Int)newVertexCount
                     ;

- (void) setNormals:(Float *)newNormals
  elementsForNormal:(Int)newElementsForNormal
         dataFormat:(NpState)newDataFormat
                   ;

- (void) setColors:(Float *)newColors 
  elementsForColor:(Int)newElementsForColor
        dataFormat:(NpState)newDataFormat
                  ;

- (void) setWeights:(Float *)newWeights
 elementsForWeights:(Int)newElementsForWeights
         dataFormat:(NpState)newDataFormat
                   ;

- (void) setTextureCoordinates   :(Float *)newTextureCoordinates 
    elementsForTextureCoordinates:(Int)newElementsForTextureCoordinates
                       dataFormat:(NpState)newDataFormat
                           forSet:(Int)textureCoordinateSet
                                 ;

- (void) setIndices:(Int *)newIndices
         indexCount:(Int)newIndexCount
                   ;

@end
