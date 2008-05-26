#import "TOCamera.h"
#import "Graphics/npgl.h"
#import "Core/World/NPTransformationState.h"
#import "Core/World/NPTransformationStateManager.h"
#import "Core/NPEngineCore.h"

@implementation TOCamera

- (id) init
{
	return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
	return [ self initWithName:@"TOCamera" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
	self = [ super initWithName:newName parent:newParent ];

	view = fm4_alloc_init();
	projection = fm4_alloc_init();

	orientation = quat_alloc_init();
	position = fv3_alloc_init();

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
	fm4_m_set_identity(view);
	fm4_m_set_identity(projection);

	quat_set_identity(orientation);
	fv3_v_zeros(position);
}

- (FVector3 *) position
{
	return position;
}

- (void) setPosition:(FVector3 *)newPosition
{
	*position = *newPosition;
}

- (void) setFov:(Float)newFov
{
	fov = newFov;
}

- (void) setNearPlane:(Float)newNearPlane
{
	nearPlane = newNearPlane;
}

- (void) setFarPlane:(Float)newFarPlane
{
	farPlane = newFarPlane;
}

- (void) setAspectRatio:(Float)newAspectRatio
{
	aspectRatio = newAspectRatio;
}

- (void) updateProjection
{
    glMatrixMode(GL_PROJECTION);

    fm4_msss_projection_matrix(projection, aspectRatio, fov, nearPlane, farPlane);

    glLoadMatrixf((Float *)(FM_ELEMENTS(*projection)));
    glMatrixMode(GL_MODELVIEW);
}

- (void) updateView
{
    fm4_m_set_identity(view);

    Quaternion q;
    quat_q_conjugate_q(orientation, &q);

    FMatrix4 rotate;
    quat_q_to_fmatrix4_m(&q, &rotate);

    FMatrix4 tmp;
    fm4_mm_multiply_m(view, &rotate, &tmp);

    FVector3 invpos;
    fv3_v_invert_v(position, &invpos);

    FMatrix4 trans;
    fm4_mv_translation_matrix(&trans, &invpos);

    fm4_mm_multiply_m(&tmp, &trans, view);

    glLoadMatrixf((Float *)(FM_ELEMENTS(*view)));
}

- (void) update
{
	[ self updateProjection ];
	[ self updateView ];
}

- (void) render
{
    NPTransformationState * trafo = [[[ NPEngineCore instance ] transformationStateManager ] currentActiveTransformationState ];
    [ trafo setViewMatrix:view ];
    [ trafo setProjectionMatrix:projection ];
}

@end
