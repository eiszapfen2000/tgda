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

@interface ODCamera (Private)

- (void) processInput:(const float)frameTime;

@end

@implementation ODCamera (Private)

- (void) processInput:(const float)frameTime
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
        [ self moveLeft:frameTime * 10.0f ];
    }

    if ( [ strafeRightAction active ] == YES )
    {
        [ self moveRight:frameTime * 10.0f ];
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
        quat_q_forward_vector_v(&orientation, &forward);

        position.x += (forward.x * 2.0);
        position.y += (forward.y * 2.0);
        position.z += (forward.z * 2.0);
    }

    if ( [ wheelDownAction activated ] == YES )
    {
        quat_q_forward_vector_v(&orientation, &forward);

        position.x -= (forward.x * 2.0);
        position.y -= (forward.y * 2.0);
        position.z -= (forward.z * 2.0);
    }
}

@end

@implementation ODCamera

- (id) init
{
	return [ self initWithName:@"ODCamera" ];
}

- (id) initWithName:(NSString *)newName;
{
	self = [ super initWithName:newName ];

    m4_m_set_identity(&view);
    m4_m_set_identity(&projection);
    m4_m_set_identity(&inverseViewProjection);
    quat_set_identity(&orientation);
    v3_v_init_with_zeros(&position);
    v3_v_init_with_zeros(&forward);
    forward.z  = -1.0f;

    fov         = 45.0f;
    nearPlane   = 0.1f;
    farPlane    = 150.0f;
    aspectRatio = 1.0f;

    yaw   = 0.0f;
    pitch = 0.0f;

    inputLocked = NO;

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

- (Vector3) forward
{
    return forward;
}

- (Vector3) position
{
	return position;
}

- (Quaternion) orientation
{
    return orientation;
}

- (float) yaw
{
    return yaw;
}

- (float) pitch
{
    return pitch;
}

- (Matrix4 *) view
{
    return &view;
}

- (Matrix4 *) projection
{
    return &projection;
}

- (Matrix4 *) inverseViewProjection
{
    return &inverseViewProjection;
}

- (BOOL) inputLocked
{
    return inputLocked;
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

- (void) setPosition:(const Vector3)newPosition
{
	position = newPosition;
}

- (void) setOrientation:(const Quaternion)newOrientation
{
    orientation = newOrientation;
}

- (void) setYaw:(const float)newYaw
{
    yaw = newYaw;
}

- (void) setPitch:(const float)newPitch
{
    pitch = newPitch;
}

- (void) lockInput
{
    inputLocked = YES;
}

- (void) unlockInput
{
    inputLocked = NO;
}

- (void) updateYaw:(float)degrees
{
    if ( degrees != 0.0f )
    {
        yaw += degrees;

        if ( yaw < 0.0f )
        {
            yaw = 360.0f + yaw;
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

        if ( pitch < 0.0f )
        {
            pitch = 360.0f + pitch;
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
}

- (void) moveForward:(const float)frameTime
{
    quat_q_forward_vector_v(&orientation, &forward);
    
    position.x += (forward.x * frameTime);
    position.y += (forward.y * frameTime);
    position.z += (forward.z * frameTime);
}

- (void) moveBackward:(const float)frameTime
{
    quat_q_forward_vector_v(&orientation, &forward);
    
    position.x -= (forward.x * frameTime);
    position.y -= (forward.y * frameTime);
    position.z -= (forward.z * frameTime);
}

- (void) moveLeft:(const float)frameTime
{
    Vector3 right;
    quat_q_right_vector_v(&orientation, &right);
    
    position.x -= (right.x * frameTime);
    position.y -= (right.y * frameTime);
    position.z -= (right.z * frameTime);
}

- (void) moveRight:(const float)frameTime
{
    Vector3 right;
    quat_q_right_vector_v(&orientation, &right);
    
    position.x += (right.x * frameTime);
    position.y += (right.y * frameTime);
    position.z += (right.z * frameTime);
}

- (void) updateProjection
{
    aspectRatio = [[[ NP Graphics ] viewport ] aspectRatio ];
    m4_mssss_projection_matrix(&projection, aspectRatio, fov, nearPlane, farPlane);
}

- (void) updateView
{
    m4_m_set_identity(&view);
    
    if ( inputLocked == NO )
    {
        quat_q_init_with_axis_and_degrees(&orientation, NP_WORLD_Y_AXIS, yaw);
        quat_q_rotatex(&orientation, pitch);
    }

    quat_q_forward_vector_v(&orientation, &forward);
    Quaternion q = quat_q_conjugated(&orientation);
    Vector3 invpos = v3_v_inverted(&position);
    Matrix4 rotate = quat_q_to_matrix4(&q);
    Matrix4 translate = m4_v_translation_matrix(&invpos);
    m4_mm_multiply_m(&rotate, &translate, &view);
}

- (void) update:(const double)frameTime
{
    if ( inputLocked == NO )
    {
        [ self processInput:frameTime ];
    }

    // update matrices
    [ self updateProjection ];
    [ self updateView ];

    Matrix4 viewProjection;
    m4_mm_multiply_m(&projection, &view, &viewProjection);
    m4_m_inverse_m(&viewProjection, &inverseViewProjection);

    /*
    const char * s1 = fm4_m_to_string(&projection);
    const char * s2 = m4_m_to_string(&projectionD);

    NSLog(@"\n%s\n\n%s\n", s1, s2);

    SAFE_FREE(s1);
    SAFE_FREE(s2);
    */
}

- (void) render
{
    NPTransformationState * trafo = [[ NP Core ] transformationState ];
//    [ trafo setFViewMatrix:&view ];
    [ trafo setViewMatrix:&view ];
//    [ trafo setFProjectionMatrix:&projection ];
    [ trafo setProjectionMatrix:&projection ];
}

@end
