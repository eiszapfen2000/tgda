#define _GNU_SOURCE
#include <stdio.h>
#include <math.h>

#include "Quaternion.h"
#include "Utilities.h"

NpFreeList * NP_QUATERNION_FREELIST = NULL;

void npmath_quaternion_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_QUATERNION_FREELIST, Quaternion, 512)
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

Quaternion * quat_alloc_init_with_axis_and_degrees(Vector3 * axis, Double * degrees)
{
    Quaternion * q = quat_alloc();
    quat_q_init_with_axis_and_degrees(q, axis, degrees);

    return q;
}

Quaternion * quat_alloc_init_with_axis_and_radians(Vector3 * axis, Double * radians)
{
    Quaternion * q = quat_alloc();
    quat_q_init_with_axis_and_radians(q, axis, radians);

    return q;
}

Quaternion * quat_free(Quaternion * q)
{
    return npfreenode_free(q, NP_QUATERNION_FREELIST);
}

void quat_set_identity(Quaternion * q)
{
    Q_X(*q) = Q_Y(*q) = Q_Z(*q) = 0.0;
    Q_W(*q) = 1.0;
}

void quat_q_init_with_axis_and_degrees(Quaternion * q, Vector3 * axis, Double * degrees)
{
    Double angle = DEGREE_TO_RADIANS(*degrees);
    Double sin_angle = sin(angle / 2.0);
    Double cos_angle = cos(angle / 2.0);

    Vector3 tmp;

    if ( v3_v_length(axis) != 1.0 )
    {
        v3_v_normalise_v(axis, &tmp);
    }
    else
    {
        tmp = *axis;
    }

    Q_X(*q) = V_X(tmp) * sin_angle;
    Q_Y(*q) = V_Y(tmp) * sin_angle;
    Q_Z(*q) = V_Z(tmp) * sin_angle;
    Q_W(*q) = cos_angle;

    quat_q_normalise(q);
}

void quat_q_init_with_axis_and_radians(Quaternion * q, Vector3 * axis, Double * radians)
{
    Double sin_angle = sin((*radians) / 2.0);
    Double cos_angle = cos((*radians) / 2.0);

    Vector3 tmp;

    if ( v3_v_length(axis) != 1.0 )
    {
        v3_v_normalise_v(axis, &tmp);
    }
    else
    {
        tmp = *axis;
    }

    Q_X(*q) = V_X(tmp) * sin_angle;
    Q_Y(*q) = V_Y(tmp) * sin_angle;
    Q_Z(*q) = V_Z(tmp) * sin_angle;
    Q_W(*q) = cos_angle;

    quat_q_normalise(q);
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
    Q_X(*result) = Q_W(*q1) * Q_X(*q2) + Q_X(*q1) * Q_W(*q2) + Q_Y(*q1) * Q_Z(*q2) - Q_Z(*q1) * Q_Y(*q2);
    Q_Y(*result) = Q_W(*q1) * Q_Y(*q2) - Q_X(*q1) * Q_Z(*q2) + Q_Y(*q1) * Q_W(*q2) + Q_Z(*q1) * Q_X(*q2);
    Q_Z(*result) = Q_W(*q1) * Q_Z(*q2) + Q_X(*q1) * Q_Y(*q2) - Q_Y(*q1) * Q_X(*q2) + Q_Z(*q1) * Q_W(*q2);
    Q_W(*result) = Q_W(*q1) * Q_W(*q2) - Q_X(*q1) * Q_X(*q2) - Q_Y(*q1) * Q_Y(*q2) - Q_Z(*q1) * Q_Z(*q2);

    quat_q_normalise(result);
}

void quat_qv_multiply_v(const Quaternion * const q, const Vector3 * const v, Vector3 * result)
{
	V_X(*result) = Q_W(*q) * Q_W(*q) * V_X(*v) + 2 * Q_Y(*q) * Q_W(*q) * V_Z(*v)
                   - 2 * Q_Z(*q) * Q_W(*q) * V_Y(*v) + Q_X(*q) * Q_X(*q) * V_X(*v) + 2 * Q_Y(*q) * Q_X(*q) * V_Y(*v)
                   + 2 * Q_Z(*q) * Q_X(*q) * V_Z(*v) - Q_Z(*q) * Q_Z(*q) * V_X(*v) - Q_Y(*q) * Q_Y(*q) * V_X(*v);
	V_Y(*result) = 2 * Q_X(*q) * Q_Y(*q) * V_X(*v) + Q_Y(*q) * Q_Y(*q) * V_Y(*v)
                   + 2 * Q_Z(*q) * Q_Y(*q) * V_Z(*v) + 2 * Q_W(*q) * Q_Z(*q) * V_X(*v) - Q_Z(*q) * Q_Z(*q) * V_Y(*v)
                   + Q_W(*q) * Q_W(*q) * V_Y(*v) - 2 * Q_X(*q) * Q_W(*q) * V_Z(*v) - Q_X(*q) * Q_X(*q) * V_Y(*v);
	V_Z(*result) = 2 * Q_X(*q) * Q_Z(*q) * V_X(*v) + 2 * Q_Y(*q) * Q_Z(*q) * V_Y(*v)
                   + Q_Z(*q) * Q_Z(*q) * V_Z(*v) - 2 * Q_W(*q) * Q_Y(*q) * V_X(*v) - Q_Y(*q) * Q_Y(*q) * V_Z(*v)
                   + 2 * Q_W(*q) * Q_X(*q) * V_Y(*v) - Q_X(*q) * Q_X(*q) * V_Z(*v) + Q_W(*q) * Q_W(*q) * V_Z(*v);
}

void quat_q_rotatex(Quaternion * q, Double * degrees)
{
    Quaternion rotatex;
    quat_q_init_with_axis_and_degrees(&rotatex, NP_WORLD_X_AXIS, degrees);
    Quaternion tmp = *q;
    quat_qq_multiply_q(&tmp, &rotatex, q);
}

void quat_q_rotatey(Quaternion * q, Double * degrees)
{
    Quaternion rotatey;
    quat_q_init_with_axis_and_degrees(&rotatey, NP_WORLD_Y_AXIS, degrees);
    Quaternion tmp = *q;
    quat_qq_multiply_q(&tmp, &rotatey, q);
}

void quat_q_rotatez(Quaternion * q, Double * degrees)
{
    Quaternion rotatez;
    quat_q_init_with_axis_and_degrees(&rotatez, NP_WORLD_Z_AXIS, degrees);
    Quaternion tmp = *q;
    quat_qq_multiply_q(&tmp, &rotatez, q);
}

void quat_q_forward_vector_v(Quaternion * q, Vector3 * v)
{
    quat_qv_multiply_v(q, NP_WORLD_FORWARD_VECTOR, v);
}

void quat_q_up_vector_v(Quaternion * q, Vector3 * v)
{
    quat_qv_multiply_v(q, NP_WORLD_Y_AXIS, v);
}

void quat_q_right_vector_v(Quaternion * q, Vector3 * v)
{
    quat_qv_multiply_v(q, NP_WORLD_X_AXIS, v);
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

void quat_q_to_fmatrix3_m(const Quaternion * const q, FMatrix3 * m)
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

void quat_q_to_fmatrix4_m(const Quaternion * const q, FMatrix4 * m)
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

Quaternion quat_q_conjugated(const Quaternion * const q)
{
    return (Quaternion){{ -Q_X(*q), -Q_Y(*q), -Q_Z(*q) }, Q_W(*q) };
}

Quaternion quat_q_normalised(const Quaternion * const q)
{
    Double magnitude = quat_q_magnitude(q);

    return (Quaternion){{ Q_X(*q) / magnitude, Q_Y(*q) / magnitude, Q_Z(*q) / magnitude }, Q_W(*q) / magnitude };
}


Quaternion quat_qq_multiply(const Quaternion * const q1, const Quaternion * const q2)
{
    Quaternion result;
    quat_qq_multiply_q(q1, q2, &result);

    return result;
}

Vector3 quat_qv_multiply(const Quaternion * const q, const Vector3 * const v)
{
    Vector3 result;
    quat_qv_multiply_v(q, v, &result);

    return result;
}

Vector3 quat_q_forward_vector(const Quaternion * const q)
{
    Vector3 forwardVector;
    quat_qv_multiply_v(q, NP_WORLD_FORWARD_VECTOR, &forwardVector);

    return forwardVector;
}

Vector3 quat_q_up_vector(const Quaternion * const q)
{
    Vector3 upVector;
    quat_qv_multiply_v(q, NP_WORLD_Y_AXIS, &upVector);

    return upVector;
}

Vector3 quat_q_right_vector(const Quaternion * const q)
{
    Vector3 rightVector;
    quat_qv_multiply_v(q, NP_WORLD_X_AXIS, &rightVector);

    return rightVector;
}

Matrix3 quat_q_to_matrix3(const Quaternion * const q)
{
    Matrix3 result;
    quat_q_to_matrix3_m(q, &result);

    return result;
}

FMatrix3 quat_q_to_fmatrix3(const Quaternion * const q)
{
    FMatrix3 result;
    quat_q_to_fmatrix3_m(q, &result);

    return result;    
}

Matrix4 quat_q_to_matrix4(const Quaternion * const q)
{
    Matrix4 result;
    quat_q_to_matrix4_m(q, &result);

    return result;    
}

FMatrix4 quat_q_to_fmatrix4(const Quaternion * const q)
{
    FMatrix4 result;
    quat_q_to_fmatrix4_m(q, &result);

    return result;    
}

Quaternion quat_m3_to_quaternion(const Matrix3 * const m)
{
    Quaternion result;
    quat_m3_to_quaternion_q(m, &result);

    return result;
}

Quaternion quat_m4_to_quaternion(const Matrix4 * const m)
{
    Quaternion result;
    quat_m4_to_quaternion_q(m, &result);

    return result;
}

const char * quat_q_to_string(Quaternion * q)
{
    char * quatstring;

    if ( asprintf(&quatstring, "%f %f %f %f\n", Q_X(*q), Q_Y(*q), Q_Z(*q), Q_W(*q)) < 0 )
    {
        return NULL;
    }

    return quatstring;
}

