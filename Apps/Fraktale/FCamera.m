#import "NP.h"
#import "FCamera.h"

@implementation FCamera

- (id) init
{
	return [ self initWithName:@"FCamera" ];
}

- (id) initWithName:(NSString *)newName;
{
	return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
{
	self = [ super initWithName:newName parent:newParent ];

	view = fm4_alloc_init();
	projection = fm4_alloc_init();

	orientation = fquat_alloc_init();
	position = fv3_alloc_init();

    fov         = 45.0f;
    nearPlane   = 0.1f;
    farPlane    = 1000.0f;
    aspectRatio = [[[[ NP Graphics ] viewportManager ] currentViewport ] aspectRatio ];

    yaw   = 0.0f;
    pitch = 0.0f;

    forward = fv3_alloc_init();
    V_Z(*forward) = -1.0;

    leftClickAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"LeftClick" primaryInputAction:NP_INPUT_MOUSE_BUTTON_LEFT ];
    wheelDownAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"ZoomIn"    primaryInputAction:NP_INPUT_MOUSE_WHEEL_DOWN  ];
    wheelUpAction   = [[[ NP Input ] inputActions ] addInputActionWithName:@"ZoomOut"   primaryInputAction:NP_INPUT_MOUSE_WHEEL_UP    ];

    controlAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"Control" primaryInputAction:NP_INPUT_KEYBOARD_LEFT_CONTROL ];

    forwardMovementAction  = [[[ NP Input ] inputActions ] addInputActionWithName:@"Forward"     primaryInputAction:NP_INPUT_KEYBOARD_UP    ];
    backwardMovementAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"Backward"    primaryInputAction:NP_INPUT_KEYBOARD_DOWN  ];
    strafeLeftAction       = [[[ NP Input ] inputActions ] addInputActionWithName:@"StrafeLeft"  primaryInputAction:NP_INPUT_KEYBOARD_LEFT  ];
    strafeRightAction      = [[[ NP Input ] inputActions ] addInputActionWithName:@"StrafeRight" primaryInputAction:NP_INPUT_KEYBOARD_RIGHT ];

	return self;
}

- (void) dealloc
{
	view = fm4_free(view);
	projection = fm4_free(projection);

	orientation = fquat_free(orientation);
	position = fv3_free(position);
	forward = fv3_free(forward);

    [[[ NP Input ] inputActions ] removeInputAction:leftClickAction ];
    [[[ NP Input ] inputActions ] removeInputAction:wheelDownAction ];
    [[[ NP Input ] inputActions ] removeInputAction:wheelUpAction ];
    [[[ NP Input ] inputActions ] removeInputAction:controlAction ];

    [[[ NP Input ] inputActions ] removeInputAction:forwardMovementAction ];
    [[[ NP Input ] inputActions ] removeInputAction:backwardMovementAction ];
    [[[ NP Input ] inputActions ] removeInputAction:strafeLeftAction ];
    [[[ NP Input ] inputActions ] removeInputAction:strafeRightAction ];

	[ super dealloc ];
}

- (void) reset
{
	fm4_m_set_identity(view);
	fm4_m_set_identity(projection);

	fquat_set_identity(orientation);
	fv3_v_init_with_zeros(position);
}

- (FVector3 *) position
{
	return position;
}

- (void) setPosition:(FVector3 *)newPosition
{
	*position = *newPosition;
}

- (FMatrix4 *) projection
{
    return projection;
}

- (Float) fov
{
    return fov;
}

- (void) setFov:(Float)newFov
{
	fov = newFov;
}

- (Float) nearPlane
{
    return nearPlane;
}

- (void) setNearPlane:(Float)newNearPlane
{
	nearPlane = newNearPlane;
}

- (Float) farPlane
{
    return farPlane;
}

- (void) setFarPlane:(Float)newFarPlane
{
	farPlane = newFarPlane;
}

- (Float) aspectRatio
{
    return aspectRatio;
}

- (void) setAspectRatio:(Float)newAspectRatio
{
	aspectRatio = newAspectRatio;
}

- (void) updateYaw:(Float)degrees
{
    if ( degrees != 0.0f )
    {
        yaw += degrees;

        /*if ( yaw < -360.0f )
        {
            yaw += 360.0f;
        }

        if ( yaw > 360.0f )
        {
            yaw -= 360.0f;
        }*/
    }
}

- (void) updatePitch:(Float)degrees
{
    if ( degrees != 0.0f )
    {
        pitch += degrees;

        /*if ( pitch < -360.0f )
        {
            pitch += 360.0f;
        }

        if ( pitch > 360.0f )
        {
            pitch -= 360.0f;
        }*/
    }
}

- (void) cameraRotateUsingYaw:(Float)yawDegrees andPitch:(Float)pitchDegrees
{
    [ self updateYaw:yawDegrees ];
    [ self updatePitch:pitchDegrees ];

    fquat_q_init_with_axis_and_degrees(orientation,NP_WORLDF_Y_AXIS,&yaw);
    fquat_q_rotatex(orientation,&pitch);
}

/*
- (void) moveForward:(Float)frameTime
{
    fquat_q_forward_vector_v(orientation,forward);

    V_X(*position) += (forward->x * frameTime);
    V_Y(*position) += (forward->y * frameTime);
    V_Z(*position) += (forward->z * frameTime);
}

- (void) moveBackward:(Float)frameTime
{
    fquat_q_forward_vector_v(orientation,forward);

    V_X(*position) -= (forward->x * frameTime);
    V_Y(*position) -= (forward->y * frameTime);
    V_Z(*position) -= (forward->z * frameTime);
}

- (void) moveLeft:(Float)frameTime
{
    FVector3 left;
    fquat_q_right_vector_v(orientation,&left);

    V_X(*position) -= (left.x * frameTime);
    V_Y(*position) -= (left.y * frameTime);
    V_Z(*position) -= (left.z * frameTime);
}

- (void) moveRight:(Float)frameTime
{
    FVector3 right;
    fquat_q_right_vector_v(orientation,&right);

    V_X(*position) += (right.x * frameTime);
    V_Y(*position) += (right.y * frameTime);
    V_Z(*position) += (right.z * frameTime);
}
*/

- (void) strafe:(Float)strafe
{
    FVector3 right = fquat_q_right_vector(orientation);

    V_X(*position) += (right.x * strafe);
    V_Y(*position) += (right.y * strafe);
    V_Z(*position) += (right.z * strafe);
}

- (void) updateProjection
{
    glMatrixMode(GL_PROJECTION);

    fm4_mssss_projection_matrix(projection, aspectRatio, fov, nearPlane, farPlane);

    glLoadMatrixf((Float *)(M_ELEMENTS(*projection)));
    glMatrixMode(GL_MODELVIEW);
}

- (void) updateView
{
    fm4_m_set_identity(view);

    FQuaternion q = fquat_q_conjugated(orientation);
    FMatrix4 rotate = fquat_q_to_fmatrix4(&q);
    FMatrix4 tmp = fm4_mm_multiply(view, &rotate);
    FVector3 invpos = fv3_v_inverted(position);
    FMatrix4 trans = fm4_v_translation_matrix(&invpos);

    fm4_mm_multiply_m(&tmp, &trans, view);

    glLoadMatrixf((Float *)(M_ELEMENTS(*view)));
}

- (void) update:(Float)frameTime
{
    // position update
    /*if ( [ forwardMovementAction active ] == YES )
    {
        [ self moveForward:(Float)frameTime ];
    }

    if ( [ backwardMovementAction active ] == YES )
    {
        [ self moveBackward:(Float)frameTime ];
    }

    if ( [ strafeLeftAction active ] == YES )
    {
        [ self moveLeft:(Float)frameTime ];
    }

    if ( [ strafeRightAction active ] == YES )
    {
        [ self moveRight:(Float)frameTime ];
    }*/

    // rotation update
    if ( [ leftClickAction active ] == YES )
    {
        NPMouse * mouse = [[ NP Input ] mouse ];
        Float deltaX = [ mouse deltaX ];
        Float deltaY = [ mouse deltaY ];

        if ( [ controlAction active ] == YES )
        {
            if ( deltaX != 0.0f )
            {
                [ self strafe:(deltaX/2.0f) ];
            }
        }
        else
        {
            if ( deltaX != 0.0f || deltaY != 0.0f )
            {
                [ self cameraRotateUsingYaw:-deltaX*0.3f andPitch:deltaY*0.3f ];
            }
        }
    }

    if ( [ wheelDownAction activated ] == YES )
    {
        fquat_q_forward_vector_v(orientation, forward);

        V_X(*position) += (forward->x * 2.0f);
        V_Y(*position) += (forward->y * 2.0f);
        V_Z(*position) += (forward->z * 2.0f);        

    }

    if ( [ wheelUpAction activated ] == YES )
    {
        fquat_q_forward_vector_v(orientation, forward);

        V_X(*position) -= (forward->x * 2.0f);
        V_Y(*position) -= (forward->y * 2.0f);
        V_Z(*position) -= (forward->z * 2.0f);
    }

    // update matrices
	[ self updateProjection ];
	[ self updateView ];
}

- (void) render
{
    NPTransformationState * trafo = [[ NP Core ] transformationState ];
    [ trafo setViewMatrix:view ];
    [ trafo setProjectionMatrix:projection ];
}

@end
