#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPKeyboard.h"
#import "Input/NPMouse.h"
#import "NP.h"
#import "ODCamera.h"
#import "ODFrustum.h"
#import "ODProjector.h"

@interface ODProjector (Private)

- (void) cameraRotateUsingYaw:(const double)yawDegrees andPitch:(const double)pitchDegrees;
- (void) moveForward;
- (void) moveBackward;

- (void) updateYaw:(double)degrees;
- (void) updatePitch:(double)degrees;
- (void) updateProjection;
- (void) updateView;

@end

@implementation ODProjector (Private)

- (void) cameraRotateUsingYaw:(const double)yawDegrees andPitch:(const double)pitchDegrees
{
    [ self updateYaw:yawDegrees ];
    [ self updatePitch:pitchDegrees ];

    quat_q_init_with_axis_and_degrees(&orientation, NP_WORLD_Y_AXIS, yaw);
    quat_q_rotatex(&orientation, pitch);
}

- (void) moveForward
{
    quat_q_forward_vector_v(&orientation, &forward);

    position.x += forward.x;
    position.y += forward.y;
    position.z += forward.z;
}

- (void) moveBackward
{
    quat_q_forward_vector_v(&orientation, &forward);

    position.x -= forward.x;
    position.y -= forward.y;
    position.z -= forward.z;
}

- (void) updateYaw:(double)degrees
{
    if ( degrees != 0.0 )
    {
        yaw += degrees;

        if ( yaw < 0.0 )
        {
            yaw += 360.0;
        }

        if ( yaw > 360.0 )
        {
            yaw -= 360.0;
        }
    }
}

- (void) updatePitch:(double)degrees
{
    if ( degrees != 0.0 )
    {
        pitch += degrees;

        if ( pitch < 0.0 )
        {
            pitch += 360.0;
        }

        if ( pitch > 360.0 )
        {
            pitch -= 360.0;
        }
    }
}

- (void) updateProjection
{
    /*
    if ( connectedToCamera == YES )
    {
        //enlarge horizontal field of view
        float horizontalFOV = [ camera fov ] * [ camera aspectRatio ] * 1.2f;

        // Set vertical field of view to 90°
        fov = 90.0f;

        // Recalculate aspectRatio
        aspectRatio = horizontalFOV / fov;
    }
    else
    {
    */
        aspectRatio = [ camera aspectRatio ];
        fov = [ camera fov ];
    //}

    fov = 90.0 - 0.00001;

    nearPlane = [ camera nearPlane ];
    farPlane  = [ camera farPlane  ];

    m4_mssss_projection_matrix(&projection, aspectRatio, fov, nearPlane, farPlane);
}

- (void) updateView
{
    float localPitch = pitch;
    float localYaw = yaw;

    if ( connectedToCamera == YES )
    {
        position   = [ camera position ];
        localPitch = [ camera pitch ];
        localYaw   = [ camera yaw ];
    }

    if ( localPitch >= 0.0 && localPitch <= 180.0 )
    {
        if ( localPitch <= 90.0 )
        {
            localPitch = 315.0;
        }
        else
        {
            localPitch = 225.0;
        }
    }
    else
    {
        if ( localPitch < 225.0 )
        {
            localPitch = 225.0;
        }

        if ( localPitch > 315.0 )
        {
            localPitch = 315.0;
        }
    }

    m4_m_set_identity(&view);
    quat_q_init_with_axis_and_degrees(&orientation, NP_WORLD_Y_AXIS, localYaw);
    quat_q_rotatex(&orientation, localPitch);
    Quaternion q = quat_q_conjugated(&orientation);
    Vector3 invpos = v3_v_inverted(&position);
    Matrix4 rotate = quat_q_to_matrix4(&q);
    Matrix4 translate = m4_v_translation_matrix(&invpos);
    m4_mm_multiply_m(&rotate, &translate, &view);

    /*
    if ( connectedToCamera == YES )
    {
        position =  [ camera position ];

        FVector3 cameraForward  = [ camera forward  ];
        FVector3 cameraPosition = [ camera position ];

        FVector3 cameraForwardProjectedOnBasePlane = { cameraForward.x, 0.0f, cameraForward.z };
        fv3_v_normalise(&cameraForward);
        fv3_v_normalise(&cameraForwardProjectedOnBasePlane);

        // replace with atan2
        // need y and z values to compute angle between xz plane and forward vector

        float cosAngle = fv3_vv_dot_product(&cameraForward, &cameraForwardProjectedOnBasePlane);
        float angle = RADIANS_TO_DEGREE(acosf(cosAngle));

        FMatrix4 rotationX;

        // camera looks upwards
        if ( cameraForward.y >= 0.0f )
        {
            fm4_s_rotatex_m((45.0f + angle), &rotationX);
        }
        else
        {
            float deltaAngle = 45.0f - angle;

            if ( deltaAngle > 0.0f )
            {
                fm4_s_rotatex_m(deltaAngle, &rotationX);
            }
            else
            {
                fm4_m_set_identity(&rotationX);
            }
        }

        fm4_mm_multiply_m(&rotationX, [camera view], &view);

        fquat_m4_to_quaternion_q(&view, &orientation);
        fquat_q_normalise(&orientation);
        fquat_q_conjugate(&orientation);
    }
    else
    {
    */
        // camera looking upwards



    //}
}

@end

@implementation ODProjector

- (id) init
{
	return [ self initWithName:@"Projector" ];
}

- (id) initWithName:(NSString *)newName
{
	self = [ super initWithName:newName ];

    m4_m_set_identity(&view);
    m4_m_set_identity(&projection);
    m4_m_set_identity(&viewProjection);
    m4_m_set_identity(&inverseViewProjection);

    quat_set_identity(&orientation);
    v3_v_init_with_zeros(&position);

    position.y = 150.0;

    yaw   = 0.0;
    pitch = 0.0;

    v3_v_init_with_zeros(&forward);
    v3_v_init_with_zeros(&up);
    v3_v_init_with_zeros(&right);
    forward.z = -1.0;

    renderFrustum = NO;

    frustum = [[ ODFrustum alloc ] initWithName:@"ProjectorFrustum" ];

    pitchMinusAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"PitchMinus" inputEvent:NpKeyboardS ];
    pitchPlusAction  = [[[ NP Input ] inputActions ] addInputActionWithName:@"PitchPlus"  inputEvent:NpKeyboardW ];
    yawMinusAction   = [[[ NP Input ] inputActions ] addInputActionWithName:@"YawMinus"   inputEvent:NpKeyboardA ];
    yawPlusAction    = [[[ NP Input ] inputActions ] addInputActionWithName:@"YawPlus"    inputEvent:NpKeyboardD ];

    connectedToCameraLastFrame = connectedToCamera = YES;

	return self;
}

- (void) dealloc
{
    SAFE_DESTROY(frustum);
    SAFE_DESTROY(camera);

	[ super dealloc ];
}

- (Vector3) position
{
	return position;
}

- (Quaternion) orientation
{
    return orientation;
}

- (double) yaw
{
    return yaw;
}

- (double) pitch
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

- (ODCamera *) camera
{
    return camera;
}

- (ODFrustum *) frustum
{
    return frustum;
}

- (BOOL) connecting
{
    return ( connectedToCameraLastFrame == NO && connectedToCamera == YES ) ? YES : NO;
}

- (BOOL) disconnecting
{
    return ( connectedToCameraLastFrame == YES && connectedToCamera == NO ) ? YES : NO;
}

- (void) setPosition:(const Vector3)newPosition
{
	position = newPosition;
}

- (void) setCamera:(ODCamera *)newCamera
{
    ASSIGN(camera, newCamera);
}

- (void) setRenderFrustum:(BOOL)newRenderFrustum
{
    renderFrustum = newRenderFrustum;
}

- (void) update:(const double)frameTime
{
    NSAssert(camera != nil, @"No camera attached");

    const double pitchYaw = frameTime * 45.0;

    if ( [ pitchMinusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:0.0f andPitch:-pitchYaw ];
    }

    if ( [ pitchPlusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:0.0 andPitch:pitchYaw ];
    }

    if ( [ yawMinusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:-pitchYaw  andPitch:0.0 ];
    }

    if ( [ yawPlusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:pitchYaw andPitch:0.0 ];
    }

    [ self updateProjection ];
    [ self updateView ];

    /*
    [ frustum updateWithPosition:position
                     orientation:orientation
                             fov:fov
                       nearPlane:nearPlane
                        farPlane:farPlane
                     aspectRatio:aspectRatio ];
    */

    m4_mm_multiply_m(&projection, &view, &viewProjection);
    m4_m_inverse_m(&viewProjection, &inverseViewProjection);

    connectedToCameraLastFrame = connectedToCamera;
}

- (void) render
{
    NSAssert(camera != nil, @"No camera attached");

    //if ( renderFrustum == YES && connectedToCamera == NO)
    if ( renderFrustum == YES )
    {
        [[[ NP Core ] transformationState ] resetModelMatrix ];
        [ frustum render ];
    }
}

@end
