#import "Graphics/NPEngineGraphicsEnums.h"
#import "ODWorldCoordinateAxes.h"

@interface ODWorldCoordinateAxes (Private)

- (void) setup;

@end

@implementation ODWorldCoordinateAxes (Private)

- (void) setup
{
    FVector3 origin = fv3_zero();
    FVector3 xAxis  = fv3_sv_scaled(axisLength, NP_WORLDF_X_AXIS);
    FVector3 yAxis  = fv3_sv_scaled(axisLength, NP_WORLDF_Y_AXIS);
    FVector3 zAxis  = fv3_sv_scaled(axisLength, NP_WORLDF_Z_AXIS);

    const FVector3 red   = (FVector3){colorMultiplier, 0.0, 0.0};
    const FVector3 green = (FVector3){0.0, colorMultiplier, 0.0};
    const FVector3 blue  = (FVector3){0.0, 0.0, colorMultiplier};

    FVector3 * vertices = ALLOC_ARRAY(FVector3, 6);
    FVector3 * colors   = ALLOC_ARRAY(FVector3, 6);

    vertices[0] = vertices[2] = vertices[4] = origin;
    vertices[1] = xAxis; vertices[3] = yAxis; vertices[5] = zAxis;

    colors[0] = colors[1] = red;
    colors[2] = colors[3] = green;
    colors[4] = colors[5] = blue;

    glBindBuffer(GL_ARRAY_BUFFER, vertexStreamID);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(FVector3) * 6, vertices);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glBindBuffer(GL_ARRAY_BUFFER, colorStreamID);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(FVector3) * 6, colors);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    FREE(colors);
    FREE(vertices);

    glBindVertexArray(vertexArrayID);

        glBindBuffer(GL_ARRAY_BUFFER, vertexStreamID);
            glVertexAttribPointer(NpVertexStreamPositions, 3, GL_FLOAT, GL_FALSE, 0, 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glEnableVertexAttribArray(NpVertexStreamPositions);

        glBindBuffer(GL_ARRAY_BUFFER, colorStreamID);
            glVertexAttribPointer(NpVertexStreamColors, 3, GL_FLOAT, GL_FALSE, 0, 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glEnableVertexAttribArray(NpVertexStreamColors);

    glBindVertexArray(0);
}

@end

@implementation ODWorldCoordinateAxes

- (id) init
{
    return [ self initWithName:@"ODWorldCoordinateAxes" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    axisLength = 100.0f;
    colorMultiplier = 10000.0f;

    glGenVertexArrays(1, &vertexArrayID);
    glGenBuffers(1, &vertexStreamID);
    glGenBuffers(1, &colorStreamID);

    glBindBuffer(GL_ARRAY_BUFFER, vertexStreamID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(FVector3) * 6, NULL, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glBindBuffer(GL_ARRAY_BUFFER, colorStreamID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(FVector3) * 6, NULL, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    [ self setup ];

    return self;
}

- (void) dealloc
{
    glDeleteVertexArrays(1, &vertexArrayID);
    glDeleteBuffers(1, &colorStreamID);
    glDeleteBuffers(1, &vertexStreamID);

    [ super dealloc ];
}

- (float) axisLength
{
    return axisLength;
}

- (float) colorMultiplier
{
    return colorMultiplier;
}

- (void) setAxisLength:(float)newAxisLength
{
    axisLength = newAxisLength;

    [ self setup ];
}

- (void) setColorMultiplier:(float)newColorMultiplier
{
    colorMultiplier = newColorMultiplier;

    [ self setup ];
}

- (void) update:(double)frameTime
{
}

- (void) render
{
    glBindVertexArray(vertexArrayID);
        glDrawArrays(GL_LINES, 0, 6);
    glBindVertexArray(0);
}

@end
