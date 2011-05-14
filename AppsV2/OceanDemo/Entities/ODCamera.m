#import <Foundation/NSDictionary.h>
#import "GL/glew.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPKeyboard.h"
#import "Input/NPMouse.h"
#import "NP.h"
#import "ODCamera.h"

@implementation ODCamera

- (id) init
{
	return [ self initWithName:@"ODCamera" ];
}

- (id) initWithName:(NSString *)newName;
{
	self = [ super initWithName:newName ];

	view = fm4_alloc_init();
	projection = fm4_alloc_init();

	orientation = fquat_alloc_init();
	position = fv3_alloc_init();

    fov         = 45.0f;
    nearPlane   = 0.1f;
    farPlane    = 50.0f;
    aspectRatio = [[[ NP Graphics ] viewport ] aspectRatio ];

    yaw   = 0.0f;
    pitch = 0.0f;

    forward = fv3_alloc_init();
    V_Z(*forward) = -1.0;

    leftClickAction        = [[[ NP Input ] inputActions ] addInputActionWithName:@"LeftClick"   inputEvent:NpMouseButtonLeft ];
    forwardMovementAction  = [[[ NP Input ] inputActions ] addInputActionWithName:@"Forward"     inputEvent:NpKeyboardUp      ];
    backwardMovementAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"Backward"    inputEvent:NpKeyboardDown    ];
    strafeLeftAction       = [[[ NP Input ] inputActions ] addInputActionWithName:@"StrafeLeft"  inputEvent:NpKeyboardLeft    ];
    strafeRightAction      = [[[ NP Input ] inputActions ] addInputActionWithName:@"StrafeRight" inputEvent:NpKeyboardRight   ];

    wheelDownAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"ZoomOut" inputEvent:NpMouseWheelDown ];
    wheelUpAction   = [[[ NP Input ] inputActions ] addInputActionWithName:@"ZoomIn"  inputEvent:NpMouseWheelUp   ];

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
    /*
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
    */

    return YES;
}

- (void) reset
{
	fm4_m_set_identity(view);
	fm4_m_set_identity(projection);

	fquat_set_identity(orientation);
	fv3_v_init_with_zeros(position);
}

- (float) fov
{
    return fov;
}

- (float) aspectRatio
{
    return aspectRatio;
}

- (float) nearPlane
{
    return nearPlane;
}

- (float) farPlane
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

- (void) setFov:(float)newFov
{
	fov = newFov;
}

- (void) setAspectRatio:(float)newAspectRatio
{
	aspectRatio = newAspectRatio;
}

- (void) setNearPlane:(float)newNearPlane
{
	nearPlane = newNearPlane;
}

- (void) setFarPlane:(float)newFarPlane
{
	farPlane = newFarPlane;
}

- (void) setPosition:(FVector3 *)newPosition
{
	*position = *newPosition;
}


- (void) updateYaw:(float)degrees
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

- (void) updatePitch:(float)degrees
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

- (void) cameraRotateUsingYaw:(float)yawDegrees andPitch:(float)pitchDegrees
{
    [ self updateYaw:yawDegrees ];
    [ self updatePitch:pitchDegrees ];

    fquat_q_init_with_axis_and_degrees(orientation, NP_WORLDF_Y_AXIS, yaw);
    fquat_q_rotatex(orientation, pitch);
}

- (void) moveForward:(float)frameTime
{
    fquat_q_forward_vector_v(orientation,forward);

    V_X(*position) += (forward->x * frameTime);
    V_Y(*position) += (forward->y * frameTime);
    V_Z(*position) += (forward->z * frameTime);
}

- (void) moveBackward:(float)frameTime
{
    fquat_q_forward_vector_v(orientation, forward);

    V_X(*position) -= (forward->x * frameTime);
    V_Y(*position) -= (forward->y * frameTime);
    V_Z(*position) -= (forward->z * frameTime);
}

- (void) moveLeft:(float)frameTime
{
    FVector3 left;
    fquat_q_right_vector_v(orientation, &left);

    V_X(*position) -= (left.x * frameTime);
    V_Y(*position) -= (left.y * frameTime);
    V_Z(*position) -= (left.z * frameTime);
}

- (void) moveRight:(float)frameTime
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

    glLoadMatrixf((float *)(M_ELEMENTS(*projection)));
    glMatrixMode(GL_MODELVIEW);
}

- (void) updateView
{
    fm4_m_set_identity(view);

    fquat_q_forward_vector_v(orientation,forward);

    FQuaternion q = fquat_q_conjugated(orientation);
    FMatrix4 rotate = fquat_q_to_fmatrix4(&q);
    FMatrix4 tmp = fm4_mm_multiply(view, &rotate);
    FVector3 invpos = fv3_v_inverted(position);
    FMatrix4 trans = fm4_v_translation_matrix(&invpos);
    fm4_mm_multiply_m(&tmp, &trans, view);

    glLoadMatrixf((float *)(M_ELEMENTS(*view)));
}

- (void) update:(float)frameTime
{
    // position update
    if ( [ forwardMovementAction active ] == YES )
    {
        [ self moveForward:frameTime ];
    }

    if ( [ backwardMovementAction active ] == YES )
    {
        [ self moveBackward:frameTime ];
    }

    if ( [ strafeLeftAction active ] == YES )
    {
        [ self moveLeft:frameTime*10.0f ];
    }

    if ( [ strafeRightAction active ] == YES )
    {
        [ self moveRight:frameTime*10.0f ];
    }

    if ( [ leftClickAction active ] == YES )
    {
        // rotation update
        NPMouse * mouse = [[ NP Input ] mouse ];
        float deltaX = [ mouse deltaX ];
        float deltaY = [ mouse deltaY ];

        if ( deltaX != 0.0f || deltaY != 0.0f )
        {
            [ self cameraRotateUsingYaw:-deltaX*0.3f andPitch:-deltaY*0.3f ];
        }
    }

    if ( [ wheelUpAction activated ] == YES )
    {
        fquat_q_forward_vector_v(orientation,forward);

        V_X(*position) += (forward->x * 2.0f);
        V_Y(*position) += (forward->y * 2.0f);
        V_Z(*position) += (forward->z * 2.0f);        
    }

    if ( [ wheelDownAction activated ] == YES )
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
    NPTransformationState * trafo = [[ NP Core ] transformationState ];
    [ trafo setViewMatrix:view ];
    [ trafo setProjectionMatrix:projection ];
}

@end
