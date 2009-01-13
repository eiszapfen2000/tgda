#import "NPVertexBuffer.h"
#import "NP.h"

void reset_npvertexformat(NpVertexFormat * vertex_format)
{
    vertex_format->elementsForPosition = 3;
    vertex_format->elementsForNormal   = 0;
    vertex_format->elementsForColor    = 0;
    vertex_format->elementsForWeights  = 0;

    for ( Int i = 0; i < 8; i++ )
    {
        vertex_format->elementsForTextureCoordinateSet[i] = 0;
    }

    vertex_format->maxTextureCoordinateSet = 0;
}

void init_empty_npvertices(NpVertices * vertices)
{
    reset_npvertexformat(&(vertices->format));

    vertices->primitiveType      = -1;
    vertices->positions          = NULL;
    vertices->normals            = NULL;
    vertices->colors             = NULL;
    vertices->weights            = NULL;
    vertices->textureCoordinates = NULL;
    vertices->indices            = NULL;
    vertices->indexed            = NO;
    vertices->maxVertex          = 0;
    vertices->maxIndex           = 0;
}

void reset_npvertices(NpVertices * vertices)
{
    reset_npvertexformat(&(vertices->format));

    vertices->primitiveType = -1;

    if ( vertices->positions != NULL )
    {
        free(vertices->positions);
    }

    if ( vertices->normals != NULL )
    {
        FREE(vertices->normals);
    }

    if ( vertices->colors != NULL )
    {
        FREE(vertices->colors);
    }

    if ( vertices->weights != NULL )
    {
        FREE(vertices->weights);
    }

    if ( vertices->textureCoordinates != NULL )
    {
        FREE(vertices->textureCoordinates);
    }

    if ( vertices->indices != NULL && vertices->indexed == YES )
    {
        FREE(vertices->indices);
    }

    vertices->indexed   = NO;
    vertices->maxVertex = 0;
    vertices->maxIndex  = 0;
}

void reset_npvertexbuffer(NpVertexBuffer * vertex_buffer)
{
    vertex_buffer->hasVBO      = NO;
    vertex_buffer->positionsID = 0;
    vertex_buffer->normalsID   = 0;
    vertex_buffer->colorsID    = 0;
    vertex_buffer->weightsID   = 0;

    for ( Int i = 0; i < 8; i++ )
    {
        vertex_buffer->textureCoordinatesSetID[i] = -1;
    }

    vertex_buffer->indicesID = -1;
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

- (void) allocArrays
{
    Int size = vertices.maxVertex + 1;
    vertices.positions = ALLOC_ARRAY(Float,(size*vertices.format.elementsForPosition));

    if ( vertices.format.elementsForNormal > 0 )
    {
        vertices.normals = ALLOC_ARRAY(Float,size*vertices.format.elementsForNormal);
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        vertices.colors = ALLOC_ARRAY(Float,size*vertices.format.elementsForColor);
    }

    if ( vertices.format.elementsForWeights > 0 )
    {
        vertices.weights = ALLOC_ARRAY(Float,size*vertices.format.elementsForWeights);
    }

    Int textureCoordinatesCount = 0;
    for ( Int i = 0; i < 8; i++ )
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            textureCoordinatesCount += (size * vertices.format.elementsForTextureCoordinateSet[i]);
        }
    }

    if ( textureCoordinatesCount > 0 )
    {
        vertices.textureCoordinates = ALLOC_ARRAY(Float,textureCoordinatesCount);
    }

    if ( vertices.maxIndex > 0 )
    {
        vertices.indices = ALLOC_ARRAY(Int,vertices.maxIndex + 1);
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
    vertices.maxIndex = indexCount - 1;
    [ self allocArrays ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

    Int indexCount;
    Int vertexCount;

    vertices.format.elementsForPosition = 3;

    [ file readInt32:&(vertices.format.elementsForNormal) ];
    [ file readInt32:&(vertices.format.elementsForColor) ];
    [ file readInt32:&(vertices.format.elementsForWeights) ];

    for ( Int i = 0; i < 8; i++ )
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

    Int textureCoordinatesCount = 0;
    for ( Int i = 0; i < 8; i++ )
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            textureCoordinatesCount += (vertexCount * vertices.format.elementsForTextureCoordinateSet[i]);
        }
    }

    if ( textureCoordinatesCount > 0 )
    {
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

    for ( Int i = 0; i < 8; i++ )
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

    Float * texCoordPointer = vertices.textureCoordinates;

    for ( Int i = 0; i < 8; i++ )
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            [ file writeFloats:texCoordPointer withLength:(vertexCount * vertices.format.elementsForTextureCoordinateSet[i]) ];
            texCoordPointer += (vertexCount * vertices.format.elementsForTextureCoordinateSet[i]);
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
        NPLOG_ERROR(@"VBO not ready");
        return;
    }

    if ( vertexBuffer.hasVBO == YES )
    {
        [ self deleteVBO ];
    }

    GLenum vboUsage;

    switch( usage )
    {
        case NP_GRAPHICS_VBO_UPLOAD_ONCE_RENDER_OFTEN:
        {
            vboUsage = GL_STATIC_DRAW;
            break;
        }
        case NP_GRAPHICS_VBO_UPLOAD_ONCE_RENDER_SELDOM:
        {
            vboUsage = GL_STREAM_DRAW;
            break;
        }
        case NP_GRAPHICS_VBO_UPLOAD_OFTEN_RENDER_OFTEN:
        {
            vboUsage = GL_DYNAMIC_DRAW;
            break;
        }
        default:
        {
            vboUsage = GL_STATIC_DRAW;
            break;
        }
    }

    Int verticesSize = (vertices.maxVertex + 1) * sizeof(Float);

    glGenBuffers(1, &(vertexBuffer.positionsID));
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.positionsID);
    glBufferData(GL_ARRAY_BUFFER, verticesSize * vertices.format.elementsForPosition, vertices.positions, vboUsage);

    if ( vertices.format.elementsForNormal > 0 )
    {
        glGenBuffers(1, &(vertexBuffer.normalsID));
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.normalsID);
        glBufferData(GL_ARRAY_BUFFER, verticesSize * vertices.format.elementsForNormal, vertices.normals, vboUsage);
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        glGenBuffers(1, &(vertexBuffer.colorsID));
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.colorsID);
        glBufferData(GL_ARRAY_BUFFER, verticesSize * vertices.format.elementsForColor, vertices.colors, vboUsage);
    }

    if ( vertices.format.elementsForWeights > 0 )
    {
        glGenBuffers(1, &(vertexBuffer.weightsID));
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.weightsID);
        glBufferData(GL_ARRAY_BUFFER, verticesSize * vertices.format.elementsForWeights, vertices.weights, vboUsage);
    }

    for ( Int i = 0; i < 8; i++)
    {
        Float * texCoordPointer = vertices.textureCoordinates;

        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            glGenBuffers(1, &(vertexBuffer.textureCoordinatesSetID[i]));
            glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.textureCoordinatesSetID[i]);
            glBufferData(GL_ARRAY_BUFFER, verticesSize * vertices.format.elementsForTextureCoordinateSet[i], texCoordPointer, vboUsage);
            texCoordPointer += ((vertices.maxVertex + 1) * vertices.format.elementsForTextureCoordinateSet[i]);
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

    if ( error != GL_NO_ERROR )
    {
        NPLOG_ERROR(([ NSString stringWithFormat:@"%s",gluErrorString(error)]));
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

    for ( Int i = 0; i < 8; i++ )
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

    for ( Int i = 0; i < 8; i++)
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

    for ( Int i = 0; i < 8; i++)
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

    for ( Int i = 0; i < 8; i++)
    {
        Float * texCoordPointer = vertices.textureCoordinates;

        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            glActiveTexture(GL_TEXTURE0 + i);
            glClientActiveTexture(GL_TEXTURE0 + i);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(vertices.format.elementsForTextureCoordinateSet[i], GL_FLOAT, 0, texCoordPointer);
            texCoordPointer += ((vertices.maxVertex + 1) * vertices.format.elementsForTextureCoordinateSet[i]);
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

    for ( Int i = 0; i < 8; i++)
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            glClientActiveTexture(GL_TEXTURE0 + i);
            glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        }
    }

    glClientActiveTexture(GL_TEXTURE0);

}

- (Float *) positions
{
    return vertices.positions;
}

- (Int) elementsForPosition
{
    return vertices.format.elementsForPosition;
}

- (Int) vertexCount
{
    return ( vertices.maxVertex + 1);
}

- (void) setPositions:(Float *)newPositions elementsForPosition:(Int)newElementsForPosition vertexCount:(Int)newVertexCount;
{
    if ( newElementsForPosition < 1 || newElementsForPosition > 4 )
    {
        NPLOG_WARNING(([NSString stringWithFormat:@"Invalid positions element count %d",newElementsForPosition]));
        return;
    }

    if ( newVertexCount < 1 )
    {
        NPLOG_WARNING(([NSString stringWithFormat:@"Invalid vertex count %d",newElementsForPosition]));
        return;
    }

    if ( vertices.positions != NULL && vertices.positions != newPositions )
    {
        FREE(vertices.positions);
    }

    vertices.positions = newPositions;
    vertices.format.elementsForPosition = newElementsForPosition;
    vertices.maxVertex = newVertexCount - 1;
}

- (Float *) normals
{
    return vertices.normals;
}

- (void) setNormals:(Float *)newNormals withElementsForNormal:(Int)newElementsForNormal
{
    if ( vertices.normals != NULL && vertices.normals != newNormals )
    {
        FREE(vertices.normals);
    }

    vertices.format.elementsForNormal = newElementsForNormal;
    vertices.normals = newNormals;
}

- (Float *) colors
{
    return vertices.colors;
}

- (void) setColors:(Float *)newColors withElementsForColor:(Int)newElementsForColor
{
    if ( vertices.colors != NULL && vertices.colors != newColors )
    {
        FREE(vertices.colors);
    }

    vertices.format.elementsForColor = newElementsForColor;
    vertices.normals = newColors;
}

- (Float *) weights
{
    return vertices.weights;
}

- (void) setWeights:(Float *)newWeights withElementsForWeights:(Int)newElementsForWeights
{
    if ( vertices.weights != NULL && vertices.weights != newWeights )
    {
        FREE(vertices.weights);
    }

    vertices.format.elementsForWeights = newElementsForWeights;
    vertices.normals = newWeights;
}

- (Int *) indices
{
    return vertices.indices;
}

- (void) setIndices:(Int *)newIndices indexCount:(Int)newIndexCount
{
    if ( vertices.indices != NULL && vertices.indices != newIndices)
    {
        FREE(vertices.indices);
    }

    vertices.indices  = newIndices;
    vertices.indexed  = YES;
    vertices.maxIndex = newIndexCount - 1;
}

@end
