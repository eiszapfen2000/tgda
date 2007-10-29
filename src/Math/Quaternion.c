#include "Quaternion.h"

#include <math.h>

void quat_q_conjugate(Quaternion * q)
{
    Q_X(*q) = -Q_X(*q);
    Q_Y(*q) = -Q_Y(*q);
    Q_Z(*q) = -Q_Z(*q);
}

void quat_q_conjugate_q(Quaternion * q, Quaternion * conjugate)
{
    Q_X(*conjugate) = -Q_X(*q);
    Q_Y(*conjugate) = -Q_Y(*q);
    Q_Z(*conjugate) = -Q_Z(*q);
    Q_W(*conjugate) =  Q_W(*q);
}

Double quat_q_magnitude(Quaternion * q)
{
    return sqrt( Q_X(*q) * Q_X(*q) + Q_Y(*q) * Q_Y(*q) + Q_Z(*q) * Q_Z(*q) + Q_W(*q) * Q_W(*q) );
}

void quat_q_magnitude_s(Quaternion * q, Double * magnitude)
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

void quat_q_normalise_q(Quaternion * q, Quaternion * normalised)
{
    Double magnitude = quat_q_magnitude(q);

    Q_X(*normalised) = Q_X(*q)/magnitude;
    Q_Y(*normalised) = Q_Y(*q)/magnitude;
    Q_Z(*normalised) = Q_Z(*q)/magnitude;
    Q_W(*normalised) = Q_W(*q)/magnitude;
}

void quat_qq_multiply_q(Quaternion * q1, Quaternion * q2, Quaternion * result)
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

