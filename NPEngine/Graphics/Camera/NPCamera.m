#import "NPCamera.h"
#import "NPCameraManager.h"
#import "Core/World/NPTransformationState.h"
#import "Core/World/NPTransformationStateManager.h"
#import "Graphics/npgl.h"
#import "Core/NPEngineCore.h"
#import "Core/Math/NpMath.h"

@implementation NPCamera

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPCamera" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    view = fm4_alloc_init();
    projection = fm4_alloc_init();

    orientation = quat_alloc_init();
    position = fv3_alloc_init();

    [ self reset ];

    return self;
}

- (void) dealloc
{
    view = fm4_free(view);
    projection = fm4_free(projection);
    orientation = quat_free(orientation);
    position = fv3_free(position);

    [ super dealloc ];
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

- (void) setView:(FMatrix4 *)newView
{
    *view = *newView;
}

- (FMatrix4 *) projection
{
    return projection;
}

- (void) setProjection:(FMatrix4 *)newProjection
{
    *projection = *newProjection;
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
    V_X(*position) = V_X(*newPosition);    
    V_Y(*position) = V_Y(*newPosition);
    V_Z(*position) = V_Z(*newPosition);
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
    //NPLOG(([NSString stringWithFormat:@"%s",quat_q_to_string(&q)]));

    FMatrix4 rotate;
    quat_q_to_fmatrix4_m(&q, &rotate);
    //NPLOG(([NSString stringWithFormat:@"%s",fm4_m_to_string(&rotate)]));

    FMatrix4 tmp;
    fm4_mm_multiply_m(view,&rotate,&tmp);
    //NPLOG(([NSString stringWithFormat:@"%s",fm4_m_to_string(view)]));
    //NPLOG(([NSString stringWithFormat:@"%s",fm4_m_to_string(&tmp)]));

    FVector3 invpos;
    fv3_v_invert_v(position,&invpos);
    //NPLOG(([NSString stringWithFormat:@"%s",fv3_v_to_string(&invpos)]));

    FMatrix4 trans;
    fm4_mv_translation_matrix(&trans,&invpos);
    //NPLOG(([NSString stringWithFormat:@"%s",fm4_m_to_string(&trans)]));

    fm4_mm_multiply_m(&tmp,&trans,view);
    //NPLOG(([NSString stringWithFormat:@"%s",fm4_m_to_string(view)]));

    glLoadMatrixf((Float *)(M_ELEMENTS(*view)));
}

- (void) updateProjectionMatrix
{
    glMatrixMode(GL_PROJECTION);

    fm4_msss_projection_matrix(projection,aspectRatio,fieldOfView,nearPlane,farPlane);

    glLoadMatrixf((Float *)(M_ELEMENTS(*projection)));
    glMatrixMode(GL_MODELVIEW);
}

- (void) activate
{
    [ [ [ NPEngineCore instance ] cameraManager ] setCurrentActiveCamera:self ];
    [ self update ];
}

- (void) render
{
    NPTransformationState * trafo = [[[ NPEngineCore instance ] transformationStateManager ] currentTransformationState ];
    [ trafo setViewMatrix:view ];
    [ trafo setProjectionMatrix:projection ];
}

@end
