#import "ODFrustum.h"

#import "Graphics/npgl.h"
#import "Graphics/Model/NPVertexBuffer.h"

@implementation ODFrustum

- (id) init
{
    return [ self initWithName:@"ODFrustum" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    for ( Int i = 0; i < 8; i++ )
    {
        frustumCornerPositions[i] = fv3_alloc_init();
    }

    frustumGeometry = [[ NPVertexBuffer alloc ] initWithName:@"Projector Geometry" parent:self ];
    frustumVertices = ALLOC_ARRAY(Float,24);

    //frustumIndices = {0,1,1,2,2,3,3,0,4,5,5,6,6,7,7,4,0,4,1,5,2,6,3,7};
    frustumIndices = ALLOC_ARRAY(Int,24);
    frustumIndices[0] = frustumIndices[7] = frustumIndices[16] = 0;
    frustumIndices[1] = frustumIndices[2] = frustumIndices[18] = 1;
    frustumIndices[3] = frustumIndices[4] = frustumIndices[20] = 2;
    frustumIndices[5] = frustumIndices[6] = frustumIndices[22] = 3;
    frustumIndices[8] = frustumIndices[15] = frustumIndices[17] = 4;
    frustumIndices[9] = frustumIndices[10] = frustumIndices[19] = 5;
    frustumIndices[11] = frustumIndices[12] = frustumIndices[21] = 6;
    frustumIndices[13] = frustumIndices[14] = frustumIndices[23] = 7;

    [ frustumGeometry setIndices:frustumIndices indexCount:24 ];
    [ frustumGeometry setPositions:frustumVertices vertexCount:8 ];
    [ frustumGeometry setPrimitiveType:NP_VBO_PRIMITIVES_LINES ];

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

    return self;
}

- (void) dealloc
{
    [ frustumGeometry release ];

    for ( Int i = 0; i < 8; i++ )
    {
        frustumCornerPositions[i] = fv3_free(frustumCornerPositions[i]);
    }

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

- (FVector3 **) frustumCornerPositions
{
    return frustumCornerPositions;
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

    fquat_q_forward_vector_v(orientation,forward);
    fv3_v_normalise(forward);

    fquat_q_up_vector_v(orientation,up);
    fv3_v_normalise(up);

    fquat_q_right_vector_v(orientation,right);
    fv3_v_normalise(right);

    FVector3 * tmp = fv3_alloc_init_with_fv3(forward);
    fv3_sv_scale(&farPlane, tmp);
    fv3_vv_add_v(position, tmp, positionToFarPlaneCenter);

    fv3_v_init_with_fv3(tmp,forward);
    fv3_sv_scale(&nearPlane, tmp);
    fv3_vv_add_v(position, tmp, positionToNearPlaneCenter);

    fv3_v_init_with_fv3(farPlaneHalfWidthV,right);
    fv3_v_init_with_fv3(nearPlaneHalfWidthV,right);
    fv3_v_init_with_fv3(farPlaneHalfHeightV,up);
    fv3_v_init_with_fv3(nearPlaneHalfHeightV,up);

    fv3_sv_scale(&farPlaneHalfWidth ,  farPlaneHalfWidthV);
    fv3_sv_scale(&nearPlaneHalfWidth,  nearPlaneHalfWidthV);
    fv3_sv_scale(&farPlaneHalfHeight,  farPlaneHalfHeightV);
    fv3_sv_scale(&nearPlaneHalfHeight, nearPlaneHalfHeightV);

    // near plane stuff
    fv3_vv_add_v(nearPlaneHalfHeightV, nearPlaneHalfWidthV, tmp);
    fv3_vv_add_v(positionToNearPlaneCenter, tmp, frustumCornerPositions[NEARPLANE_UPPERRIGHT]);
    fv3_vv_sub_v(positionToNearPlaneCenter, tmp, frustumCornerPositions[NEARPLANE_LOWERLEFT]);

    fv3_vv_add_v(positionToNearPlaneCenter, nearPlaneHalfHeightV, tmp);
    fv3_vv_sub_v(tmp, nearPlaneHalfWidthV, frustumCornerPositions[NEARPLANE_UPPERLEFT]);

    fv3_vv_sub_v(positionToNearPlaneCenter, nearPlaneHalfHeightV, tmp);
    fv3_vv_add_v(tmp, nearPlaneHalfWidthV, frustumCornerPositions[NEARPLANE_LOWERRIGHT]);

    // far plane stuff
    fv3_vv_add_v(farPlaneHalfHeightV, farPlaneHalfWidthV, tmp);
    fv3_vv_add_v(positionToFarPlaneCenter, tmp, frustumCornerPositions[FARPLANE_UPPERRIGHT]);
    fv3_vv_sub_v(positionToFarPlaneCenter, tmp, frustumCornerPositions[FARPLANE_LOWERLEFT]);

    fv3_vv_add_v(positionToFarPlaneCenter, farPlaneHalfHeightV, tmp);
    fv3_vv_sub_v(tmp, farPlaneHalfWidthV, frustumCornerPositions[FARPLANE_UPPERLEFT]);

    fv3_vv_sub_v(positionToFarPlaneCenter, farPlaneHalfHeightV, tmp);
    fv3_vv_add_v(tmp, farPlaneHalfWidthV, frustumCornerPositions[FARPLANE_LOWERRIGHT]);

    for ( Int i = 0; i < 8; i++ )
    {
        frustumVertices[i*3]   = frustumCornerPositions[i]->x;
        frustumVertices[i*3+1] = frustumCornerPositions[i]->y;
        frustumVertices[i*3+2] = frustumCornerPositions[i]->z;

        //NSLog(@"corner %f %f %f",frustumCornerPositions[i]->x,frustumCornerPositions[i]->y,frustumCornerPositions[i]->z);
    }

    tmp = fv3_free(tmp);
}

- (void) render
{
    [ frustumGeometry render ]; //WithPrimitiveType:NP_VBO_PRIMITIVES_LINES firstIndex:0 andLastIndex:23 ];
}

@end
