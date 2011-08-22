#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "GL/glew.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPKeyboard.h"
#import "Input/NPMouse.h"
#import "NP.h"
#import "ODProjector.h"
#import "ODCamera.h"

@implementation ODCamera

- (id) init
{
	return [ self initWithName:@"ODCamera" ];
}

- (id) initWithName:(NSString *)newName;
{
	self = [ super initWithName:newName ];

    fm4_m_set_identity(&view);
    fm4_m_set_identity(&projection);
    fquat_set_identity(&orientation);
    fv3_v_init_with_zeros(&position);

    fov         = 45.0f;
    nearPlane   = 0.1f;
    farPlane    = 50.0f;
    //aspectRatio = [[[ NP Graphics ] viewport ] aspectRatio ];
    aspectRatio = 1.0f;

    yaw   = 0.0f;
    pitch = 0.0f;

    fv3_v_init_with_zeros(&forward);
    forward.z = -1.0f;

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
    [[[ NP Input ] inputActions ] removeInputAction:wheelUpAction ];
    [[[ NP Input ] inputActions ] removeInputAction:wheelDownAction ];
    [[[ NP Input ] inputActions ] removeInputAction:strafeRightAction ];
    [[[ NP Input ] inputActions ] removeInputAction:strafeLeftAction ];
    [[[ NP Input ] inputActions ] removeInputAction:backwardMovementAction ];
    [[[ NP Input ] inputActions ] removeInputAction:forwardMovementAction ];
    [[[ NP Input ] inputActions ] removeInputAction:leftClickAction ];

	[ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    NSAssert(config != nil, @"");

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
	fm4_m_set_identity(&view);
	fm4_m_set_identity(&projection);
	fquat_set_identity(&orientation);
	fv3_v_init_with_zeros(&position);
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

- (FVector3) forward
{
    return forward;
}

- (FVector3) position
{
	return position;
}

- (FMatrix4 *) view
{
    return &view;
}

- (FMatrix4 *) projection
{
    return &projection;
}

- (void) setFov:(const float)newFov
{
	fov = newFov;
}

- (void) setAspectRatio:(const float)newAspectRatio
{
	aspectRatio = newAspectRatio;
}

- (void) setNearPlane:(const float)newNearPlane
{
	nearPlane = newNearPlane;
}

- (void) setFarPlane:(const float)newFarPlane
{
	farPlane = newFarPlane;
}

- (void) setPosition:(const FVector3)newPosition
{
	position = newPosition;
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

- (void) cameraRotateUsingYaw:(const float)yawDegrees andPitch:(const float)pitchDegrees
{
    [ self updateYaw:yawDegrees ];
    [ self updatePitch:pitchDegrees ];

    fquat_q_init_with_axis_and_degrees(&orientation, NP_WORLDF_Y_AXIS, yaw);
    fquat_q_rotatex(&orientation, pitch);
}

- (void) moveForward:(const float)frameTime
{
    fquat_q_forward_vector_v(&orientation, &forward);

    position.x += (forward.x * frameTime);
    position.y += (forward.y * frameTime);
    position.z += (forward.z * frameTime);
}

- (void) moveBackward:(const float)frameTime
{
    fquat_q_forward_vector_v(&orientation, &forward);

    position.x -= (forward.x * frameTime);
    position.y -= (forward.y * frameTime);
    position.z -= (forward.z * frameTime);
}

- (void) moveLeft:(const float)frameTime
{
    FVector3 right;
    fquat_q_right_vector_v(&orientation, &right);

    position.x -= (right.x * frameTime);
    position.y -= (right.y * frameTime);
    position.z -= (right.z * frameTime);
}

- (void) moveRight:(const float)frameTime
{
    FVector3 right;
    fquat_q_right_vector_v(&orientation, &right);

    position.x += (right.x * frameTime);
    position.y += (right.y * frameTime);
    position.z += (right.z * frameTime);
}

- (void) updateProjection
{
    glMatrixMode(GL_PROJECTION);

    fm4_mssss_projection_matrix(&projection, aspectRatio, fov, nearPlane, farPlane);

    glLoadMatrixf((float *)(M_ELEMENTS(projection)));
    glMatrixMode(GL_MODELVIEW);
}

- (void) updateView
{
    aspectRatio = [[[ NP Graphics ] viewport ] aspectRatio ];

    fm4_m_set_identity(&view);

    fquat_q_forward_vector_v(&orientation, &forward);
    FQuaternion q = fquat_q_conjugated(&orientation);
    FVector3 invpos = fv3_v_inverted(&position);
    FMatrix4 rotate = fquat_q_to_fmatrix4(&q);
    FMatrix4 translate = fm4_v_translation_matrix(&invpos);
    fm4_mm_multiply_m(&rotate, &translate, &view);

    glLoadMatrixf((float *)(M_ELEMENTS(view)));
}

- (void) update:(const float)frameTime
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
        [ self moveLeft:frameTime * 3.0f ];
    }

    if ( [ strafeRightAction active ] == YES )
    {
        [ self moveRight:frameTime * 3.0f ];
    }

    if ( [ leftClickAction active ] == YES )
    {
        // rotation update
        NPMouse * mouse = [[ NP Input ] mouse ];
        int32_t deltaX = [ mouse deltaX ];
        int32_t deltaY = [ mouse deltaY ];

        if ( deltaX != 0 || deltaY != 0 )
        {
            [ self cameraRotateUsingYaw:-deltaX*0.3f andPitch:-deltaY*0.3f ];
        }
    }

    if ( [ wheelUpAction activated ] == YES )
    {
        fquat_q_forward_vector_v(&orientation, &forward);

        position.x += (forward.x * 2.0f);
        position.y += (forward.y * 2.0f);
        position.z += (forward.z * 2.0f);
    }

    if ( [ wheelDownAction activated ] == YES )
    {
        fquat_q_forward_vector_v(&orientation, &forward);

        position.x -= (forward.x * 2.0f);
        position.y -= (forward.y * 2.0f);
        position.z -= (forward.z * 2.0f);
    }

    // update matrices
	[ self updateProjection ];
	[ self updateView ];
}

- (void) render
{
    NPTransformationState * trafo = [[ NP Core ] transformationState ];
    [ trafo setViewMatrix:&view ];
    [ trafo setProjectionMatrix:&projection ];
}

@end
