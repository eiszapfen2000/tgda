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

@implementation ODProjector

- (id) init
{
	return [ self initWithName:@"Projector" ];
}

- (id) initWithName:(NSString *)newName
{
	self = [ super initWithName:newName ];

    fm4_m_set_identity(&view);
    fm4_m_set_identity(&projection);
    fm4_m_set_identity(&viewProjection);
    fm4_m_set_identity(&inverseViewProjection);

    fquat_set_identity(&orientation);
    fv3_v_init_with_zeros(&position);

    yaw   = 0.0f;
    pitch = 0.0f;

    fv3_v_init_with_zeros(&forward);
    fv3_v_init_with_zeros(&up);
    fv3_v_init_with_zeros(&right);
    forward.z = -1.0f;

    renderFrustum = YES;

    frustum = [[ ODFrustum alloc ] initWithName:@"ProjectorFrustum" ];

    pitchMinusAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"PitchMinus" inputEvent:NpKeyboardS ];
    pitchPlusAction  = [[[ NP Input ] inputActions ] addInputActionWithName:@"PitchPlus"  inputEvent:NpKeyboardW ];
    yawMinusAction   = [[[ NP Input ] inputActions ] addInputActionWithName:@"YawMinus"   inputEvent:NpKeyboardA ];
    yawPlusAction    = [[[ NP Input ] inputActions ] addInputActionWithName:@"YawPlus"    inputEvent:NpKeyboardD ];

    connectedToCamera = NO;

	return self;
}

- (void) dealloc
{
    SAFE_DESTROY(frustum);
    SAFE_DESTROY(camera);

	[ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    NSAssert(config != nil, @"");

    NSString * projectorName   = [ config objectForKey:@"Name" ];
    NSArray  * positionStrings = [ config objectForKey:@"Position" ];

    if ( projectorName == nil || positionStrings == nil )
    {
        //NPLOG_ERROR(@"%@: Dictionary incomplete", name);
        if ( error != NULL )
        {
            *error = nil;
        }

        return NO;
    }

    [ self setName:projectorName ];

    position.x = [[ positionStrings objectAtIndex:0 ] floatValue ];
    position.y = [[ positionStrings objectAtIndex:1 ] floatValue ];
    position.z = [[ positionStrings objectAtIndex:2 ] floatValue ];

    return YES;
}

- (void) reset
{
	fm4_m_set_identity(&view);
	fm4_m_set_identity(&projection);
	fm4_m_set_identity(&viewProjection);
	fm4_m_set_identity(&inverseViewProjection);

	fquat_set_identity(&orientation);
	fv3_v_init_with_zeros(&position);
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

- (FMatrix4 *) inverseViewProjection
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

- (void) setPosition:(const FVector3)newPosition
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

- (void) updateYaw:(float)degrees
{
    if ( degrees != 0.0f )
    {
        yaw += degrees;

        if ( yaw < 0.0f )
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

        if ( pitch < 0.0f )
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

- (void) moveForward
{
    fquat_q_forward_vector_v(&orientation, &forward);

    position.x += forward.x;
    position.y += forward.y;
    position.z += forward.z;
}

- (void) moveBackward
{
    fquat_q_forward_vector_v(&orientation, &forward);

    position.x -= forward.x;
    position.y -= forward.y;
    position.z -= forward.z;
}

- (void) activate
{
    NPTransformationState * trafo = [[ NP Core ] transformationState ];
    [ trafo setViewMatrix:&view ];
    [ trafo setProjectionMatrix:&projection ];
}

- (void) updateProjection
{
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
        aspectRatio = [ camera aspectRatio ];
        fov = [ camera fov ];
    }

    nearPlane = [ camera nearPlane ];
    farPlane  = [ camera farPlane  ];

    fm4_mssss_projection_matrix(&projection, aspectRatio, fov, nearPlane, farPlane);
}

- (void) updateView
{
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
        // camera looking upwards
        if ( pitch >= 0.0f && pitch <= 180.0f )
        {
            if ( pitch <= 90.0f )
            {
                pitch = 315.0f;
            }
            else
            {
                pitch = 225.0f;
            }
        }
        else
        {
            if ( pitch < 225.0f )
            {
                pitch = 225.0f;
            }

            if ( pitch > 315.0f )
            {
                pitch = 315.0f;
            }
        }

        fm4_m_set_identity(&view);
        fquat_q_init_with_axis_and_degrees(&orientation, NP_WORLDF_Y_AXIS, yaw);
        fquat_q_rotatex(&orientation, pitch);
        FQuaternion q = fquat_q_conjugated(&orientation);
        FVector3 invpos = fv3_v_inverted(&position);
        FMatrix4 rotate = fquat_q_to_fmatrix4(&q);
        FMatrix4 translate = fm4_v_translation_matrix(&invpos);
        fm4_mm_multiply_m(&rotate, &translate, &view);
    }
}

- (void) update:(const float)frameTime
{
    NSAssert(camera != nil, @"No camera attached");

    const float pitchYaw = frameTime * 45.0f;

    if ( [ pitchMinusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:0.0f andPitch:-pitchYaw ];
    }

    if ( [ pitchPlusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:0.0f andPitch:pitchYaw ];
    }

    if ( [ yawMinusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:-pitchYaw  andPitch:0.0f ];
    }

    if ( [ yawPlusAction active ] == YES )
    {
        [ self cameraRotateUsingYaw:pitchYaw andPitch:0.0f ];
    }

    [ self updateProjection ];
    [ self updateView ];

    [ frustum updateWithPosition:position
                     orientation:orientation
                             fov:fov
                       nearPlane:nearPlane
                        farPlane:farPlane
                     aspectRatio:aspectRatio ];

    fm4_mm_multiply_m(&projection, &view, &viewProjection);
    fm4_m_inverse_m(&viewProjection, &inverseViewProjection);
}

- (void) render
{
    NSAssert(camera != nil, @"No camera attached");

    if ( renderFrustum == YES && connectedToCamera == NO)
    {
        [[[ NP Core ] transformationState ] resetModelMatrix ];
        [ frustum render ];
    }
}

@end
