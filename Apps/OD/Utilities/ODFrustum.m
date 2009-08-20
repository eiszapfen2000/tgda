#define _GNU_SOURCE

#import "NP.h"
#import "ODCore.h"
#import "Entities/ODCamera.h"
#import "ODScene.h"
#import "ODSceneManager.h"
#import <stdlib.h>

#import "ODFrustum.h"

int compare_floats (const float * a, const float * b)
{
    float temp = *a - *b;

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
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    frustumCornerPositions = ALLOC_ARRAY(FVertex3, 8);

    frustumFaceVertices = ALLOC_ARRAY(Float, 24);
    frustumLineVertices = ALLOC_ARRAY(Float, 24);

    frustumFaceIndices  = ALLOC_ARRAY(Int, 24);
    defaultFaceIndices  = ALLOC_ARRAY(Int, 24);
    frustumLineIndices  = ALLOC_ARRAY(Int, 24);

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

    for (Int i = 0; i < 24; i++ )
    {
        frustumFaceIndices[i] = defaultFaceIndices[i];
    }    

    frustumFaceGeometry = [[ NPVertexBuffer alloc ] initWithName:@"FaceGeometry" parent:self ];
    [ frustumFaceGeometry setIndices:frustumFaceIndices indexCount:24 ];
    [ frustumFaceGeometry setPositions:frustumFaceVertices elementsForPosition:3 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT vertexCount:8 ];

    frustumLineGeometry = [[ NPVertexBuffer alloc ] initWithName:@"LineGeometry" parent:self ];
    [ frustumLineGeometry setIndices:frustumLineIndices indexCount:24 ];
    [ frustumLineGeometry setPositions:frustumLineVertices elementsForPosition:3 dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT vertexCount:8 ];

    nearPlaneHalfHeight = 0.0f;
    nearPlaneHalfWidth  = 0.0f;
    farPlaneHalfHeight  = 0.0f;
    farPlaneHalfWidth   = 0.0f;

    farPlaneHalfWidthV   = fv3_alloc_init();
    nearPlaneHalfWidthV  = fv3_alloc_init();
    farPlaneHalfHeightV  = fv3_alloc_init();
    nearPlaneHalfHeightV = fv3_alloc_init();

    positionToNearPlaneCenter = fv3_alloc_init();
    positionToFarPlaneCenter  = fv3_alloc_init();

    forward = fv3_alloc_init();
    up      = fv3_alloc_init();
    right   = fv3_alloc_init();

    frustumEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"default.cgfx" ];

    return self;
}

- (void) dealloc
{
    [ frustumLineGeometry release ];
    [ frustumFaceGeometry release ];

    SAFE_FREE(frustumCornerPositions);

    forward = fv3_free(forward);
    up      = fv3_free(up);
    right   = fv3_free(right);

    positionToNearPlaneCenter = fv3_free(positionToNearPlaneCenter);
    positionToFarPlaneCenter  = fv3_free(positionToFarPlaneCenter);

    farPlaneHalfWidthV   = fv3_free(farPlaneHalfWidthV);
    nearPlaneHalfWidthV  = fv3_free(nearPlaneHalfWidthV);
    farPlaneHalfHeightV  = fv3_free(farPlaneHalfHeightV);
    nearPlaneHalfHeightV = fv3_free(nearPlaneHalfHeightV);

    [ super dealloc ];
}

- (Float) nearPlaneHeight
{
    return nearPlaneHeight;
}

- (Float) nearPlaneWidth
{
    return nearPlaneWidth;
}

- (Float) farPlaneHeight
{
    return farPlaneHeight;
}

- (Float) farPlaneWidth
{
    return farPlaneWidth;
}


- (void) updateWithPosition:(FVector3 *)position
                orientation:(FQuaternion *)orientation
                        fov:(Float)fov
                  nearPlane:(Float)nearPlane
                   farPlane:(Float)farPlane
                aspectRatio:(Float)aspectRatio
{
    Float fovradians = DEGREE_TO_RADIANS(fov/2.0f);

    nearPlaneHeight = 2.0f * tanf(fovradians) * nearPlane;
    nearPlaneWidth  = nearPlaneHeight * aspectRatio;
    farPlaneHeight  = 2.0f * tanf(fovradians) * farPlane;
    farPlaneWidth   = farPlaneHeight * aspectRatio;

    nearPlaneHalfHeight = nearPlaneHeight / 2.0f;
    nearPlaneHalfWidth  = nearPlaneWidth  / 2.0f;
    farPlaneHalfHeight  = farPlaneHeight  / 2.0f;
    farPlaneHalfWidth   = farPlaneWidth   / 2.0f;

    fquat_q_forward_vector_v(orientation, forward);
    fv3_v_normalise(forward);

    fquat_q_up_vector_v(orientation, up);
    fv3_v_normalise(up);

    fquat_q_right_vector_v(orientation, right);
    fv3_v_normalise(right);

    FVector3 * tmp = fv3_alloc_init_with_fv3(forward);
    fv3_sv_scale(&farPlane, tmp);
    fv3_vv_add_v(position, tmp, positionToFarPlaneCenter);

    fv3_v_init_with_fv3(tmp,forward);
    fv3_sv_scale(&nearPlane, tmp);
    fv3_vv_add_v(position, tmp, positionToNearPlaneCenter);

    fv3_v_init_with_fv3(farPlaneHalfWidthV, right);
    fv3_v_init_with_fv3(nearPlaneHalfWidthV, right);
    fv3_v_init_with_fv3(farPlaneHalfHeightV, up);
    fv3_v_init_with_fv3(nearPlaneHalfHeightV, up);

    fv3_sv_scale(&farPlaneHalfWidth , farPlaneHalfWidthV);
    fv3_sv_scale(&nearPlaneHalfWidth, nearPlaneHalfWidthV);
    fv3_sv_scale(&farPlaneHalfHeight, farPlaneHalfHeightV);
    fv3_sv_scale(&nearPlaneHalfHeight, nearPlaneHalfHeightV);

    // near plane stuff
    fv3_vv_add_v(nearPlaneHalfHeightV, nearPlaneHalfWidthV, tmp);
    fv3_vv_add_v(positionToNearPlaneCenter, tmp, &frustumCornerPositions[NEARPLANE_UPPERRIGHT]);
    fv3_vv_sub_v(positionToNearPlaneCenter, tmp, &frustumCornerPositions[NEARPLANE_LOWERLEFT]);

    fv3_vv_add_v(positionToNearPlaneCenter, nearPlaneHalfHeightV, tmp);
    fv3_vv_sub_v(tmp, nearPlaneHalfWidthV, &frustumCornerPositions[NEARPLANE_UPPERLEFT]);

    fv3_vv_sub_v(positionToNearPlaneCenter, nearPlaneHalfHeightV, tmp);
    fv3_vv_add_v(tmp, nearPlaneHalfWidthV, &frustumCornerPositions[NEARPLANE_LOWERRIGHT]);

    // far plane stuff
    fv3_vv_add_v(farPlaneHalfHeightV, farPlaneHalfWidthV, tmp);
    fv3_vv_add_v(positionToFarPlaneCenter, tmp, &frustumCornerPositions[FARPLANE_UPPERRIGHT]);
    fv3_vv_sub_v(positionToFarPlaneCenter, tmp, &frustumCornerPositions[FARPLANE_LOWERLEFT]);

    fv3_vv_add_v(positionToFarPlaneCenter, farPlaneHalfHeightV, tmp);
    fv3_vv_sub_v(tmp, farPlaneHalfWidthV, &frustumCornerPositions[FARPLANE_UPPERLEFT]);

    fv3_vv_sub_v(positionToFarPlaneCenter, farPlaneHalfHeightV, tmp);
    fv3_vv_add_v(tmp, farPlaneHalfWidthV, &frustumCornerPositions[FARPLANE_LOWERRIGHT]);

    for ( Int i = 0; i < 8; i++ )
    {
        frustumFaceVertices[i*3]     = frustumLineVertices[i*3]     = frustumCornerPositions[i].x;
        frustumFaceVertices[i*3 + 1] = frustumLineVertices[i*3 + 1] = frustumCornerPositions[i].y;
        frustumFaceVertices[i*3 + 2] = frustumLineVertices[i*3 + 2] = frustumCornerPositions[i].z;
    }

    tmp = fv3_free(tmp);
}

- (void) render
{
    ODCamera * camera = [[[[ NP applicationController ] sceneManager ] currentScene ] camera ];
    FVector3 * position = [ camera position ];

    Float squareDistances[6];
    Float sortedSquareDistances[6];

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

    [[[[ NP Core ] transformationStateManager ] currentTransformationState ] resetModelMatrix ];

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
}

@end
