#define _GNU_SOURCE
#import <stdlib.h>
#import "ODFrustum.h"

int compare_floats (const void * a, const void * b)
{
    float temp = *((float *)a) - *((float *)b);

    if (temp > 0.0f)
    {
        return -1;
    }
    else if (temp < 0.0f)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}


@implementation ODFrustum

- (id) init
{
    return [ self initWithName:@"ODFrustum" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    frustumLineIndices[0] = frustumLineIndices[7] = frustumLineIndices[16] = 0;
    frustumLineIndices[1] = frustumLineIndices[2] = frustumLineIndices[18] = 1;
    frustumLineIndices[3] = frustumLineIndices[4] = frustumLineIndices[20] = 2;
    frustumLineIndices[5] = frustumLineIndices[6] = frustumLineIndices[22] = 3;
    frustumLineIndices[8] = frustumLineIndices[15] = frustumLineIndices[17] = 4;
    frustumLineIndices[9] = frustumLineIndices[10] = frustumLineIndices[19] = 5;
    frustumLineIndices[11] = frustumLineIndices[12] = frustumLineIndices[21] = 6;
    frustumLineIndices[13] = frustumLineIndices[14] = frustumLineIndices[23] = 7;

    // Quad on near plane
    defaultFaceIndices[0] = 0;
    defaultFaceIndices[1] = 1;
    defaultFaceIndices[2] = 2;
    defaultFaceIndices[3] = 3;

    // Quad on far plane
    defaultFaceIndices[4] = 4;
    defaultFaceIndices[5] = 5;
    defaultFaceIndices[6] = 6;
    defaultFaceIndices[7] = 7;

    //Top Quad
    defaultFaceIndices[8] = 3;
    defaultFaceIndices[9] = 2;
    defaultFaceIndices[10] = 6;
    defaultFaceIndices[11] = 7;

    //Bottom Quad
    defaultFaceIndices[12] = 0;
    defaultFaceIndices[13] = 1;
    defaultFaceIndices[14] = 5;
    defaultFaceIndices[15] = 4;

    // Left quad
    defaultFaceIndices[16]  = 3;
    defaultFaceIndices[17]  = 0;
    defaultFaceIndices[18] = 4;
    defaultFaceIndices[19] = 7;

    //Right Quad
    defaultFaceIndices[20] = 1;
    defaultFaceIndices[21] = 2;
    defaultFaceIndices[22] = 6;
    defaultFaceIndices[23] = 5;

    memcpy(frustumFaceIndices, defaultFaceIndices, sizeof(defaultFaceIndices));

    /*
    frustumFaceGeometry = [[ NPVertexBuffer alloc ] initWithName:@"FaceGeometry" parent:self ];
    [ frustumFaceGeometry setIndices:frustumFaceIndices indexCount:24 ];
    [ frustumFaceGeometry setPositions:frustumFaceVertices elementsForPosition:3 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT vertexCount:8 ];

    frustumLineGeometry = [[ NPVertexBuffer alloc ] initWithName:@"LineGeometry" parent:self ];
    [ frustumLineGeometry setIndices:frustumLineIndices indexCount:24 ];
    [ frustumLineGeometry setPositions:frustumLineVertices elementsForPosition:3 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT vertexCount:8 ];
    */

    nearPlaneHalfHeight = 0.0f;
    nearPlaneHalfWidth  = 0.0f;
    farPlaneHalfHeight  = 0.0f;
    farPlaneHalfWidth   = 0.0f;

    fv3_v_init_with_zeros(&farPlaneHalfWidthV);
    fv3_v_init_with_zeros(&nearPlaneHalfWidthV);
    fv3_v_init_with_zeros(&farPlaneHalfHeightV);
    fv3_v_init_with_zeros(&nearPlaneHalfHeightV);

    fv3_v_init_with_zeros(&positionToNearPlaneCenter);
    fv3_v_init_with_zeros(&positionToFarPlaneCenter);

    fv3_v_init_with_zeros(&forward);
    fv3_v_init_with_zeros(&up);
    fv3_v_init_with_zeros(&right);

    //frustumEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"default.cgfx" ];

    return self;
}

- (void) dealloc
{
    /*
    [ frustumLineGeometry release ];
    [ frustumFaceGeometry release ];
    */

    [ super dealloc ];
}

- (float) nearPlaneHeight
{
    return nearPlaneHeight;
}

- (float) nearPlaneWidth
{
    return nearPlaneWidth;
}

- (float) farPlaneHeight
{
    return farPlaneHeight;
}

- (float) farPlaneWidth
{
    return farPlaneWidth;
}

- (void) updateWithPosition:(FVector3 *)position
                orientation:(FQuaternion *)orientation
                        fov:(float)fov
                  nearPlane:(float)nearPlane
                   farPlane:(float)farPlane
                aspectRatio:(float)aspectRatio
{
    float fovradians = DEGREE_TO_RADIANS(fov/2.0f);

    nearPlaneHeight = 2.0f * tanf(fovradians) * nearPlane;
    farPlaneHeight  = 2.0f * tanf(fovradians) * farPlane;
    nearPlaneWidth  = nearPlaneHeight * aspectRatio;
    farPlaneWidth   = farPlaneHeight * aspectRatio;

    nearPlaneHalfHeight = nearPlaneHeight / 2.0f;
    nearPlaneHalfWidth  = nearPlaneWidth  / 2.0f;
    farPlaneHalfHeight  = farPlaneHeight  / 2.0f;
    farPlaneHalfWidth   = farPlaneWidth   / 2.0f;

    fquat_q_forward_vector_v(orientation, &forward);
    fquat_q_up_vector_v(orientation, &up);
    fquat_q_right_vector_v(orientation, &right);

    fv3_v_normalise(&forward);
    fv3_v_normalise(&up);
    fv3_v_normalise(&right);

    FVector3 positionToFarPlane  = fv3_sv_scaled(farPlane, &forward);
    FVector3 positionToNearPlane = fv3_sv_scaled(nearPlane, &forward);
    positionToFarPlaneCenter  = fv3_vv_add(position, &positionToFarPlane);
    positionToNearPlaneCenter = fv3_vv_add(position, &positionToNearPlane);

    farPlaneHalfWidthV  = fv3_sv_scaled(farPlaneHalfWidth, &right);
    farPlaneHalfHeightV = fv3_sv_scaled(farPlaneHalfHeight, &up);
    nearPlaneHalfWidthV  = fv3_sv_scaled(nearPlaneHalfWidth, &right);
    nearPlaneHalfHeightV = fv3_sv_scaled(nearPlaneHalfHeight, &up);

    // near plane stuff
    FVector3 direction = fv3_vv_add(&nearPlaneHalfHeightV, &nearPlaneHalfWidthV);
    FVector3 nearPlaneUpperCenter = fv3_vv_add(&positionToNearPlaneCenter, &nearPlaneHalfHeightV);
    FVector3 nearPlaneLowerCenter = fv3_vv_sub(&positionToNearPlaneCenter, &nearPlaneHalfHeightV);

    frustumCornerPositions[NEARPLANE_UPPERRIGHT] = fv3_vv_add(&positionToNearPlaneCenter, &direction);
    frustumCornerPositions[NEARPLANE_LOWERLEFT]  = fv3_vv_sub(&positionToNearPlaneCenter, &direction);
    frustumCornerPositions[NEARPLANE_UPPERLEFT]  = fv3_vv_sub(&nearPlaneUpperCenter, &nearPlaneHalfWidthV);
    frustumCornerPositions[NEARPLANE_LOWERRIGHT] = fv3_vv_add(&nearPlaneLowerCenter, &nearPlaneHalfWidthV);

    // far plane stuff
    direction = fv3_vv_add(&farPlaneHalfHeightV, &farPlaneHalfWidthV);
    FVector3 farPlaneUpperCenter = fv3_vv_add(&positionToFarPlaneCenter, &farPlaneHalfHeightV);
    FVector3 farPlaneLowerCenter = fv3_vv_sub(&positionToFarPlaneCenter, &farPlaneHalfHeightV);

    frustumCornerPositions[FARPLANE_UPPERRIGHT] = fv3_vv_add(&positionToFarPlaneCenter, &direction);
    frustumCornerPositions[FARPLANE_LOWERLEFT]  = fv3_vv_sub(&positionToFarPlaneCenter, &direction);
    frustumCornerPositions[FARPLANE_UPPERLEFT]  = fv3_vv_sub(&farPlaneUpperCenter, &farPlaneHalfWidthV);
    frustumCornerPositions[FARPLANE_LOWERRIGHT] = fv3_vv_add(&farPlaneLowerCenter, &farPlaneHalfWidthV);

    for ( int32_t i = 0; i < 8; i++ )
    {
        frustumFaceVertices[i] = frustumLineVertices[i] = frustumCornerPositions[i];
    }
}

- (void) render
{
    /*
    ODCamera * camera = [[[[ NP applicationController ] sceneManager ] currentScene ] camera ];
    FVector3 * position = [ camera position ];

    float squareDistances[6];
    float sortedSquareDistances[6];

    for ( Int i = 0; i < 6; i++ )
    {
        FVertex3 midPoint = fvertex_aass_calculate_indexed_MassCenter3D(frustumCornerPositions, &(defaultFaceIndices[i*4]), 8, 4);
        squareDistances[i] = fv3_vv_square_distance(&midPoint, position);
        sortedSquareDistances[i] = squareDistances[i];
    }

    qsort(sortedSquareDistances, 6, sizeof(float), compare_floats);

    for ( Int i = 0; i < 6; i++ )
    {
        Int32 index = -1;

        for ( Int j = 0; j < 6; j++ )
        {
            if ( (sortedSquareDistances[i] == squareDistances[j]) && (index == -1))
            {
                index = j;
                squareDistances[j] = 0.0f;
            }
        }

        frustumFaceIndices[i*4]   = defaultFaceIndices[index*4];
        frustumFaceIndices[i*4+1] = defaultFaceIndices[index*4+1];
        frustumFaceIndices[i*4+2] = defaultFaceIndices[index*4+2];
        frustumFaceIndices[i*4+3] = defaultFaceIndices[index*4+3];
    }

    [[[ NP Core ] transformationState ] resetModelMatrix ];

    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setBlendingMode:NP_BLENDING_AVERAGE ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] activate ];

    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] activate ];

    glLineWidth(5.0f);

    FVector4 color = { 0.0f, 1.0f, 0.0f, 0.5f };
    [ frustumEffect uploadFVector4ParameterWithName:@"color" andValue:&color ];

    [ frustumEffect activateTechniqueWithName:@"render" ];
    [ frustumFaceGeometry renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_QUADS ];

    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

    [ frustumEffect activateTechniqueWithName:@"render" ];
    [ frustumLineGeometry renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_LINES ];

    [ frustumEffect deactivate ];

    glLineWidth(1.0f);
    */
}

@end
