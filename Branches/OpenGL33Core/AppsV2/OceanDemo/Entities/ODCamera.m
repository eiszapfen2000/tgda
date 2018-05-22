#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "GL/glew.h"
#import "Graphics/NPEngineGraphics.h"
#import "Graphics/NPViewport.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPKeyboard.h"
#import "Input/NPMouse.h"
#import "NP.h"
#import "ODProjector.h"
#import "ODCamera.h"

@interface ODCamera (Private)

- (void) processInput:(const double)frameTime;
- (void) cameraRotateUsingYaw:(const double)yawDegrees andPitch:(const double)pitchDegrees;
- (void) strafe:(const double)scale;
- (void) updateProjection;
- (void) updateView;

@end

@implementation ODCamera (Private)

- (void) processInput:(const double)frameTime
{
    if (( rotateAction != nil ) && ( [ rotateAction active ] == YES ))
    {
        NPMouse * mouse = [[ NP Input ] mouse ];
        int32_t deltaX = [ mouse deltaX ];
        int32_t deltaY = [ mouse deltaY ];

        if ( deltaX != 0 || deltaY != 0 )
        {
            double y = 0.3 * (double)(-deltaX);
            double p = 0.3 * (double)(-deltaY);
            [ self cameraRotateUsingYaw:y andPitch:p ];
        }
    }

    if (( strafeAction != nil ) && ( [ strafeAction active ] == YES ))
    {
        NPMouse * mouse = [[ NP Input ] mouse ];
        int32_t deltaX = [ mouse deltaX ];

        [ self strafe:frameTime * 25.0 * deltaX ];
    }

    if (( forwardAction != nil ) && ( [ forwardAction active ] == YES ))
    {
        quat_q_forward_vector_v(&orientation, &forward);

        position.x += (forward.x * 20.0);
        position.y += (forward.y * 20.0);
        position.z += (forward.z * 20.0);
    }

    if (( backwardAction != nil ) && ( [ backwardAction active ] == YES ))
    {
        quat_q_forward_vector_v(&orientation, &forward);

        position.x -= (forward.x * 20.0);
        position.y -= (forward.y * 20.0);
        position.z -= (forward.z * 20.0);
    }
}

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
}

- (void) strafe:(const double)scale
{
    Vector3 right;
    quat_q_right_vector_v(&orientation, &right);
    
    position.x += (right.x * scale);
    position.y += (right.y * scale);
    position.z += (right.z * scale);
}

- (void) updateProjection
{
    aspectRatio = [[[ NP Graphics ] viewport ] aspectRatio ];
    m4_mssss_projection_matrix(&projection, aspectRatio, fov, nearPlane, farPlane);
}

- (void) updateView
{
    m4_m_set_identity(&view);

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

@end

static const OdCameraMovementEvents defaultMovementEvents
    = {.rotate  = NpMouseButtonLeft, .strafe   = NpMouseButtonRight,
       .forward = NpMouseWheelUp,    .backward = NpMouseWheelDown };

static NSString * const rotateActionString   = @"Rotate";
static NSString * const strafeActionString   = @"Strafe";
static NSString * const forwardActionString  = @"Forward";
static NSString * const backwardActionString = @"Backward";

static NPInputAction * create_input_action(NSString * cameraName, NSString * actionName, NpInputEvent event)
{
    if ( event != NpInputEventUnknown )
    {
        NSMutableString * name = [NSMutableString stringWithString:cameraName];
        [ name appendString:actionName ];

        return
            [[[ NP Input ] inputActions ]
                    addInputActionWithName:name
                                inputEvent:event ]; 
    }

    return nil;
}

@implementation ODCamera

- (id) init
{
	return [ self initWithName:@"ODCamera" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName movementEvents:defaultMovementEvents ];
}

- (id) initWithName:(NSString *)newName
     movementEvents:(OdCameraMovementEvents)movementEvents
{
	self = [ super initWithName:newName ];

    m4_m_set_identity(&view);
    m4_m_set_identity(&projection);
    m4_m_set_identity(&inverseViewProjection);
    quat_set_identity(&orientation);
    v3_v_init_with_zeros(&position);

    position.x = 0.0f;
    position.y = 120.0f;
    position.z = 0.0;
    v3_v_init_with_zeros(&forward);
    forward.z  = -1.0;

    fov         = 45.0f;
    nearPlane   = 0.1f;
    farPlane    = 2500.0f;
    aspectRatio = 1.0f;

    yaw   = 0.0;
    pitch = -30.0;

    inputLocked = NO;

    rotateAction   = create_input_action(name, rotateActionString,   movementEvents.rotate);
    strafeAction   = create_input_action(name, strafeActionString,   movementEvents.strafe);
    forwardAction  = create_input_action(name, forwardActionString,  movementEvents.forward);
    backwardAction = create_input_action(name, backwardActionString, movementEvents.backward);

	return self;
}

- (void) dealloc
{
    [[[ NP Input ] inputActions ] removeInputAction:backwardAction ];
    [[[ NP Input ] inputActions ] removeInputAction:forwardAction  ];
    [[[ NP Input ] inputActions ] removeInputAction:strafeAction   ];
    [[[ NP Input ] inputActions ] removeInputAction:rotateAction   ];

	[ super dealloc ];
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

- (double) yaw
{
    return yaw;
}

- (double) pitch
{
    return pitch;
}

- (const Matrix4 * const) view
{
    return &view;
}

- (const Matrix4 * const) projection
{
    return &projection;
}

- (const Matrix4 * const) inverseViewProjection
{
    return &inverseViewProjection;
}

- (BOOL) inputLocked
{
    return inputLocked;
}

- (void) setNearPlane:(double)newNearPlane
{
    nearPlane = newNearPlane;
}

- (void) setFarPlane:(double)newFarPlane
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

- (void) setYaw:(const double)newYaw
{
    yaw = newYaw;
}

- (void) setPitch:(const double)newPitch
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
}

- (void) render
{
    NPTransformationState * trafo = [[ NP Core ] transformationState ];
    [ trafo setViewMatrix:&view ];
    [ trafo setProjectionMatrix:&projection ];
}

@end
