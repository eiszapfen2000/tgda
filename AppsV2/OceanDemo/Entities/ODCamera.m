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
        fquat_q_forward_vector_v(&orientation, &forward);
        quat_q_forward_vector_v(&orientationD, &forwardD);

        position.x += (forward.x * 2.0f);
        position.y += (forward.y * 2.0f);
        position.z += (forward.z * 2.0f);

        positionD.x += (forwardD.x * 2.0);
        positionD.y += (forwardD.y * 2.0);
        positionD.z += (forwardD.z * 2.0);
    }

    if ( [ wheelDownAction activated ] == YES )
    {
        fquat_q_forward_vector_v(&orientation, &forward);
        quat_q_forward_vector_v(&orientationD, &forwardD);

        position.x -= (forward.x * 2.0f);
        position.y -= (forward.y * 2.0f);
        position.z -= (forward.z * 2.0f);

        positionD.x -= (forwardD.x * 2.0);
        positionD.y -= (forwardD.y * 2.0);
        positionD.z -= (forwardD.z * 2.0);
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

    fm4_m_set_identity(&view);
    fm4_m_set_identity(&projection);
    fm4_m_set_identity(&inverseViewProjection);
    fquat_set_identity(&orientation);
    fv3_v_init_with_zeros(&position);

    m4_m_set_identity(&viewD);
    m4_m_set_identity(&projectionD);
    m4_m_set_identity(&inverseViewProjectionD);
    quat_set_identity(&orientationD);
    v3_v_init_with_zeros(&positionD);

    fov         = 45.0f;
    nearPlane   = 0.1f;
    farPlane    = 150.0f;
    aspectRatio = 1.0f;

    yaw   = 0.0f;
    pitch = 0.0f;

    fv3_v_init_with_zeros(&forward);
    v3_v_init_with_zeros(&forwardD);
    forward.z  = -1.0f;
    forwardD.z = -1.0;

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

- (FQuaternion) orientation
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

- (FMatrix4 *) view
{
    return &view;
}

- (FMatrix4 *) projection
{
    return &projection;
}

- (FMatrix4 *) inverseViewProjection
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

- (void) setPosition:(const FVector3)newPosition
{
	position = newPosition;
}

- (void) setOrientation:(const FQuaternion)newOrientation
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
    fquat_q_forward_vector_v(&orientation, &forward);
    quat_q_forward_vector_v(&orientationD, &forwardD);

    position.x += (forward.x * frameTime);
    position.y += (forward.y * frameTime);
    position.z += (forward.z * frameTime);

    positionD.x += (forwardD.x * frameTime);
    positionD.y += (forwardD.y * frameTime);
    positionD.z += (forwardD.z * frameTime);
}

- (void) moveBackward:(const float)frameTime
{
    fquat_q_forward_vector_v(&orientation, &forward);
    quat_q_forward_vector_v(&orientationD, &forwardD);

    position.x -= (forward.x * frameTime);
    position.y -= (forward.y * frameTime);
    position.z -= (forward.z * frameTime);

    positionD.x -= (forwardD.x * frameTime);
    positionD.y -= (forwardD.y * frameTime);
    positionD.z -= (forwardD.z * frameTime);
}

- (void) moveLeft:(const float)frameTime
{
    FVector3 right;
    Vector3  rightD;

    fquat_q_right_vector_v(&orientation, &right);
    quat_q_right_vector_v(&orientationD, &rightD);

    position.x -= (right.x * frameTime);
    position.y -= (right.y * frameTime);
    position.z -= (right.z * frameTime);

    positionD.x -= (rightD.x * frameTime);
    positionD.y -= (rightD.y * frameTime);
    positionD.z -= (rightD.z * frameTime);
}

- (void) moveRight:(const float)frameTime
{
    FVector3 right;
    Vector3  rightD;
    fquat_q_right_vector_v(&orientation, &right);
    quat_q_right_vector_v(&orientationD, &rightD);

    position.x += (right.x * frameTime);
    position.y += (right.y * frameTime);
    position.z += (right.z * frameTime);

    positionD.x += (rightD.x * frameTime);
    positionD.y += (rightD.y * frameTime);
    positionD.z += (rightD.z * frameTime);
}

- (void) updateProjection
{
    aspectRatio = [[[ NP Graphics ] viewport ] aspectRatio ];
    fm4_mssss_projection_matrix(&projection, aspectRatio, fov, nearPlane, farPlane);
    m4_mssss_projection_matrix(&projectionD, aspectRatio, fov, nearPlane, farPlane);
}

- (void) updateView
{
    fm4_m_set_identity(&view);
    m4_m_set_identity(&viewD);

    if ( inputLocked == NO )
    {
        fquat_q_init_with_axis_and_degrees(&orientation, NP_WORLDF_Y_AXIS, yaw);
        fquat_q_rotatex(&orientation, pitch);

        quat_q_init_with_axis_and_degrees(&orientationD, NP_WORLD_Y_AXIS, yaw);
        quat_q_rotatex(&orientationD, pitch);
    }

    fquat_q_forward_vector_v(&orientation, &forward);
    FQuaternion q = fquat_q_conjugated(&orientation);
    FVector3 invpos = fv3_v_inverted(&position);
    FMatrix4 rotate = fquat_q_to_fmatrix4(&q);
    FMatrix4 translate = fm4_v_translation_matrix(&invpos);
    fm4_mm_multiply_m(&rotate, &translate, &view);

    quat_q_forward_vector_v(&orientationD, &forwardD);
    Quaternion qD = quat_q_conjugated(&orientationD);
    Vector3 invposD = v3_v_inverted(&positionD);
    Matrix4 rotateD = quat_q_to_matrix4(&qD);
    Matrix4 translateD = m4_v_translation_matrix(&invposD);
    m4_mm_multiply_m(&rotateD, &translateD, &viewD);
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

    FMatrix4 viewProjection;
    fm4_mm_multiply_m(&projection, &view, &viewProjection);
    fm4_m_inverse_m(&viewProjection, &inverseViewProjection);

    Matrix4 viewProjectionD;
    m4_mm_multiply_m(&projectionD, &viewD, &viewProjectionD);
    m4_m_inverse_m(&viewProjectionD, &inverseViewProjectionD);

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
    [ trafo setViewMatrix:&viewD ];
//    [ trafo setFProjectionMatrix:&projection ];
    [ trafo setProjectionMatrix:&projectionD ];
}

@end
