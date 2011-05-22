#import "GL/glew.h"
#import "Core/Basics/NpMemory.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPFullscreenQuad.h"

@implementation NPFullscreenQuad

- (id) init
{
    return [ self initWithName:@"NPFullscreenQuad" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    glGenVertexArrays(1, &vertexArrayID);
    glGenBuffers(1, &vertexStreamID);
    glGenBuffers(1, &texcoordStreamID);

    FVector2 minTexCoord = { 0.0f, 0.0f };
    FVector2 maxTexCoord = { 1.0f, 1.0f };

    [ self setupGeometryUsingAspectRatio:1.0f
                    minTextureCoordinate:minTexCoord
                    maxTextureCoordinate:maxTexCoord ];

    return self;
}

- (void) dealloc
{
    glDeleteVertexArrays(1, &vertexArrayID);
    glDeleteBuffers(1, &texcoordStreamID);
    glDeleteBuffers(1, &vertexStreamID);

    [ super dealloc ];
}

- (void) setupGeometryUsingAspectRatio:(const float)aspectRatio
                  minTextureCoordinate:(const FVector2)minTextureCoordinate
                  maxTextureCoordinate:(const FVector2)maxTextureCoordinate
{
    FVertex2 * vertices  = ALLOC_ARRAY(FVertex2, 6);
    FVertex2 * texcoords = ALLOC_ARRAY(FVertex2, 6);

    FVertex2 minVertex = (FVertex2){-aspectRatio, -1.0f};
    FVertex2 maxVertex = (FVertex2){ aspectRatio,  1.0f};

    vertices[0] = vertices[5] = minVertex;
    vertices[2] = vertices[3] = maxVertex;
    vertices[1].x = aspectRatio;
    vertices[1].y = -1.0f;
    vertices[4].x = -aspectRatio;
    vertices[4].y =  1.0f;

    texcoords[0] = texcoords[5] = minTextureCoordinate;
    texcoords[2] = texcoords[3] = maxTextureCoordinate;
    texcoords[1].x = maxTextureCoordinate.x;
    texcoords[1].y = minTextureCoordinate.y;
    texcoords[4].x = minTextureCoordinate.x;
    texcoords[4].y = maxTextureCoordinate.y;

    glBindBuffer(GL_ARRAY_BUFFER, vertexStreamID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(FVertex2) * 6, vertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glBindBuffer(GL_ARRAY_BUFFER, texcoordStreamID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(FVertex2) * 6, texcoords, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    FREE(texcoords);
    FREE(vertices);

    glBindVertexArray(vertexArrayID);

        glBindBuffer(GL_ARRAY_BUFFER, vertexStreamID);
            glVertexAttribPointer(NpVertexStreamPositions, 2, GL_FLOAT, GL_FALSE, 0, 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glEnableVertexAttribArray(NpVertexStreamPositions);

        glBindBuffer(GL_ARRAY_BUFFER, texcoordStreamID);
            glVertexAttribPointer(NpVertexStreamTexCoords0, 2, GL_FLOAT, GL_FALSE, 0, 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glEnableVertexAttribArray(NpVertexStreamTexCoords0);

    glBindVertexArray(0);
}

- (void) render
{
    glBindVertexArray(vertexArrayID);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArray(0);
}

@end
