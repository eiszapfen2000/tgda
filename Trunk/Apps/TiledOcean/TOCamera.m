#import "TOCamera.h"
#import "Graphics/npgl.h"
#import "Core/World/NPTransformationState.h"
#import "Core/World/NPTransformationStateManager.h"
#import "Core/NPEngineCore.h"

@implementation TOCamera

- (id) init
{
	return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
	return [ self initWithName:@"TOCamera" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
	self = [ super initWithName:newName parent:newParent ];

	view = fm4_alloc_init();
	projection = fm4_alloc_init();

	orientation = quat_alloc_init();
	position = fv3_alloc_init();

    fov = 45.0f;
    nearPlane = 0.1f;
    farPlane = 50.0f;
    aspectRatio = 1.0f;

    yaw = 0.0;
    pitch = 0.0;
    forward = v3_alloc_init();
    V_Z(*forward) = -1.0;

	return self;
}

- (void) dealloc
{
	view = fm4_free(view);
	projection = fm4_free(projection);

	orientation = quat_free(orientation);
	position = fv3_free(position);

	[ super dealloc ];
}

- (void) reset
{
	fm4_m_set_identity(view);
	fm4_m_set_identity(projection);

	quat_set_identity(orientation);
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

- (void) setFov:(Float)newFov
{
	fov = newFov;
}

- (void) setNearPlane:(Float)newNearPlane
{
	nearPlane = newNearPlane;
}

- (void) setFarPlane:(Float)newFarPlane
{
	farPlane = newFarPlane;
}

- (void) setAspectRatio:(Float)newAspectRatio
{
	aspectRatio = newAspectRatio;
}

/*- (void) rotateX:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        //degrees = -degrees;

        quat_q_rotatex(orientation, &degrees);
    }
}

- (void) rotateY:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        degrees = -degrees;

        quat_q_rotatey(orientation, &degrees);
    }
}

- (void) rotateZ:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        degrees = -degrees;
        quat_q_rotatez(orientation, &degrees);
    }
}*/

- (void) updateYaw:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        yaw += degrees;

        if ( yaw < -360.0 )
        {
            yaw += 360.0;
        }

        if ( yaw > 360.0 )
        {
            yaw -= 360.0;
        }
    }
}

- (void) updatePitch:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        pitch += degrees;

        if ( pitch < -360.0 )
        {
            pitch += 360.0;
        }

        if ( pitch > 360.0 )
        {
            pitch -= 360.0;
        }

        NSLog(@"%f",pitch);
    }
}

- (void) cameraRotateUsingYaw:(Double)yawDegrees andPitch:(Double)pitchDegrees
{
    [ self updateYaw:yawDegrees ];
    [ self updatePitch:pitchDegrees ];

    quat_q_init_with_axis_and_degrees(orientation,NP_WORLD_Y_AXIS,&yaw);
    quat_q_rotatex(orientation,&pitch);
}

- (void) moveForward
{
    quat_q_forward_vector_v(orientation,forward);

    FV_X(*position) += V_X(*forward);
    FV_Y(*position) += V_Y(*forward);
    FV_Z(*position) += V_Z(*forward);
}

- (void) moveBackward
{
    quat_q_forward_vector_v(orientation,forward);

    FV_X(*position) -= V_X(*forward);
    FV_Y(*position) -= V_Y(*forward);
    FV_Z(*position) -= V_Z(*forward);
}

- (void) updateProjection
{
    glMatrixMode(GL_PROJECTION);

    fm4_msss_projection_matrix(projection, aspectRatio, fov, nearPlane, farPlane);

    glLoadMatrixf((Float *)(FM_ELEMENTS(*projection)));
    glMatrixMode(GL_MODELVIEW);
}

- (void) updateView
{
    fm4_m_set_identity(view);

    Quaternion q;
    quat_q_conjugate_q(orientation, &q);

    FMatrix4 rotate;
    quat_q_to_fmatrix4_m(&q, &rotate);

    FMatrix4 tmp;
    fm4_mm_multiply_m(view, &rotate, &tmp);

    FVector3 invpos;
    fv3_v_invert_v(position, &invpos);

    FMatrix4 trans;
    fm4_mv_translation_matrix(&trans, &invpos);

    fm4_mm_multiply_m(&tmp, &trans, view);

    glLoadMatrixf((Float *)(FM_ELEMENTS(*view)));
}

- (void) update
{
	[ self updateProjection ];
	[ self updateView ];
}

- (void) render
{
    NPTransformationState * trafo = [[[ NPEngineCore instance ] transformationStateManager ] currentActiveTransformationState ];
    [ trafo setViewMatrix:view ];
    [ trafo setProjectionMatrix:projection ];
}

@end
