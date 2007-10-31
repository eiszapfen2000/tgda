#include <math.h>

#include "Quaternion.h"

NpFreeList * NP_QUATERNION_FREELIST = NULL;

void npmath_quaternion_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_QUATERNION_FREELIST,Quaternion,512)
}

void quat_q_conjugate(Quaternion * q)
{
    Q_X(*q) = -Q_X(*q);
    Q_Y(*q) = -Q_Y(*q);
    Q_Z(*q) = -Q_Z(*q);
}

void quat_q_conjugate_q(const Quaternion * const q, Quaternion * conjugate)
{
    Q_X(*conjugate) = -Q_X(*q);
    Q_Y(*conjugate) = -Q_Y(*q);
    Q_Z(*conjugate) = -Q_Z(*q);
    Q_W(*conjugate) =  Q_W(*q);
}

void quat_q_magnitude_s(const Quaternion * const q, Double * magnitude)
{
    *magnitude = sqrt( Q_X(*q) * Q_X(*q) + Q_Y(*q) * Q_Y(*q) + Q_Z(*q) * Q_Z(*q) + Q_W(*q) * Q_W(*q) );
}

void quat_q_normalise(Quaternion * q)
{
    Double magnitude = quat_q_magnitude(q);

    Q_X(*q) /= magnitude;
    Q_Y(*q) /= magnitude;
    Q_Z(*q) /= magnitude;
    Q_W(*q) /= magnitude;
}

void quat_q_normalise_q(const Quaternion * const q, Quaternion * normalised)
{
    Double magnitude = quat_q_magnitude(q);

    Q_X(*normalised) = Q_X(*q)/magnitude;
    Q_Y(*normalised) = Q_Y(*q)/magnitude;
    Q_Z(*normalised) = Q_Z(*q)/magnitude;
    Q_W(*normalised) = Q_W(*q)/magnitude;
}

void quat_qq_multiply_q(const Quaternion * const q1, const Quaternion * const q2, Quaternion * result)
{
    Q_W(*result) = v3_vv_dot_product( &Q_V(*q1), &Q_V(*q2) );

    Vector3 cross, scale1, scale2;

    v3_vv_cross_product_v( &Q_V(*q1), &Q_V(*q2), &cross);

    v3_sv_scale_v( &Q_V(*q1), &Q_W(*q2), &scale1);
    v3_sv_scale_v( &Q_V(*q2), &Q_W(*q1), &scale2);

    v3_vv_add_v( &cross, &scale1, &cross);
    v3_vv_add_v( &cross, &scale2, &Q_V(*result));

    quat_q_normalise(result);
}
/*
    xx      = X * X;
    xy      = X * Y;
    xz      = X * Z;
    xw      = X * W;

    yy      = Y * Y;
    yz      = Y * Z;
    yw      = Y * W;

    zz      = Z * Z;
    zw      = Z * W;

    mat[0]  = 1 - 2 * ( yy + zz );
    mat[1]  =     2 * ( xy - zw );
    mat[2]  =     2 * ( xz + yw );

    mat[4]  =     2 * ( xy + zw );
    mat[5]  = 1 - 2 * ( xx + zz );
    mat[6]  =     2 * ( yz - xw );

    mat[8]  =     2 * ( xz - yw );
    mat[9]  =     2 * ( yz + xw );
    mat[10] = 1 - 2 * ( xx + yy );

    mat[3]  = mat[7] = mat[11 = mat[12] = mat[13] = mat[14] = 0;
    mat[15] = 1;
*/
void quat_q_to_matrix3_m(const Quaternion * const q, Matrix3 * m)
{
    M_EL(*m,0,0) = 1 - 2 * ( Q_Y(*q) * Q_Y(*q) + Q_Z(*q) * Q_Z(*q) );
    M_EL(*m,0,1) =     2 * ( Q_X(*q) * Q_Y(*q) + Q_Z(*q) * Q_W(*q) );
    M_EL(*m,0,2) =     2 * ( Q_X(*q) * Q_Z(*q) - Q_Y(*q) * Q_W(*q) );

    M_EL(*m,1,0) =     2 * ( Q_X(*q) * Q_Y(*q) - Q_Z(*q) * Q_W(*q) );
    M_EL(*m,1,1) = 1 - 2 * ( Q_X(*q) * Q_X(*q) + Q_Z(*q) * Q_Z(*q) );
    M_EL(*m,1,2) =     2 * ( Q_Y(*q) * Q_Z(*q) + Q_X(*q) * Q_W(*q) );

    M_EL(*m,2,0) =     2 * ( Q_X(*q) * Q_Z(*q) + Q_Y(*q) * Q_W(*q) );
    M_EL(*m,2,1) =     2 * ( Q_Y(*q) * Q_Z(*q) - Q_X(*q) * Q_W(*q) );
    M_EL(*m,2,2) = 1 - 2 * ( Q_X(*q) * Q_X(*q) + Q_Y(*q) * Q_Y(*q) );
}

void quat_q_to_matrix4_m(const Quaternion * const q, Matrix4 * m)
{
    M_EL(*m,0,0) = 1 - 2 * ( Q_Y(*q) * Q_Y(*q) + Q_Z(*q) * Q_Z(*q) );
    M_EL(*m,0,1) =     2 * ( Q_X(*q) * Q_Y(*q) + Q_Z(*q) * Q_W(*q) );
    M_EL(*m,0,2) =     2 * ( Q_X(*q) * Q_Z(*q) - Q_Y(*q) * Q_W(*q) );

    M_EL(*m,1,0) =     2 * ( Q_X(*q) * Q_Y(*q) - Q_Z(*q) * Q_W(*q) );
    M_EL(*m,1,1) = 1 - 2 * ( Q_X(*q) * Q_X(*q) + Q_Z(*q) * Q_Z(*q) );
    M_EL(*m,1,2) =     2 * ( Q_Y(*q) * Q_Z(*q) + Q_X(*q) * Q_W(*q) );

    M_EL(*m,2,0) =     2 * ( Q_X(*q) * Q_Z(*q) + Q_Y(*q) * Q_W(*q) );
    M_EL(*m,2,1) =     2 * ( Q_Y(*q) * Q_Z(*q) - Q_X(*q) * Q_W(*q) );
    M_EL(*m,2,2) = 1 - 2 * ( Q_X(*q) * Q_X(*q) + Q_Y(*q) * Q_Y(*q) );

    M_EL(*m,0,3) = M_EL(*m,1,3) = M_EL(*m,2,3) = M_EL(*m,3,0) = M_EL(*m,3,1) = M_EL(*m,3,2) = 0.0;
    M_EL(*m,3,3) = 1.0;
}

Double quat_q_magnitude(const Quaternion * const q)
{
    return sqrt( Q_X(*q) * Q_X(*q) + Q_Y(*q) * Q_Y(*q) + Q_Z(*q) * Q_Z(*q) + Q_W(*q) * Q_W(*q) );
}

