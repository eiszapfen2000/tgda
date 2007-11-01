#include <math.h>

#include "Quaternion.h"

NpFreeList * NP_QUATERNION_FREELIST = NULL;

void npmath_quaternion_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_QUATERNION_FREELIST,Quaternion,512)
}

Quaternion * quat_alloc()
{
    return (Quaternion *)npfreenode_alloc(NP_QUATERNION_FREELIST);
}

Quaternion * quat_alloc_init()
{
    Quaternion * tmp = npfreenode_alloc(NP_QUATERNION_FREELIST);
    Q_X(*tmp) = Q_Y(*tmp) = Q_Z(*tmp) = 0.0;
    Q_W(*tmp) = 1.0;

    return tmp;
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

void quat_m3_to_quaternion_q(const Matrix3 * const m, Quaternion * q)
{
    Double trace = M_EL(*m,0,0) + M_EL(*m,1,1) + M_EL(*m,2,2) + 1.0;
    Double s;

    if ( trace > 0.0 )
    {
        s = 0.5 / sqrt(trace);

        Q_W(*q) = 0.25 / s;
        Q_X(*q) = ( M_EL(*m,1,2) - M_EL(*m,2,1) ) * s;
        Q_Y(*q) = ( M_EL(*m,2,0) - M_EL(*m,0,2) ) * s;
        Q_Z(*q) = ( M_EL(*m,0,1) - M_EL(*m,1,0) ) * s;

        return;
    }
    else
    {
        if ( M_EL(*m,0,0) > M_EL(*m,1,1) && M_EL(*m,0,0) > M_EL(*m,2,2) )
        {
            s = sqrt( 1.0 + M_EL(*m,0,0) - M_EL(*m,1,1) - M_EL(*m,2,2) ) * 2.0;
            Q_X(*q) = 0.5 / s;
            Q_Y(*q) = ( M_EL(*m,1,0) + M_EL(*m,0,1) ) / s;
            Q_Z(*q) = ( M_EL(*m,2,0) + M_EL(*m,0,2) ) / s;
            Q_W(*q) = ( M_EL(*m,2,1) + M_EL(*m,1,2) ) / s;

            return;
        }

        if ( M_EL(*m,1,1) > M_EL(*m,0,0) && M_EL(*m,1,1) > M_EL(*m,2,2) )
        {
            s = sqrt( 1.0 + M_EL(*m,1,1) - M_EL(*m,0,0) - M_EL(*m,2,2) ) * 2.0;
            Q_X(*q) = ( M_EL(*m,1,0) + M_EL(*m,0,1) ) / s; 
            Q_Y(*q) = 0.5 / s; 
            Q_Z(*q) = ( M_EL(*m,2,1) + M_EL(*m,1,2) ) / s;
            Q_W(*q) = ( M_EL(*m,2,0) + M_EL(*m,0,2) ) / s;

            return;
        }

        if ( M_EL(*m,2,2) > M_EL(*m,0,0) && M_EL(*m,2,2) > M_EL(*m,1,1) )
        {
            s = sqrt( 1.0 + M_EL(*m,2,2) - M_EL(*m,1,1) - M_EL(*m,0,0) ) * 2.0;
            Q_X(*q) = ( M_EL(*m,2,0) + M_EL(*m,0,2) ) / s;
            Q_Y(*q) = ( M_EL(*m,2,1) + M_EL(*m,1,2) ) / s;
            Q_Z(*q) = 0.5 / s;
            Q_W(*q) = ( M_EL(*m,1,0) + M_EL(*m,0,1) ) / s;

            return;
        }
    }
}

void quat_m4_to_quaternion_q(const Matrix4 * const m, Quaternion * q)
{
    Double trace = M_EL(*m,0,0) + M_EL(*m,1,1) + M_EL(*m,2,2) + 1.0;
    Double s;

    if ( trace > 0.0 )
    {
        s = 0.5 / sqrt(trace);

        Q_W(*q) = 0.25 / s;
        Q_X(*q) = ( M_EL(*m,1,2) - M_EL(*m,2,1) ) * s;
        Q_Y(*q) = ( M_EL(*m,2,0) - M_EL(*m,0,2) ) * s;
        Q_Z(*q) = ( M_EL(*m,0,1) - M_EL(*m,1,0) ) * s;

        return;
    }
    else
    {
        if ( M_EL(*m,0,0) > M_EL(*m,1,1) && M_EL(*m,0,0) > M_EL(*m,2,2) )
        {
            s = sqrt( 1.0 + M_EL(*m,0,0) - M_EL(*m,1,1) - M_EL(*m,2,2) ) * 2.0;
            Q_X(*q) = 0.5 / s;
            Q_Y(*q) = ( M_EL(*m,1,0) + M_EL(*m,0,1) ) / s;
            Q_Z(*q) = ( M_EL(*m,2,0) + M_EL(*m,0,2) ) / s;
            Q_W(*q) = ( M_EL(*m,2,1) + M_EL(*m,1,2) ) / s;

            return;
        }

        if ( M_EL(*m,1,1) > M_EL(*m,0,0) && M_EL(*m,1,1) > M_EL(*m,2,2) )
        {
            s = sqrt( 1.0 + M_EL(*m,1,1) - M_EL(*m,0,0) - M_EL(*m,2,2) ) * 2.0;
            Q_X(*q) = ( M_EL(*m,1,0) + M_EL(*m,0,1) ) / s; 
            Q_Y(*q) = 0.5 / s; 
            Q_Z(*q) = ( M_EL(*m,2,1) + M_EL(*m,1,2) ) / s;
            Q_W(*q) = ( M_EL(*m,2,0) + M_EL(*m,0,2) ) / s;

            return;
        }

        if ( M_EL(*m,2,2) > M_EL(*m,0,0) && M_EL(*m,2,2) > M_EL(*m,1,1) )
        {
            s = sqrt( 1.0 + M_EL(*m,2,2) - M_EL(*m,1,1) - M_EL(*m,0,0) ) * 2.0;
            Q_X(*q) = ( M_EL(*m,2,0) + M_EL(*m,0,2) ) / s;
            Q_Y(*q) = ( M_EL(*m,2,1) + M_EL(*m,1,2) ) / s;
            Q_Z(*q) = 0.5 / s;
            Q_W(*q) = ( M_EL(*m,1,0) + M_EL(*m,0,1) ) / s;

            return;
        }
    }
}

Double quat_q_magnitude(const Quaternion * const q)
{
    return sqrt( Q_X(*q) * Q_X(*q) + Q_Y(*q) * Q_Y(*q) + Q_Z(*q) * Q_Z(*q) + Q_W(*q) * Q_W(*q) );
}

