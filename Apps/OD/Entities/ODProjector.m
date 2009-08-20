#import "NP.h"
#import "ODCore.h"
#import "Utilities/ODFrustum.h"
#import "ODProjector.h"
#import "ODCamera.h"
#import "ODOceanEntity.h"
#import "ODScene.h"
#import "ODSceneManager.h"

@implementation ODProjector

- (id) init
{
	return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
	return [ self initWithName:@"OD Projector" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
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
    frustum = [[ ODFrustum alloc ] initWithName:@"ProjectorFrustum" parent:self ];

    pitchMinusAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"PitchMinus" primaryInputAction:NP_INPUT_KEYBOARD_S ];
    pitchPlusAction  = [[[ NP Input ] inputActions ] addInputActionWithName:@"PitchPlus"  primaryInputAction:NP_INPUT_KEYBOARD_W ];
    yawMinusAction   = [[[ NP Input ] inputActions ] addInputActionWithName:@"YawMinus"   primaryInputAction:NP_INPUT_KEYBOARD_A ];
    yawPlusAction    = [[[ NP Input ] inputActions ] addInputActionWithName:@"YawPlus"    primaryInputAction:NP_INPUT_KEYBOARD_D ];

    connectedToCamera = YES;

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

- (BOOL) loadFromDictionary:(NSDictionary *)config
{
    NSString * projectorName   = [ config objectForKey:@"Name" ];
    NSArray  * positionStrings = [ config objectForKey:@"Position" ];

    if ( projectorName == nil || positionStrings == nil )
    {
        NPLOG_ERROR(@"%@: Dictionary incomplete", name);
        return NO;
    }

    [ self setName:projectorName ];

    position->x = [[ positionStrings objectAtIndex:0 ] floatValue ];
    position->y = [[ positionStrings objectAtIndex:1 ] floatValue ];
    position->z = [[ positionStrings objectAtIndex:2 ] floatValue ];

    return YES;
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

- (ODFrustum *) frustum
{
    return frustum;
}

- (FMatrix4 *) view
{
    return view;
}

- (FMatrix4 *) projection
{
    return projection;
}

- (FMatrix4 *) inverseViewProjection
{
    return inverseViewProjection;
}

- (void) setPosition:(FVector3 *)newPosition
{
	*position = *newPosition;
}

- (void) setRenderFrustum:(BOOL)newRenderFrustum
{
    renderFrustum = newRenderFrustum;
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

    fquat_q_init_with_axis_and_degrees(orientation,NP_WORLDF_Y_AXIS, &yaw);
    fquat_q_rotatex(orientation, &pitch);
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
    fquat_q_forward_vector_v(orientation, forward);

    V_X(*position) -= V_X(*forward);
    V_Y(*position) -= V_Y(*forward);
    V_Z(*position) -= V_Z(*forward);
}

- (void) activate
{
    NPTransformationState * trafo = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
    [ trafo setViewMatrix:view ];
    [ trafo setProjectionMatrix:projection ];
}

- (void) updateProjection
{
    ODCamera * camera = [[[[ NP applicationController ] sceneManager ] currentScene ] camera ];

    fov         = [ camera fov ];
    nearPlane   = [ camera nearPlane ];
    farPlane    = [ camera farPlane ];
    aspectRatio = [ camera aspectRatio];

    if ( connectedToCamera == YES )
    {
        fm4_m_init_with_fm4(projection, [ camera projection ]);
    }
    else
    {
        fm4_mssss_projection_matrix(projection, aspectRatio, fov, nearPlane, farPlane);
    }

}

- (void) updateView
{
    if ( connectedToCamera == YES )
    {
        ODCamera * camera = [[[[ NP applicationController ] sceneManager ] currentScene ] camera ];
        fm4_m_init_with_fm4(view, [ camera view ]);
        fv3_v_init_with_fv3(position, [ camera position ]);

        fquat_m4_to_FQuaternion_q(view, orientation);
        fquat_q_normalise(orientation);
        fquat_q_conjugate(orientation);

        id ocean = [[[[ NP applicationController ] sceneManager ] currentScene ] entityWithName:@"Ocean" ] ;
        Float basePlaneHeight = [ ocean basePlaneHeight ];

        FVector3 cameraForward;
        FVector3 cameraPosition;

        fv3_v_init_with_fv3(&cameraForward,  [ camera forward  ]);
        fv3_v_init_with_fv3(&cameraPosition, [ camera position ]);

        FRay ray;
        ray.point     = *[ camera position ];
        ray.direction = *[ camera forward  ];

        FPlane * basePlane = [ ocean basePlane ];

        FVector3 intersection;
        Int intersectionState = fplane_pr_intersect_with_ray_v(basePlane, &ray, &intersection);

        switch ( intersectionState )
        {
            // Intersection behind us, means we are looking upwards
            case -1:
            {
                break;
            }

            // No intersection, we are looking to the horizon
            case  0:
            {
                break;
            }

            // Intersection in front of us, we are looking downwards
            case  1:
            {
                break;
            }
        }
    }
    else
    {
        fm4_m_set_identity(view);

        FQuaternion q;
        fquat_q_conjugate_q(orientation, &q);

        FMatrix4 rotate;
        fquat_q_to_fmatrix4_m(&q, &rotate);

        fquat_m4_to_FQuaternion_q(&rotate, &q);

        FMatrix4 tmp;
        fm4_mm_multiply_m(view, &rotate, &tmp);

        FVector3 invpos;
        fv3_v_invert_v(position, &invpos);

        FMatrix4 trans;
        fm4_mv_translation_matrix(&trans, &invpos);

        fm4_mm_multiply_m(&tmp, &trans, view);
    }
}

- (void) update:(Float)frameTime
{
    if ( [ pitchMinusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:0.0f andPitch:-1.0f ];
    }

    if ( [ pitchPlusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:0.0f andPitch:1.0f ];
    }

    if ( [ yawMinusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:-1.0f andPitch:0.0f ];
    }

    if ( [ yawPlusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:1.0f andPitch:0.0f ];
    }

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
    if ( renderFrustum == YES && connectedToCamera == NO)
    {
        [[[ NP Core ] transformationStateManager ] resetCurrentModelMatrix ];
        [ frustum render ];
    }
}

@end
