#import "NPCamera.h"
#import "NPCameraManager.h"
#import "Graphics/npgl.h"
#import "Core/NPEngineCore.h"

@implementation NPCamera

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NP Camera" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    view = fm4_alloc();
    projection = fm4_alloc();

    orientation = quat_alloc();
    position = fv3_alloc();

    [ self reset ];

    return self;
}

- (void) reset
{
    fieldOfView = 45.0f;
    aspectRatio = 1.0f;
    nearPlane = 0.5f;
    farPlane = 100.0f;

    fv3_v_zeros(position);

    [ self resetMatrices ];
    [ self resetOrientation ];
}

- (void) resetMatrices
{
    fm4_m_set_identity(view);
    fm4_m_set_identity(projection);
}

- (void) resetOrientation
{
    quat_set_identity(orientation);
}

- (FMatrix4 *) view
{
    return view;
}

- (FMatrix4 *) projection
{
    return projection;
}

- (void) rotateX:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        Double degrees = -degrees;
        quat_q_rotatex(orientation, &degrees);
    }
}

- (void) rotateY:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        degrees = -degrees;
        quat_q_rotatey(orientation, &degrees);
    }
}

- (void) rotateZ:(Double)degrees
{
    if ( degrees != 0.0 )
    {
        degrees = -degrees;
        quat_q_rotatez(orientation, &degrees);
    }
}

- (FVector3 *) position
{
    return position;
}

- (void) setPosition:(FVector3 *)newPosition
{
    FV_X(*position) = FV_X(*newPosition);    
    FV_Y(*position) = FV_Y(*newPosition);
    FV_Z(*position) = FV_Z(*newPosition);
}

- (void) update
{
    [ self updateProjectionMatrix ];
    [ self updateViewMatrix ];
}

- (void) updateViewMatrix
{
    fm4_m_set_identity(view);

    Quaternion q;
    quat_q_conjugate_q(orientation, &q);

    FMatrix4 rotate;
    quat_q_to_fmatrix4_m(&q, &rotate);

    FMatrix4 tmp;
    fm4_mm_multiply_m(view,&rotate,&tmp);

    FVector3 invpos;
    fv3_v_invert_v(position,&invpos);

    FMatrix4 trans;
    fm4_mv_translation_matrix(&trans,&invpos);

    fm4_mm_multiply_m(&tmp,&trans,view);

    glLoadMatrixf((Float *)(FM_ELEMENTS(*view)));
}

- (void) updateProjectionMatrix
{
    glMatrixMode(GL_PROJECTION);

    fm4_msss_projection_matrix(projection,aspectRatio,fieldOfView,nearPlane,farPlane);

    glLoadMatrixf((Float *)(FM_ELEMENTS(*projection)));
    glMatrixMode(GL_MODELVIEW);
}

- (void) activate
{
    [ [ [ NPEngineCore instance ] cameraManager ] setCurrentActiveCamera:self ];
    [ self update ];
}

@end
