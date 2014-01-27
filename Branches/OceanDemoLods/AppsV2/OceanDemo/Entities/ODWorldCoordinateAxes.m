#import "Graphics/NPEngineGraphicsEnums.h"
#import "ODWorldCoordinateAxes.h"

@implementation ODWorldCoordinateAxes

- (id) init
{
    return [ self initWithName:@"ODWorldCoordinateAxes" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    axisLength = 10.0f;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (float) axisLength
{
    return axisLength;
}

- (void) setAxisLength:(float)newAxisLength
{
    axisLength = newAxisLength;
}

- (void) update:(double)frameTime
{
}

- (void) render
{
    FVector3 xAxis = fv3_sv_scaled(axisLength, NP_WORLDF_X_AXIS);
    FVector3 yAxis = fv3_sv_scaled(axisLength, NP_WORLDF_Y_AXIS);
    FVector3 zAxis = fv3_sv_scaled(axisLength, NP_WORLDF_Z_AXIS);

    const FVector3 red   = (FVector3){1.0, 0.0, 0.0};
    const FVector3 green = (FVector3){0.0, 1.0, 0.0};
    const FVector3 blue  = (FVector3){0.0, 0.0, 1.0};

    glBegin(GL_LINES);
        glVertexAttrib3f(NpVertexStreamColors, red.x, red.y, red.z);
        glVertexAttrib3f(NpVertexStreamPositions, 0.0f, 0.0f, 0.0f);
        glVertexAttrib3f(NpVertexStreamPositions, xAxis.x, xAxis.y, xAxis.z);
        glVertexAttrib3f(NpVertexStreamColors, green.x, green.y, green.z);
        glVertexAttrib3f(NpVertexStreamPositions, 0.0f, 0.0f, 0.0f);
        glVertexAttrib3f(NpVertexStreamPositions, yAxis.x, yAxis.y, yAxis.z);
        glVertexAttrib3f(NpVertexStreamColors, blue.x, blue.y, blue.z);
        glVertexAttrib3f(NpVertexStreamPositions, 0.0f, 0.0f, 0.0f);
        glVertexAttrib3f(NpVertexStreamPositions, zAxis.x, zAxis.y, zAxis.z);
    glEnd();
}

@end

