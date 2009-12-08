#import "NP.h"
#import "ODCamera.h"

@implementation ODCamera

- (id) init
{
	return [ self initWithName:@"ODCamera" ];
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
    farPlane    = 50.0f;
    aspectRatio = [[[[ NP Graphics ] viewportManager ] currentViewport ] aspectRatio ];

    yaw   = 0.0f;
    pitch = 0.0f;

    forward = fv3_alloc_init();
    V_Z(*forward) = -1.0;

    leftClickAction        = [[[ NP Input ] inputActions ] addInputActionWithName:@"LeftClick"   primaryInputAction:NP_INPUT_MOUSE_BUTTON_LEFT ];
    forwardMovementAction  = [[[ NP Input ] inputActions ] addInputActionWithName:@"Forward"     primaryInputAction:NP_INPUT_KEYBOARD_UP       ];
    backwardMovementAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"Backward"    primaryInputAction:NP_INPUT_KEYBOARD_DOWN     ];
    strafeLeftAction       = [[[ NP Input ] inputActions ] addInputActionWithName:@"StrafeLeft"  primaryInputAction:NP_INPUT_KEYBOARD_LEFT     ];
    strafeRightAction      = [[[ NP Input ] inputActions ] addInputActionWithName:@"StrafeRight" primaryInputAction:NP_INPUT_KEYBOARD_RIGHT    ];

    wheelDownAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"ZoomIn"    primaryInputAction:NP_INPUT_MOUSE_WHEEL_DOWN ];
    wheelUpAction   = [[[ NP Input ] inputActions ] addInputActionWithName:@"ZoomOut"   primaryInputAction:NP_INPUT_MOUSE_WHEEL_UP   ];

	return self;
}

- (void) dealloc
{
	view = fm4_free(view);
	projection = fm4_free(projection);

	orientation = fquat_free(orientation);
	position = fv3_free(position);

    [[[ NP Input ] inputActions ] removeInputAction:leftClickAction ];
    [[[ NP Input ] inputActions ] removeInputAction:forwardMovementAction ];
    [[[ NP Input ] inputActions ] removeInputAction:backwardMovementAction ];
    [[[ NP Input ] inputActions ] removeInputAction:strafeLeftAction ];
    [[[ NP Input ] inputActions ] removeInputAction:strafeRightAction ];

	[ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
{
    NSString * cameraName      = [ config objectForKey:@"Name" ];
    NSArray  * positionStrings = [ config objectForKey:@"Position" ];

    if ( cameraName == nil || positionStrings == nil )
    {
        NPLOG_ERROR(@"%@: Dictionary incomplete", name);
        return NO;
    }

    [ self setName:cameraName ];

    position->x = [[ positionStrings objectAtIndex:0 ] floatValue ];
    position->y = [[ positionStrings objectAtIndex:1 ] floatValue ];
    position->z = [[ positionStrings objectAtIndex:2 ] floatValue ];

    return YES;
}

- (void) reset
{
	fm4_m_set_identity(view);
	fm4_m_set_identity(projection);

	fquat_set_identity(orientation);
	fv3_v_init_with_zeros(position);
}

- (Float) fov
{
    return fov;
}

- (Float) aspectRatio
{
    return aspectRatio;
}

- (Float) nearPlane
{
    return nearPlane;
}

- (Float) farPlane
{
    return farPlane;
}

- (FVector3 *) forward
{
    return forward;
}

- (FVector3 *) position
{
	return position;
}

- (FMatrix4 *) view
{
    return view;
}

- (FMatrix4 *) projection
{
    return projection;
}

- (void) setFov:(Float)newFov
{
	fov = newFov;
}

- (void) setAspectRatio:(Float)newAspectRatio
{
	aspectRatio = newAspectRatio;
}

- (void) setNearPlane:(Float)newNearPlane
{
	nearPlane = newNearPlane;
}

- (void) setFarPlane:(Float)newFarPlane
{
	farPlane = newFarPlane;
}

- (void) setPosition:(FVector3 *)newPosition
{
	*position = *newPosition;
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

    fquat_q_init_with_axis_and_degrees(orientation, NP_WORLDF_Y_AXIS, &yaw);
    fquat_q_rotatex(orientation, &pitch);
}

- (void) moveForward:(Float)frameTime
{
    fquat_q_forward_vector_v(orientation,forward);

    V_X(*position) += (forward->x * frameTime);
    V_Y(*position) += (forward->y * frameTime);
    V_Z(*position) += (forward->z * frameTime);
}

- (void) moveBackward:(Float)frameTime
{
    fquat_q_forward_vector_v(orientation, forward);

    V_X(*position) -= (forward->x * frameTime);
    V_Y(*position) -= (forward->y * frameTime);
    V_Z(*position) -= (forward->z * frameTime);
}

- (void) moveLeft:(Float)frameTime
{
    FVector3 left;
    fquat_q_right_vector_v(orientation, &left);

    V_X(*position) -= (left.x * frameTime);
    V_Y(*position) -= (left.y * frameTime);
    V_Z(*position) -= (left.z * frameTime);
}

- (void) moveRight:(Float)frameTime
{
    FVector3 right;
    fquat_q_right_vector_v(orientation, &right);

    V_X(*position) += (right.x * frameTime);
    V_Y(*position) += (right.y * frameTime);
    V_Z(*position) += (right.z * frameTime);
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

    fquat_q_forward_vector_v(orientation,forward);

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

    glLoadMatrixf((Float *)(M_ELEMENTS(*view)));
}

- (void) update:(Float)frameTime
{
    // position update
    if ( [ forwardMovementAction active ] == YES )
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
    }

    if ( [ leftClickAction active ] == YES )
    {
        // rotation update
        id mouse = [[ NP Input ] mouse ];
        Float deltaX = [ mouse deltaX ];
        Float deltaY = [ mouse deltaY ];

        if ( deltaX != 0.0f || deltaY != 0.0f )
        {
            [ self cameraRotateUsingYaw:-deltaX*0.3f andPitch:deltaY*0.3f ];
        }
    }

    if ( [ wheelDownAction activated ] == YES )
    {
        fquat_q_forward_vector_v(orientation,forward);

        V_X(*position) += (forward->x * 2.0f);
        V_Y(*position) += (forward->y * 2.0f);
        V_Z(*position) += (forward->z * 2.0f);        

    }

    if ( [ wheelUpAction activated ] == YES )
    {
        fquat_q_forward_vector_v(orientation,forward);

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
    NPTransformationState * trafo = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
    [ trafo setViewMatrix:view ];
    [ trafo setProjectionMatrix:projection ];
}

@end
