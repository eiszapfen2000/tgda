#include "FQuaternion.h"

#include <math.h>

NpFreeList * NP_FQUATERNION_FREELIST = NULL;

void npmath_fquaternion_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_FQUATERNION_FREELIST,FQuaternion,512)
}

void fquat_q_conjugate(FQuaternion * q)
{
    FQ_X(*q) = -FQ_X(*q);
    FQ_Y(*q) = -FQ_Y(*q);
    FQ_Z(*q) = -FQ_Z(*q);
}

void fquat_q_conjugate_q(const FQuaternion * const q, FQuaternion * conjugate)
{
    FQ_X(*conjugate) = -FQ_X(*q);
    FQ_Y(*conjugate) = -FQ_Y(*q);
    FQ_Z(*conjugate) = -FQ_Z(*q);
    FQ_W(*conjugate) =  FQ_W(*q);
}

Float fquat_q_magnitude(const FQuaternion * const q)
{
    return sqrt( FQ_X(*q) * FQ_X(*q) + FQ_Y(*q) * FQ_Y(*q) + FQ_Z(*q) * FQ_Z(*q) + FQ_W(*q) * FQ_W(*q) );
}

void fquat_q_magnitude_s(const FQuaternion * const q, Float * magnitude)
{
    *magnitude = sqrt( FQ_X(*q) * FQ_X(*q) + FQ_Y(*q) * FQ_Y(*q) + FQ_Z(*q) * FQ_Z(*q) + FQ_W(*q) * FQ_W(*q) );
}

void fquat_q_normalise(FQuaternion * q)
{
    Float magnitude = fquat_q_magnitude(q);

    FQ_X(*q) /= magnitude;
    FQ_Y(*q) /= magnitude;
    FQ_Z(*q) /= magnitude;
    FQ_W(*q) /= magnitude;
}

void fquat_q_normalise_q(const FQuaternion * const q, FQuaternion * normalised)
{
    Float magnitude = fquat_q_magnitude(q);

    FQ_X(*normalised) = FQ_X(*q)/magnitude;
    FQ_Y(*normalised) = FQ_Y(*q)/magnitude;
    FQ_Z(*normalised) = FQ_Z(*q)/magnitude;
    FQ_W(*normalised) = FQ_W(*q)/magnitude;
}

void fquat_qq_multiply_q(const FQuaternion * const q1, const FQuaternion * const q2, FQuaternion * result)
{
    FQ_W(*result) = fv3_vv_dot_product( &FQ_V(*q1), &FQ_V(*q2) );

    FVector3 cross, scale1, scale2;

    fv3_vv_cross_product_v( &FQ_V(*q1), &FQ_V(*q2), &cross);

    fv3_sv_scale_v( &FQ_V(*q1), &FQ_W(*q2), &scale1);
    fv3_sv_scale_v( &FQ_V(*q2), &FQ_W(*q1), &scale2);

    fv3_vv_add_v( &cross, &scale1, &cross);
    fv3_vv_add_v( &cross, &scale2, &FQ_V(*result));

    fquat_q_normalise(result);
}
