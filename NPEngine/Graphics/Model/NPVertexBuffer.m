#import "NPVertexBuffer.h"
#import "NP.h"

void reset_npvertexformat(NpVertexFormat * vertex_format)
{
    vertex_format->positionsDataFormat = NP_NONE;
    vertex_format->normalsDataFormat   = NP_NONE;
    vertex_format->colorsDataFormat    = NP_NONE;
    vertex_format->weightsDataFormat   = NP_NONE;

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        vertex_format->textureCoordinatesDataFormat[i] = NP_NONE;
    }

    vertex_format->elementsForPosition = 3;
    vertex_format->elementsForNormal   = 0;
    vertex_format->elementsForColor    = 0;
    vertex_format->elementsForWeights  = 0;

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        vertex_format->elementsForTextureCoordinateSet[i] = 0;
    }

    vertex_format->maxTextureCoordinateSet = 0;
}

void init_empty_npvertices(NpVertices * vertices)
{
    reset_npvertexformat(&(vertices->format));

    vertices->primitiveType = NP_NONE;
    vertices->positions     = NULL;
    vertices->normals       = NULL;
    vertices->colors        = NULL;
    vertices->weights       = NULL;
    vertices->indices       = NULL;
    vertices->indexed       = NO;
    vertices->maxVertex     = 0;
    vertices->maxIndex      = 0;

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        vertices->textureCoordinates[i] = NULL;
    }
}

void reset_npvertices(NpVertices * vertices)
{
    reset_npvertexformat(&(vertices->format));

    vertices->primitiveType = NP_NONE;

    SAFE_FREE(vertices->positions);
    SAFE_FREE(vertices->normals);
    SAFE_FREE(vertices->colors);
    SAFE_FREE(vertices->weights);
    SAFE_FREE(vertices->indices);

    vertices->indexed   = NO;
    vertices->maxVertex = 0;
    vertices->maxIndex  = 0;

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        SAFE_FREE(vertices->textureCoordinates[i]);
    }
}

void reset_npvertexbuffer(NpVertexBuffer * vertex_buffer)
{
    vertex_buffer->hasVBO      = NO;
    vertex_buffer->positionsID = 0;
    vertex_buffer->normalsID   = 0;
    vertex_buffer->colorsID    = 0;
    vertex_buffer->weightsID   = 0;

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        vertex_buffer->textureCoordinatesSetID[i] = NP_NONE;
    }

    vertex_buffer->indicesID = NP_NONE;
}

@implementation NPVertexBuffer

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPVertexBuffer" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    reset_npvertexbuffer(&vertexBuffer);
    init_empty_npvertices(&vertices);

    return self;
}

- (void) dealloc
{
    [ self reset ];
    [ super dealloc ];
}

- (void *) allocArray:(NpState)dataFormat numberOfElements:(Int)numberOfElements
{
    switch ( dataFormat )
    {
        case NP_GRAPHICS_VBO_DATAFORMAT_INT  :{ return ALLOC_ARRAY(Int,   numberOfElements); }
        case NP_GRAPHICS_VBO_DATAFORMAT_HALF :{ return ALLOC_ARRAY(UInt16,numberOfElements); }
        case NP_GRAPHICS_VBO_DATAFORMAT_FLOAT:{ return ALLOC_ARRAY(Float, numberOfElements); }
        default:{ NPLOG_ERROR(@"%@: Unknown data format %d",name,dataFormat); return NULL; }
    }
}

- (void) allocArrays
{
    Int size = vertices.maxVertex + 1;
    vertices.positions = [ self allocArray:vertices.format.positionsDataFormat numberOfElements:size*vertices.format.elementsForPosition ];

    if ( vertices.format.elementsForNormal > 0 )
    {
        vertices.normals = [ self allocArray:vertices.format.normalsDataFormat 
                            numberOfElements:size*vertices.format.elementsForNormal ];
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        vertices.colors = [ self allocArray:vertices.format.colorsDataFormat 
                           numberOfElements:size*vertices.format.elementsForColor ];
    }

    if ( vertices.format.elementsForWeights > 0 )
    {
        vertices.weights = [ self allocArray:vertices.format.weightsDataFormat 
                            numberOfElements:size*vertices.format.elementsForWeights ];
    }

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            vertices.textureCoordinates[i] = [ self allocArray:vertices.format.textureCoordinatesDataFormat[i]
                                              numberOfElements:size*vertices.format.elementsForTextureCoordinateSet[i] ];
        }
    }

    if ( vertices.maxIndex > 0 )
    {
        vertices.indices = [ self allocArray:NP_GRAPHICS_VBO_DATAFORMAT_INT
                            numberOfElements:(vertices.maxIndex + 1) ];
    }
}

- (void) allocVertexBufferStorage:(Int)vertexCount
{
    vertices.maxVertex = vertexCount - 1;
    [ self allocArrays ];
}

- (void) allocVertexBufferStorage:(Int)vertexCount indexCount:(Int)indexCount
{
    vertices.maxVertex = vertexCount - 1;
    vertices.maxIndex  = indexCount  - 1;
    [ self allocArrays ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ]];

    Int indexCount;
    Int vertexCount;

    vertices.format.positionsDataFormat = NP_GRAPHICS_VBO_DATAFORMAT_FLOAT;
    vertices.format.normalsDataFormat   = NP_GRAPHICS_VBO_DATAFORMAT_FLOAT;
    vertices.format.colorsDataFormat    = NP_GRAPHICS_VBO_DATAFORMAT_FLOAT;
    vertices.format.weightsDataFormat   = NP_GRAPHICS_VBO_DATAFORMAT_FLOAT;

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        vertices.format.textureCoordinatesDataFormat[i] = NP_GRAPHICS_VBO_DATAFORMAT_FLOAT;
    }

    vertices.format.elementsForPosition = 3;
    [ file readInt32:&(vertices.format.elementsForNormal) ];
    [ file readInt32:&(vertices.format.elementsForColor) ];
    [ file readInt32:&(vertices.format.elementsForWeights) ];

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        [ file readInt32:&(vertices.format.elementsForTextureCoordinateSet[i]) ];
    }

    [ file readInt32:&(vertices.format.maxTextureCoordinateSet) ];
    [ file readBool:&(vertices.indexed) ];

    [ file readInt32:&vertexCount ];
    vertices.maxVertex = vertexCount -1;

    if ( vertices.indexed == YES )
    {
        [ file readInt32:&indexCount ];
        [ self allocVertexBufferStorage:vertexCount indexCount:indexCount ];
    }
    else
    {
        [ self allocVertexBufferStorage:vertexCount ];
    }

    [ file readFloats:vertices.positions withLength:(vertexCount*3) ];

    if ( vertices.format.elementsForNormal > 0 )
    {
        [ file readFloats:vertices.normals withLength:(vertexCount*vertices.format.elementsForNormal) ];
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        [ file readFloats:vertices.colors withLength:(vertexCount*vertices.format.elementsForColor) ];
    }

    if ( vertices.format.elementsForWeights > 0 )
    {
        [ file readFloats:vertices.weights withLength:(vertexCount*vertices.format.elementsForWeights) ];
    }

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            [ file readFloats:vertices.textureCoordinates[i] withLength:(vertexCount * vertices.format.elementsForTextureCoordinateSet[i]) ];
        }
    }

    if ( vertices.indexed == YES )
    {
        [ file readInt32s:vertices.indices withLength:(UInt)indexCount ];
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

    Int32 vertexCount = 0;
    Int32 indexCount = 0;

    [ file writeInt32:&(vertices.format.elementsForNormal) ];
    [ file writeInt32:&(vertices.format.elementsForColor) ];
    [ file writeInt32:&(vertices.format.elementsForWeights) ];

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        [ file writeInt32:&(vertices.format.elementsForTextureCoordinateSet[i]) ];
    }

    [ file writeInt32:&(vertices.format.maxTextureCoordinateSet) ];
    [ file writeBool:&(vertices.indexed) ];

    vertexCount = vertices.maxVertex + 1;
    [ file writeInt32:&vertexCount ];

    if ( vertices.indexed == YES )
    {
        indexCount = vertices.maxIndex + 1;
        [ file writeInt32:&indexCount ];
    }

    [ file writeFloats:vertices.positions withLength:(vertexCount*3) ];

    if ( vertices.format.elementsForNormal > 0 )
    {
        [ file writeFloats:vertices.normals withLength:(vertexCount*vertices.format.elementsForNormal) ];
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        [ file writeFloats:vertices.colors withLength:(vertexCount*vertices.format.elementsForColor) ];
    }

    if ( vertices.format.elementsForWeights > 0 )
    {
        [ file writeFloats:vertices.weights withLength:(vertexCount*vertices.format.elementsForWeights) ];
    }

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            [ file writeFloats:vertices.textureCoordinates[i] withLength:(vertexCount * vertices.format.elementsForTextureCoordinateSet[i]) ];
        }
    }    

    if ( vertices.indexed == YES )
    {
        [ file writeInt32s:vertices.indices withLength:(UInt)indexCount ];
    }

    return YES;
}

- (void) reset
{
    if ( vertexBuffer.hasVBO == YES )
    {
        [ self deleteVBO ];
    }

    reset_npvertexbuffer(&vertexBuffer);
    reset_npvertices(&vertices);

    [ super reset ];
}

- (void) uploadVBOWithUsageHint:(NpState)usage
{
    if ( ready == NO )
    {
        NPLOG_ERROR(@"%@: VBO not ready", name);
        return;
    }

    if ( vertexBuffer.hasVBO == YES )
    {
        [ self deleteVBO ];
    }

    GLenum vboUsage = [[[ NP Graphics ] vertexBufferManager ] computeGLUsage:usage ];

    Int vertexCount  = vertices.maxVertex + 1;
    Int verticesSize = vertexCount * [[[ NP Graphics ] vertexBufferManager ] computeDataFormatByteCount:vertices.format.positionsDataFormat ];

    glGenBuffers(1, &(vertexBuffer.positionsID));
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.positionsID);
    glBufferData(GL_ARRAY_BUFFER, verticesSize * vertices.format.elementsForPosition, vertices.positions, vboUsage);

    if ( vertices.format.elementsForNormal > 0 )
    {
        Int normalsSize = vertexCount * [[[ NP Graphics ] vertexBufferManager ] computeDataFormatByteCount:vertices.format.normalsDataFormat ];

        glGenBuffers(1, &(vertexBuffer.normalsID));
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.normalsID);
        glBufferData(GL_ARRAY_BUFFER, normalsSize * vertices.format.elementsForNormal, vertices.normals, vboUsage);
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        Int colorsSize = vertexCount * [[[ NP Graphics ] vertexBufferManager ] computeDataFormatByteCount:vertices.format.colorsDataFormat ];

        glGenBuffers(1, &(vertexBuffer.colorsID));
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.colorsID);
        glBufferData(GL_ARRAY_BUFFER, colorsSize * vertices.format.elementsForColor, vertices.colors, vboUsage);
    }

    if ( vertices.format.elementsForWeights > 0 )
    {
        Int weightsSize = vertexCount * [[[ NP Graphics ] vertexBufferManager ] computeDataFormatByteCount:vertices.format.weightsDataFormat ];

        glGenBuffers(1, &(vertexBuffer.weightsID));
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.weightsID);
        glBufferData(GL_ARRAY_BUFFER, weightsSize * vertices.format.elementsForWeights, vertices.weights, vboUsage);
    }

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++)
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            Int texCoordsSize = vertexCount * [[[ NP Graphics ] vertexBufferManager ] computeDataFormatByteCount:vertices.format.textureCoordinatesDataFormat[i] ];

            glGenBuffers(1, &(vertexBuffer.textureCoordinatesSetID[i]));
            glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.textureCoordinatesSetID[i]);
            glBufferData(GL_ARRAY_BUFFER, texCoordsSize * vertices.format.elementsForTextureCoordinateSet[i], vertices.textureCoordinates[i], vboUsage);
        }
    }

    Int indicesSize = (vertices.maxIndex + 1) * sizeof(Int32);

    if ( vertices.indexed == YES )
    {
        glGenBuffers(1, &(vertexBuffer.indicesID));
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexBuffer.indicesID);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indicesSize, vertices.indices, vboUsage);
    }

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    GLenum error = glGetError();

    while ( error != GL_NO_ERROR )
    {
        NPLOG_ERROR(([ NSString stringWithFormat:@"%@: %s", name, gluErrorString(error)]));
        error = glGetError();
    }

    vertexBuffer.hasVBO = YES;
}

- (void) deleteBuffer:(UInt)bufferID
{
    if ( bufferID > 0 )
    {
        glDeleteBuffers(1,&bufferID);
    }
}

- (void) deleteVBO
{
    [ self deleteBuffer:vertexBuffer.positionsID ];
    [ self deleteBuffer:vertexBuffer.normalsID ];
    [ self deleteBuffer:vertexBuffer.colorsID ];
    [ self deleteBuffer:vertexBuffer.weightsID ];
    [ self deleteBuffer:vertexBuffer.indicesID ];

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        [ self deleteBuffer:vertexBuffer.textureCoordinatesSetID[i] ];
    }
}

- (void) render
{
    [ self renderWithPrimitiveType:vertices.primitiveType ];
}

- (void) renderWithPrimitiveType:(NpState)primitiveType
{
    if ( vertices.indexed == YES )
    {
        if ( vertexBuffer.hasVBO == YES )
        {
            [ self renderElementWithPrimitiveType:primitiveType firstIndex:0 andLastIndex:vertices.maxIndex ];
        }
        else
        {
            [self renderFromMemoryWithPrimitiveType:primitiveType firstIndex:0 andLastIndex:vertices.maxIndex ];
        }
    }
    else
    {
        if ( vertexBuffer.hasVBO == YES )
        {
            [ self renderElementWithPrimitiveType:primitiveType firstIndex:0 andLastIndex:vertices.maxVertex ];
        }
        else
        {
            [self renderFromMemoryWithPrimitiveType:primitiveType firstIndex:0 andLastIndex:vertices.maxVertex ];
        }
    }
}

- (void) renderWithPrimitiveType:(NpState)primitiveType firstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex
{
    if ( vertexBuffer.hasVBO == YES )
    {
        [ self renderElementWithPrimitiveType:primitiveType firstIndex:firstIndex andLastIndex:lastIndex ];
    }
    else
    {
        [self renderFromMemoryWithPrimitiveType:primitiveType firstIndex:firstIndex andLastIndex:lastIndex ];
    }
}

- (void) renderElementWithPrimitiveType:(NpState)primitiveType firstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex;
{
    if ( vertices.format.elementsForNormal > 0 )
    {
        glEnableClientState(GL_NORMAL_ARRAY);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.normalsID );
        glNormalPointer(GL_FLOAT, 0, NULL);
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        glEnableClientState(GL_COLOR_ARRAY);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.colorsID );
        glColorPointer(vertices.format.elementsForColor, GL_FLOAT, 0, NULL);
    }

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++)
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            glActiveTexture(GL_TEXTURE0 + i);
            glClientActiveTexture(GL_TEXTURE0 + i);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.textureCoordinatesSetID[i] );
            glTexCoordPointer(vertices.format.elementsForTextureCoordinateSet[i], GL_FLOAT, 0, NULL);
        }
    }

    glEnableClientState(GL_VERTEX_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.positionsID );
    glVertexPointer(vertices.format.elementsForPosition, GL_FLOAT, 0, NULL);

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

    if ( vertices.indexed == YES )
    {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexBuffer.indicesID);
        glDrawRangeElements(primitiveType, 0, vertices.maxVertex, lastIndex - firstIndex + 1,
                            GL_UNSIGNED_INT, BUFFER_OFFSET(firstIndex*sizeof(UInt32)));
    }
    else
    {
        glDrawArrays(primitiveType, 0, lastIndex - firstIndex + 1);
    }

#undef BUFFER_OFFSET

    glDisableClientState(GL_VERTEX_ARRAY);

    if ( vertices.format.elementsForNormal > 0 )
    {
        glDisableClientState(GL_NORMAL_ARRAY);
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        glDisableClientState(GL_COLOR_ARRAY);
    }

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++)
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            glClientActiveTexture(GL_TEXTURE0 + i);
            glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        }
    }

    glClientActiveTexture(GL_TEXTURE0);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

- (void) renderFromMemoryWithPrimitiveType:(NpState)primitiveType firstIndex:(Int)firstIndex andLastIndex:(Int)lastIndex
{
    if ( vertices.format.elementsForNormal > 0 )
    {
        glEnableClientState(GL_NORMAL_ARRAY);
        glNormalPointer(GL_FLOAT, 0, vertices.normals);
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        glEnableClientState(GL_COLOR_ARRAY);
        glColorPointer(vertices.format.elementsForColor, GL_FLOAT, 0, vertices.colors);
    }

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++)
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            glActiveTexture(GL_TEXTURE0 + i);
            glClientActiveTexture(GL_TEXTURE0 + i);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(vertices.format.elementsForTextureCoordinateSet[i], GL_FLOAT, 0, vertices.textureCoordinates[i]);
        }
    }

    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(vertices.format.elementsForPosition, GL_FLOAT, 0, vertices.positions);


    if ( vertices.indexed == YES )
    {
        glDrawRangeElements(primitiveType, 0, vertices.maxVertex, lastIndex - firstIndex + 1,
                            GL_UNSIGNED_INT, vertices.indices);
    }
    else
    {
        glDrawArrays(primitiveType, firstIndex, lastIndex - firstIndex + 1);
    }

    glDisableClientState(GL_VERTEX_ARRAY);

    if ( vertices.format.elementsForNormal > 0 )
    {
        glDisableClientState(GL_NORMAL_ARRAY);
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        glDisableClientState(GL_COLOR_ARRAY);
    }

    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++)
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            glClientActiveTexture(GL_TEXTURE0 + i);
            glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        }
    }

    glClientActiveTexture(GL_TEXTURE0);
}

- (BOOL) hasVBO
{
    return vertexBuffer.hasVBO;
}

- (NpVertexFormat *) vertexFormat
{
    return &(vertices.format);
}

- (NpVertexBuffer *) vertexBuffer
{
    return &vertexBuffer;
}

- (Int) vertexCount
{
    return ( vertices.maxVertex + 1);
}

- (Float *) positions
{
    return vertices.positions;
}

- (Float *) normals
{
    return vertices.normals;
}

- (Float *) colors
{
    return vertices.colors;
}

- (Float *) weights
{
    return vertices.weights;
}

- (Int *) indices
{
    return vertices.indices;
}

- (void) setVertexFormat:(NpVertexFormat *)newVertexFormat
{
    vertices.format = *newVertexFormat;
}

- (void) setVertexCount:(Int)newVertexCount
{
    vertices.maxVertex = newVertexCount - 1;
}

- (void) setPositions:(Float *)newPositions
  elementsForPosition:(Int)newElementsForPosition
           dataFormat:(NpState)newDataFormat
          vertexCount:(Int)newVertexCount
{
    if ( newElementsForPosition < 1 || newElementsForPosition > 4 )
    {
        NPLOG_WARNING(@"%@: Invalid positions element count %d", name, newElementsForPosition);
        return;
    }

    if ( newVertexCount < 1 )
    {
        NPLOG_WARNING(@"%@: Invalid vertex count %d", name, newElementsForPosition);
        return;
    }

    if ( vertices.positions != newPositions )
    {
        SAFE_FREE(vertices.positions);
    }

    vertices.positions = newPositions;
    vertices.format.elementsForPosition = newElementsForPosition;
    vertices.format.positionsDataFormat = newDataFormat;
    vertices.maxVertex = newVertexCount - 1;
    ready = YES;
}

- (void) setNormals:(Float *)newNormals
  elementsForNormal:(Int)newElementsForNormal
         dataFormat:(NpState)newDataFormat
{
    if ( newElementsForNormal < 1 || newElementsForNormal > 4 )
    {
        NPLOG_WARNING(@"%@: Invalid normals element count %d", name, newElementsForNormal);
        return;
    }

    if ( vertices.normals != newNormals )
    {
        SAFE_FREE(vertices.normals);
    }

    vertices.format.elementsForNormal = newElementsForNormal;
    vertices.format.normalsDataFormat = newDataFormat;
    vertices.normals = newNormals;
}

- (void) setColors:(Float *)newColors 
  elementsForColor:(Int)newElementsForColor
        dataFormat:(NpState)newDataFormat
{
    if ( newElementsForColor < 1 || newElementsForColor > 4 )
    {
        NPLOG_WARNING(@"%@: Invalid colors element count %d", name, newElementsForColor);
        return;
    }

    if ( vertices.colors != newColors )
    {
        SAFE_FREE(vertices.colors);
    }

    vertices.format.elementsForColor = newElementsForColor;
    vertices.format.colorsDataFormat = newDataFormat;
    vertices.colors = newColors;
}

- (void) setWeights:(Float *)newWeights
 elementsForWeights:(Int)newElementsForWeights
         dataFormat:(NpState)newDataFormat
{
    if ( newElementsForWeights < 1 || newElementsForWeights > 4 )
    {
        NPLOG_WARNING(@"%@: Invalid colors element count %d", name, newElementsForWeights);
        return;
    }

    if ( vertices.weights != newWeights )
    {
        SAFE_FREE(vertices.weights);
    }

    vertices.format.elementsForWeights = newElementsForWeights;
    vertices.format.weightsDataFormat = newDataFormat;
    vertices.weights = newWeights;
}

- (void) setTextureCoordinates   :(Float *)newTextureCoordinates 
    elementsForTextureCoordinates:(Int)newElementsForTextureCoordinates
                       dataFormat:(NpState)newDataFormat
                           forSet:(Int)textureCoordinateSet
{
    if ( newElementsForTextureCoordinates < 1 || newElementsForTextureCoordinates > 4 )
    {
        NPLOG_WARNING(@"%@: Invalid texture coordinates element count %d", name, newElementsForTextureCoordinates);
        return;
    }

    if ( textureCoordinateSet < 0 || textureCoordinateSet > NP_GRAPHICS_SAMPLER_COUNT )
    {
        NPLOG_WARNING(@"%@: Invalid texture coordinate set %d", name, textureCoordinateSet);
        return;
    }

    if ( vertices.textureCoordinates[textureCoordinateSet] != newTextureCoordinates )
    {
        SAFE_FREE(vertices.textureCoordinates[textureCoordinateSet]);
    }

    vertices.format.elementsForTextureCoordinateSet[textureCoordinateSet] = newElementsForTextureCoordinates;
    vertices.format.textureCoordinatesDataFormat[textureCoordinateSet] = newDataFormat;
    vertices.textureCoordinates[textureCoordinateSet] = newTextureCoordinates;
}

- (void) setIndices:(Int *)newIndices
         indexCount:(Int)newIndexCount
{
    if ( vertices.indices != NULL && vertices.indices != newIndices)
    {
        SAFE_FREE(vertices.indices);
    }

    vertices.indices  = newIndices;
    vertices.indexed  = YES;
    vertices.maxIndex = newIndexCount - 1;
}

@end
