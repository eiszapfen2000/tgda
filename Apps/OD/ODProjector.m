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

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
	self = [ super initWithName:newName parent:newParent ];

    model = fm4_alloc_init();
	view = fm4_alloc_init();
    projection = fm4_alloc_init();
    modelViewProjection = fm4_alloc_init();
    inverseModelViewProjection = fm4_alloc_init();

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

    pitchMinusAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"PitchMinus" primaryInputAction:NP_INPUT_KEYBOARD_S ];
    pitchPlusAction  = [[[ NP Input ] inputActions ] addInputActionWithName:@"PitchPlus"  primaryInputAction:NP_INPUT_KEYBOARD_W ];
    yawMinusAction   = [[[ NP Input ] inputActions ] addInputActionWithName:@"YawMinus"   primaryInputAction:NP_INPUT_KEYBOARD_A ];
    yawPlusAction    = [[[ NP Input ] inputActions ] addInputActionWithName:@"YawPlus"    primaryInputAction:NP_INPUT_KEYBOARD_D ];


	return self;
}

- (void) dealloc
{
    model = fm4_free(model);
	view = fm4_free(view);
	modelViewProjection = fm4_free(modelViewProjection);
    inverseModelViewProjection = fm4_free(inverseModelViewProjection);

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
	fm4_m_set_identity(model);
	fm4_m_set_identity(view);
	fm4_m_set_identity(projection);
	fm4_m_set_identity(modelViewProjection);
	fm4_m_set_identity(inverseModelViewProjection);

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

- (FMatrix4 *) model
{
    return model;
}

- (FMatrix4 *) view
{
    return view;
}

- (FMatrix4 *) projection
{
    return projection;
}

- (FMatrix4 *) inverseModelViewProjection
{
    return inverseModelViewProjection;
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

- (void) activate
{
    NPTransformationState * trafo = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
    [ trafo setViewMatrix:view ];
    [ trafo setProjectionMatrix:projection ];
}

- (void) updateProjection
{
    ODCamera * camera = [ (ODScene *)parent camera ];

    /*if ( GSObjCFindVariable((id)camera,"projection",NULL,NULL,NULL) == YES )
    {
        NSLog(@"BRAK");
    }*/

    fov         = [ camera fov ];
    nearPlane   = [ camera nearPlane ];
    farPlane    = [ camera farPlane ];
    aspectRatio = [ camera aspectRatio];

    aspectRatio = 1.0f;

    fm4_mssss_projection_matrix(projection, aspectRatio, fov, nearPlane, farPlane);
    //fm4_m_init_with_fm4(projection,[ camera projection ]);
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

- (void) updateModel
{
    model->elements[3][0] = position->x;
    model->elements[3][1] = position->y;
    model->elements[3][2] = position->z;
}

- (void) update
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
    //[ self updateModel ];

    [ frustum updateWithPosition:position
                     orientation:orientation
                             fov:fov
                       nearPlane:nearPlane
                        farPlane:farPlane
                     aspectRatio:aspectRatio ];

    FMatrix4 modelView;
    fm4_mm_multiply_m(view, model, &modelView);
    fm4_mm_multiply_m(projection, &modelView, modelViewProjection);
    fm4_m_inverse_m(modelViewProjection, inverseModelViewProjection);
}

- (void) render
{
    if ( renderFrustum == YES )
    {
        //glColor3f(1.0f,0.0f,0.0f);
        [ frustum render ];
    }
}

@end
