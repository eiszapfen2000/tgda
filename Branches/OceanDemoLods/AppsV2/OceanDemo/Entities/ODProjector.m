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
- (void) updateProjection;
- (void) updateView;

@end

@implementation ODProjector (Private)

- (void) cameraRotateUsingYaw:(const double)yawDegrees andPitch:(const double)pitchDegrees
{
    if ( yawDegrees != 0.0 )
    {
        yaw += yawDegrees;
    }

    if ( pitchDegrees != 0.0 )
    {
        pitch += pitchDegrees;
    }

    quat_q_init_with_axis_and_degrees(&orientation, NP_WORLD_Y_AXIS, yaw);
    quat_q_rotatex(&orientation, pitch);
}

- (void) updateProjection
{
    // Enlarge horizontal field of view
    float horizontalFOV = [ camera fov ] * [ camera aspectRatio ] * 1.15;
    // Set vertical field of view to nearly 90°, with exactly 90° we run into
    // numerical issues
    //fov = 90.0 - 0.05;
    //aspectRatio = horizontalFOV / fov;

    fov = [ camera fov ];
    //aspectRatio = [ camera aspectRatio ];
    aspectRatio = horizontalFOV / fov;

    nearPlane = [ camera nearPlane ];
    farPlane  = [ camera farPlane  ];

    m4_mssss_projection_matrix(&projection, aspectRatio, fov, nearPlane, farPlane);
}

- (void) updateView
{
    /*
    const Vector3 planeNormal = *NP_WORLD_Y_AXIS;

    Plane lowerPlane, basePlane, upperPlane;
    plane_pvs_init_with_normal_and_scalar(&lowerPlane, &planeNormal, lowerBound);
    plane_pvs_init_with_normal_and_scalar(&basePlane,  &planeNormal, base);
    plane_pvs_init_with_normal_and_scalar(&upperPlane, &planeNormal, upperBound);

    Vector3 cameraPosition = [ camera position ];
    Vector3 cameraForward  = [ camera forward  ];

    const double dotNF = v3_vv_dot_product(&planeNormal, &cameraForward);

    const double distanceToLowerPlane = plane_pv_signed_distance_from_plane(&lowerPlane, &cameraPosition);
    const double distanceToBasePlane  = plane_pv_signed_distance_from_plane(&basePlane,  &cameraPosition);
    const double distanceToUpperPlane = plane_pv_signed_distance_from_plane(&upperPlane, &cameraPosition);

    NSLog(@"%lf %lf %lf", distanceToLowerPlane, distanceToBasePlane, distanceToUpperPlane);

    const bool lookingDown = (dotNF < 0.0);
    const bool underWater  = (distanceToLowerPlane <  0.0 );
    const bool lowerSector = (distanceToLowerPlane >= 0.0 && distanceToBasePlane  < 0.0);
    const bool upperSector = (distanceToBasePlane  >= 0.0 && distanceToUpperPlane < 0.0);
    const bool outside     = (distanceToUpperPlane >= 0.0);

    double move = 1.0;

    // keep projector y position at least as high as upperBound
    if ( !outside )
    {
        move = -distanceToUpperPlane;
    }

    Vector3 moveUp = v3_sv_scaled(move, &planeNormal);

    NSLog(@"%lf", move);

    Vector3 direction;

    if ((lookingDown && !(lowerSector || underWater)) || (!lookingDown && (lowerSector || underWater)))
    {
        direction = cameraForward;
    }
    else
    {
        const double rf = 2.0 * dotNF;
        const Vector3 tmp = v3_sv_scaled(rf, &planeNormal);
        direction = v3_vv_sub(&cameraForward, &tmp);
    }

    Ray ray;
    Vector3 aimOne;

    ray.point = cameraPosition;
    ray.direction = direction;

    const int32_t result = plane_pr_intersect_with_ray_v(&basePlane, &ray, &aimOne);

    const Vector3 forwardScaled = v3_sv_scaled(10.0, &cameraForward);
    const Vector3 forwardDirection = v3_vv_add(&cameraPosition, &forwardScaled);
    const double dotNForwardDirection = v3_vv_dot_product(&planeNormal, &forwardDirection);
    const Vector3 normalScaled = v3_sv_scaled(dotNForwardDirection, &planeNormal);
    const Vector3 aimTwo = v3_vv_sub(&forwardDirection, &normalScaled);

    NSLog(@"%d\n%s\n%s", result, v3_v_to_string(&aimOne), v3_v_to_string(&aimTwo));

    const double dotNFA = fabs(dotNF);
    const Vector3 ao = v3_sv_scaled(dotNFA, &aimOne);
    const Vector3 at = v3_sv_scaled(1.0 - dotNFA, &aimTwo);

    const Vector3 aim = v3_vv_add(&ao, &at);

    NSLog(@"%s", v3_v_to_string(&aim));

    position = v3_vv_add(&cameraPosition, &moveUp);

    m4_vvv_look_at_matrix_m(&position, &aim, NP_WORLD_Y_AXIS, &view);

    Quaternion q = quat_m4_to_quaternion(&view);
    orientation = quat_q_conjugated(&q);
    */

    yaw   = fmod(yaw,   360.0);
    pitch = fmod(pitch, 360.0);

    if ( yaw < 0.0 )
    {
        yaw += 360.0;
    }

    if ( pitch < 0.0 )
    {
        pitch += 360.0;
    }

    double localPitch = pitch;
    double localYaw = yaw;
    double localfov = fov;

    if ( connectedToCamera == YES )
    {
        position   = [ camera position ];
        localPitch = [ camera pitch ];
        localYaw   = [ camera yaw ];
        localfov   = [ camera fov ];
    }

    const double halfCameraFOV = localfov / 2.0;

    if ( localPitch >= 0.0 && localPitch <= 180.0 )
    {
        if ( localPitch <= 90.0 )
        {
            localPitch = 360.0 - halfCameraFOV;
        }
        else
        {
            localPitch = 180.0 + halfCameraFOV;
        }
    }
    else
    {
        if ( localPitch < (180.0 + halfCameraFOV) )
        {
            localPitch = 180.0 + halfCameraFOV;
        }

        if ( localPitch > (360.0 - halfCameraFOV) )
        {
            localPitch = 360.0 - halfCameraFOV;
        }
    }

    if ( localPitch >= (180.0 + halfCameraFOV) )
    {
        localPitch = MAX(localPitch, 180.0 + halfCameraFOV + 1.0);
    }

    if ( localPitch <= (360.0 - halfCameraFOV) )
    {
        localPitch = MIN(localPitch, 360.0 - halfCameraFOV - 1.0);
    }

    m4_m_set_identity(&view);
    quat_q_init_with_axis_and_degrees(&orientation, NP_WORLD_Y_AXIS, localYaw);
    quat_q_rotatex(&orientation, localPitch);
    Quaternion q = quat_q_conjugated(&orientation);
    Vector3 invpos = v3_v_inverted(&position);
    Matrix4 rotate = quat_q_to_matrix4(&q);
    Matrix4 translate = m4_v_translation_matrix(&invpos);
    m4_mm_multiply_m(&rotate, &translate, &view);
}

@end

static const OdProjectorRotationEvents defaultRotationEvents
    = {.pitchMinus = NpInputEventUnknown, .pitchPlus = NpInputEventUnknown,
       .yawMinus   = NpInputEventUnknown, .yawPlus   = NpInputEventUnknown };

static NSString * const pitchMinusActionString = @"PitchMinus";
static NSString * const pitchPlusActionString  = @"PitchPlus";
static NSString * const yawMinusActionString   = @"YawMinus";
static NSString * const yawPlusActionString    = @"YawPlus";

static NPInputAction * create_input_action(NSString * projectorName, NSString * actionName, NpInputEvent event)
{
    if ( event != NpInputEventUnknown )
    {
        NSMutableString * name = [ NSMutableString stringWithString:projectorName ];
        [ name appendString:actionName ];

        return
            [[[ NP Input ] inputActions ]
                    addInputActionWithName:name
                                inputEvent:event ]; 
    }

    return nil;
}

@implementation ODProjector

- (id) init
{
	return [ self initWithName:@"Projector" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName rotationEvents:defaultRotationEvents ];
}

- (id) initWithName:(NSString *)newName
     rotationEvents:(OdProjectorRotationEvents)rotationEvents
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

    lowerBound = base = upperBound = 0.0;

    fov = 45.0;
    nearPlane = 0.1;
    farPlane = 100.0;
    aspectRatio = 1.0f;

    v3_v_init_with_zeros(&forward);
    v3_v_init_with_zeros(&up);
    v3_v_init_with_zeros(&right);
    forward.z = -1.0;

    pitchMinusAction = create_input_action(name, pitchMinusActionString, rotationEvents.pitchMinus);
    pitchPlusAction  = create_input_action(name, pitchPlusActionString,  rotationEvents.pitchPlus);
    yawMinusAction   = create_input_action(name, yawMinusActionString,   rotationEvents.yawMinus);
    yawPlusAction    = create_input_action(name, yawPlusActionString,    rotationEvents.yawPlus);

    connectedToCameraLastFrame = connectedToCamera = YES;

	return self;
}

- (void) dealloc
{
    SAFE_DESTROY(camera);

	[ super dealloc ];
}

- (double) lowerBound
{
    return lowerBound;
}

- (double) base
{
    return base;
}

- (double) upperBound
{
    return upperBound;
}

- (double) fov
{
    return fov;
}

- (double) aspectRatio
{
    return aspectRatio;
}

- (double) nearPlane
{
    return nearPlane;
}

- (double) farPlane
{
    return farPlane;
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

- (void) setLowerBound:(double)newLowerBound
{
    lowerBound = newLowerBound;
}

- (void) setBase:(double)newBase
{
    base = newBase;
}

- (void) setUpperBound:(double)newUpperBound
{
    upperBound = newUpperBound;
}

- (void) setCamera:(ODCamera *)newCamera
{
    ASSIGN(camera, newCamera);
}

- (void) update:(const double)frameTime
{
    NSAssert(camera != nil, @"No camera attached");

    const double pitchYaw = frameTime * 45.0;

    if (( pitchMinusAction != nil ) && ([ pitchMinusAction active ] == YES ))
    {
        [ self cameraRotateUsingYaw:0.0f andPitch:-pitchYaw ];
    }

    if (( pitchPlusAction != nil ) && ([ pitchPlusAction active ] == YES ))
    {
        [ self cameraRotateUsingYaw:0.0 andPitch:pitchYaw ];
    }

    if (( yawMinusAction != nil ) && ([ yawMinusAction active ] == YES ))
    {
        [ self cameraRotateUsingYaw:-pitchYaw  andPitch:0.0 ];
    }

    if (( yawPlusAction != nil ) && ([ yawPlusAction active ] == YES ))
    {
        [ self cameraRotateUsingYaw:pitchYaw andPitch:0.0 ];
    }

    [ self updateProjection ];
    [ self updateView ];

    m4_mm_multiply_m(&projection, &view, &viewProjection);
    m4_m_inverse_m(&viewProjection, &inverseViewProjection);

    connectedToCameraLastFrame = connectedToCamera;
}

- (void) render
{
    NSAssert(camera != nil, @"No camera attached");

    /*
    if ( renderFrustum == YES )
    {
        [[[ NP Core ] transformationState ] resetModelMatrix ];
        [ frustum render ];
    }
    */
}

@end
