#import "NP.h"

#import "ODProjector.h"
#import "ODFrustum.h"
#import "ODCamera.h"
#import "ODScene.h"

@implementation ODProjector

- (id) init
{
	return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
	return [ self initWithName:@"OD Projector" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
	self = [ super initWithName:newName parent:newParent ];

	view = fm4_alloc_init();
    projection = fm4_alloc_init();
    viewProjection = fm4_alloc_init();
    inverseViewProjection = fm4_alloc_init();

	orientation = fquat_alloc_init();
	position = fv3_alloc_init();

    yaw   = 0.0f;
    pitch = 0.0f;

    forward = fv3_alloc_init();
    up      = fv3_alloc_init();
    right   = fv3_alloc_init();
    V_Z(*forward) = -1.0;

    renderFrustum = NO;
    frustum = [[ ODFrustum alloc ] initWithName:@"Projector Frustum" parent:self ];

	return self;
}

- (void) dealloc
{
	view = fm4_free(view);
	viewProjection = fm4_free(viewProjection);
    inverseViewProjection = fm4_free(inverseViewProjection);

	orientation = fquat_free(orientation);
	position = fv3_free(position);

    forward = fv3_free(forward);
    up      = fv3_free(up);
    right   = fv3_free(right);

    [ frustum release ];

	[ super dealloc ];
}

- (void) reset
{
	fm4_m_set_identity(view);
	fm4_m_set_identity(projection);
	fm4_m_set_identity(viewProjection);
	fm4_m_set_identity(inverseViewProjection);

	fquat_set_identity(orientation);
	fv3_v_zeros(position);
}

- (FVector3 *) position
{
	return position;
}

- (void) setPosition:(FVector3 *)newPosition
{
	*position = *newPosition;
}

- (void) setRenderFrustum:(BOOL)newRenderFrustum
{
    renderFrustum = newRenderFrustum;
}

- (ODFrustum *) frustum
{
    return frustum;
}

- (FMatrix4 *) projection
{
    return projection;
}

- (FMatrix4 *) viewProjection
{
    return viewProjection;
}

- (FMatrix4 *) inverseViewProjection
{
    return inverseViewProjection;
}

- (void) updateYaw:(Float)degrees
{
    if ( degrees != 0.0f )
    {
        yaw += degrees;

        if ( yaw < -360.0f )
        {
            yaw += 360.0f;
        }

        if ( yaw > 360.0f )
        {
            yaw -= 360.0f;
        }
    }
}

- (void) updatePitch:(Float)degrees
{
    if ( degrees != 0.0f )
    {
        pitch += degrees;

        if ( pitch < -360.0f )
        {
            pitch += 360.0f;
        }

        if ( pitch > 360.0f )
        {
            pitch -= 360.0f;
        }
    }
}

- (void) cameraRotateUsingYaw:(Float)yawDegrees andPitch:(Float)pitchDegrees
{
    [ self updateYaw:yawDegrees ];
    [ self updatePitch:pitchDegrees ];

    fquat_q_init_with_axis_and_degrees(orientation,NP_WORLDF_Y_AXIS,&yaw);
    fquat_q_rotatex(orientation,&pitch);
}

- (void) moveForward
{
    fquat_q_forward_vector_v(orientation,forward);

    V_X(*position) += V_X(*forward);
    V_Y(*position) += V_Y(*forward);
    V_Z(*position) += V_Z(*forward);
}

- (void) moveBackward
{
    fquat_q_forward_vector_v(orientation,forward);

    V_X(*position) -= V_X(*forward);
    V_Y(*position) -= V_Y(*forward);
    V_Z(*position) -= V_Z(*forward);
}

- (void) updateProjection
{
    ODCamera * camera = [ (ODScene *)parent camera ];

    fov         = [ camera fov ];
    nearPlane   = [ camera nearPlane ];
    farPlane    = [ camera farPlane ];
    aspectRatio = [ camera aspectRatio];

    fm4_m_init_with_fm4(projection,[ camera projection ]);
}

- (void) updateView
{
    fm4_m_set_identity(view);

    FQuaternion q;
    fquat_q_conjugate_q(orientation, &q);

    FMatrix4 rotate;
    fquat_q_to_fmatrix4_m(&q, &rotate);

    FMatrix4 tmp;
    fm4_mm_multiply_m(view, &rotate, &tmp);

    FVector3 invpos;
    fv3_v_invert_v(position, &invpos);

    FMatrix4 trans;
    fm4_mv_translation_matrix(&trans, &invpos);

    fm4_mm_multiply_m(&tmp, &trans, view);
}

- (void) update
{
    [ self updateProjection ];
	[ self updateView ];
    [ frustum updateWithPosition:position
                     orientation:orientation
                             fov:fov
                       nearPlane:nearPlane
                        farPlane:farPlane
                     aspectRatio:aspectRatio ];

    fm4_mm_multiply_m(projection, view, viewProjection);
    fm4_m_inverse_m(viewProjection, inverseViewProjection);
}

- (void) render
{
    if ( renderFrustum == YES )
    {
        [ frustum render ];
    }
}

@end
