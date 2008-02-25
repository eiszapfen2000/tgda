#import "NPVertexBuffer.h"
#import "Graphics/npgl.h"
#import "Core/Basics/NpMemory.h"
#import "Core/NPEngineCore.h"


void reset_npvertexformat(NpVertexFormat * vertex_format)
{
    vertex_format->elementsForNormal = 0;
    vertex_format->elementsForColor = 0;
    vertex_format->elementsForWeights = 0;

    for ( Int i = 0; i < 8; i++ )
    {
        vertex_format->elementsForTextureCoordinateSet[i] = 0;
    }

    vertex_format->maxTextureCoordinateSet = 0;
}

void reset_npvertices(NpVertices * vertices)
{
    reset_npvertexformat(&(vertices->format));

    vertices->primitiveType = -1;

    if ( vertices->positions != NULL )
    {
        FREE(vertices->positions);
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

    vertices->indexed = NO;
    vertices->maxVertex = 0;
    vertices->maxIndex = 0;
}

void reset_npvertexbuffer(NpVertexBuffer * vertex_buffer)
{
    vertex_buffer->positionsID = -1;
    vertex_buffer->normalsID = -1;
    vertex_buffer->colorsID = -1;
    vertex_buffer->weightsID = -1;

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

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPVertexBuffer" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];    

    return self;
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName:[ file fileName ] ];

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

    if ( vertexCount <= 0 )
    {
        return NO;
    }

    if ( vertices.indexed == YES )
    {
        NSLog(@"indexed");
        
        [ file readInt32:&indexCount ];
        NSLog(@"Index count: %d",indexCount);

        if ( indexCount <= 0 )
        {
            return NO;
        }
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

    return YES;
}

- (void) reset
{
    reset_npvertexbuffer(&vertexBuffer);
    reset_npvertices(&vertices);

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}

- (void) uploadVBOWithUsageHint:(NPState)usage
{
    if ( ready == NO )
    {
        NPLOG(@"VBO not ready");
        return;
    }

    [ self deleteVBO ];

    GLenum vboUsage;

    switch( usage )
    {
        case NP_VBO_UPLOAD_ONCE_RENDER_OFTEN:
        {
            vboUsage = GL_STATIC_DRAW;
            break;
        }
        case NP_VBO_UPLOAD_ONCE_RENDER_SELDOM:
        {
            vboUsage = GL_STREAM_DRAW;
            break;
        }
        case NP_VBO_UPLOAD_OFTEN_RENDER_OFTEN:
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
    glBufferDataARB(GL_ARRAY_BUFFER, verticesSize * 3, vertices.positions, vboUsage);

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

    /*if ( vertices.format.elementsForWeights > 0 )
    {
        glGenBuffers(1, &(vertexBuffer.weightsID));
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.weightsID);
        glBufferData(GL_ARRAY_BUFFER, verticesSize * vertices.format.elementsForWeights, vertices.weights, vboUsage);
    }*/

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

    Int indicesSize = (vertices.maxVertex + 1) * sizeof(Int32);

    if ( vertices.indexed == YES )
    {
        glGenBuffers(1, &(vertexBuffer.indicesID));
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.indicesID);
        glBufferData(GL_ARRAY_BUFFER, indicesSize, vertices.indices, vboUsage);
    }

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

- (void) deleteBuffer:(UInt)bufferID
{
    if ( bufferID > -1 )
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
    [ self renderElementWithFirstindex:0 andLastindex:vertices.maxIndex ];
}

- (void) renderElementWithFirstindex:(Int)firstIndex andLastindex:(Int)lastIndex
{
    glEnableClientState(GL_VERTEX_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer.positionsID );
    glVertexPointer(3, GL_FLOAT, 0, NULL);

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

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

    if ( vertices.indexed == YES )
    {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexBuffer.indicesID);
        glDrawRangeElements(vertices.primitiveType, 0, vertices.maxVertex, lastIndex - firstIndex + 1,
                            GL_UNSIGNED_INT, BUFFER_OFFSET(firstIndex*sizeof(UInt32)));
    }
    else
    {
        NSLog(@"vbo not indexed");
        return;
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

@end
