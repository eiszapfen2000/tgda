#define _GNU_SOURCE
#include <stdio.h>
#include <math.h>
#include <float.h>

#include "Core/Basics/NpFreeList.h"
#include "FQuaternion.h"
#include "Utilities.h"

NpFreeList * NP_FQUATERNION_FREELIST = NULL;

void npmath_fquaternion_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_FQUATERNION_FREELIST, FQuaternion, 512)
}

FQuaternion * fquat_alloc()
{
    return (FQuaternion *)npfreenode_alloc(NP_FQUATERNION_FREELIST);
}

FQuaternion * fquat_alloc_init()
{
    FQuaternion * tmp = npfreenode_alloc(NP_FQUATERNION_FREELIST);
    Q_X(*tmp) = Q_Y(*tmp) = Q_Z(*tmp) = 0.0f;
    Q_W(*tmp) = 1.0f;

    return tmp;
}

FQuaternion * fquat_alloc_init_with_axis_and_degrees(const FVector3 * axis, const Float degrees)
{
    FQuaternion * q = fquat_alloc();
    fquat_q_init_with_axis_and_degrees(q, axis, degrees);

    return q;
}

FQuaternion * fquat_alloc_init_with_axis_and_radians(const FVector3 * axis, const Float radians)
{
    FQuaternion * q = fquat_alloc();
    fquat_q_init_with_axis_and_radians(q, axis, radians);

    return q;
}

FQuaternion * fquat_free(FQuaternion * q)
{
    return npfreenode_free(q, NP_FQUATERNION_FREELIST);
}

void fquat_set_identity(FQuaternion * q)
{
    Q_X(*q) = Q_Y(*q) = Q_Z(*q) = 0.0;
    Q_W(*q) = 1.0;
}

void fquat_q_init_with_axis_and_degrees(FQuaternion * q, const FVector3 * axis, const Float degrees)
{
    Float angle = DEGREE_TO_RADIANS(degrees);
    Float sin_angle = sin(angle / 2.0);
    Float cos_angle = cos(angle / 2.0);

    FVector3 tmp;

    if ( fv3_v_length(axis) != 1.0f )
    {
        fv3_v_normalise_v(axis, &tmp);
    }
    else
    {
        tmp = *axis;
    }

    Q_X(*q) = V_X(tmp) * sin_angle;
    Q_Y(*q) = V_Y(tmp) * sin_angle;
    Q_Z(*q) = V_Z(tmp) * sin_angle;
    Q_W(*q) = cos_angle;

    fquat_q_normalise(q);
}

void fquat_q_init_with_axis_and_radians(FQuaternion * q, const FVector3 * axis, const Float radians)
{
    Float sin_angle = sin(radians / 2.0);
    Float cos_angle = cos(radians / 2.0);

    FVector3 tmp;

    if ( fv3_v_length(axis) != 1.0f )
    {
        fv3_v_normalise_v(axis, &tmp);
    }
    else
    {
        tmp = *axis;
    }

    Q_X(*q) = V_X(tmp) * sin_angle;
    Q_Y(*q) = V_Y(tmp) * sin_angle;
    Q_Z(*q) = V_Z(tmp) * sin_angle;
    Q_W(*q) = cos_angle;

    fquat_q_normalise(q);
}

Float fquat_q_magnitude(const FQuaternion * q)
{
    return sqrt( Q_X(*q) * Q_X(*q) + Q_Y(*q) * Q_Y(*q) + Q_Z(*q) * Q_Z(*q) + Q_W(*q) * Q_W(*q) );
}

void fquat_q_conjugate(FQuaternion * q)
{
    Q_X(*q) = -Q_X(*q);
    Q_Y(*q) = -Q_Y(*q);
    Q_Z(*q) = -Q_Z(*q);
}

void fquat_q_conjugate_q(const FQuaternion * restrict q, FQuaternion * restrict conjugate)
{
    Q_X(*conjugate) = -Q_X(*q);
    Q_Y(*conjugate) = -Q_Y(*q);
    Q_Z(*conjugate) = -Q_Z(*q);
    Q_W(*conjugate) =  Q_W(*q);
}



void fquat_q_normalise(FQuaternion * q)
{
    const Float magnitude = fquat_q_magnitude(q);

    Q_X(*q) /= magnitude;
    Q_Y(*q) /= magnitude;
    Q_Z(*q) /= magnitude;
    Q_W(*q) /= magnitude;
}

void fquat_q_normalise_q(const FQuaternion * restrict q, FQuaternion * restrict normalised)
{
    const Float magnitude = fquat_q_magnitude(q);

    Q_X(*normalised) = Q_X(*q)/magnitude;
    Q_Y(*normalised) = Q_Y(*q)/magnitude;
    Q_Z(*normalised) = Q_Z(*q)/magnitude;
    Q_W(*normalised) = Q_W(*q)/magnitude;
}

void fquat_qq_multiply_q(const FQuaternion * restrict q1, const FQuaternion * restrict q2, FQuaternion * restrict result)
{
    Q_X(*result) = Q_W(*q1) * Q_X(*q2) + Q_X(*q1) * Q_W(*q2) + Q_Y(*q1) * Q_Z(*q2) - Q_Z(*q1) * Q_Y(*q2);
    Q_Y(*result) = Q_W(*q1) * Q_Y(*q2) - Q_X(*q1) * Q_Z(*q2) + Q_Y(*q1) * Q_W(*q2) + Q_Z(*q1) * Q_X(*q2);
    Q_Z(*result) = Q_W(*q1) * Q_Z(*q2) + Q_X(*q1) * Q_Y(*q2) - Q_Y(*q1) * Q_X(*q2) + Q_Z(*q1) * Q_W(*q2);
    Q_W(*result) = Q_W(*q1) * Q_W(*q2) - Q_X(*q1) * Q_X(*q2) - Q_Y(*q1) * Q_Y(*q2) - Q_Z(*q1) * Q_Z(*q2);

    fquat_q_normalise(result);
}

void fquat_qv_multiply_v(const FQuaternion * const q, const FVector3 * restrict v, FVector3 * restrict result)
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


void fquat_q_rotatex(FQuaternion * q, const Float degrees)
{
    FQuaternion rotatex;
    fquat_q_init_with_axis_and_degrees(&rotatex, NP_WORLDF_X_AXIS, degrees);
    FQuaternion tmp = *q;
    fquat_qq_multiply_q(&tmp, &rotatex, q);
}

void fquat_q_rotatey(FQuaternion * q, const Float degrees)
{
    FQuaternion rotatey;
    fquat_q_init_with_axis_and_degrees(&rotatey, NP_WORLDF_Y_AXIS, degrees);
    FQuaternion tmp = *q;
    fquat_qq_multiply_q(&tmp, &rotatey, q);
}

void fquat_q_rotatez(FQuaternion * q, const Float degrees)
{
    FQuaternion rotatez;
    fquat_q_init_with_axis_and_degrees(&rotatez, NP_WORLDF_Z_AXIS, degrees);
    FQuaternion tmp = *q;
    fquat_qq_multiply_q(&tmp, &rotatez, q);
}

void fquat_q_forward_vector_v(const FQuaternion * q, FVector3 * v)
{
    fquat_qv_multiply_v(q, NP_WORLDF_FORWARD_VECTOR, v);
}

void fquat_q_up_vector_v(const FQuaternion * q, FVector3 * v)
{
    fquat_qv_multiply_v(q, NP_WORLDF_Y_AXIS, v);
}

void fquat_q_right_vector_v(const FQuaternion * q, FVector3 * v)
{
    fquat_qv_multiply_v(q, NP_WORLDF_X_AXIS, v);
}

void fquat_q_to_matrix3_m(const FQuaternion * q, Matrix3 * m)
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

void fquat_q_to_fmatrix3_m(const FQuaternion * q, FMatrix3 * m)
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

void fquat_q_to_matrix4_m(const FQuaternion * q, Matrix4 * m)
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

void fquat_q_to_fmatrix4_m(const FQuaternion * q, FMatrix4 * m)
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

void fquat_m3_to_quaternion_q(const FMatrix3 * m, FQuaternion * q)
{
    Float trace = M_EL(*m,0,0) + M_EL(*m,1,1) + M_EL(*m,2,2) + 1.0;
    Float s;

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

void fquat_m4_to_quaternion_q(const FMatrix4 * m, FQuaternion * q)
{
    Float trace = M_EL(*m,0,0) + M_EL(*m,1,1) + M_EL(*m,2,2) + 1.0;
    Float s;

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

void fquat_qqs_slerp_q(const FQuaternion * const q1, const FQuaternion * const q2, const float u, FQuaternion * result)
{
    //http://libcinder.org/docs/v0.8.2/_quaternion_8h_source.html

    const double cosAngle
        = q1->w * q2->w + q1->v.x * q2->v.x + q1->v.y * q2->v.y + q1->v.z * q2->v.z;

    double q1Scale;
    double q2Scale;

    if ( cosAngle >= DBL_EPSILON )
    {
        if (( 1.0 - cosAngle ) > DBL_EPSILON )
        {
            const double sinAngle = sqrt(1.0 - cosAngle * cosAngle);
            const double angle = atan2(sinAngle, cosAngle);
            const double rSinAngle = 1.0 / sinAngle;

            q1Scale = sin(angle * (1.0 - u)) * rSinAngle;
            q2Scale = sin(angle * u) * rSinAngle;
        }
        else
        {
            q1Scale = 1.0 - u;
            q2Scale = u;
        }
    }
    else
    {
        if (( 1.0 + cosAngle ) > DBL_EPSILON )
        {
            const double sinAngle = sqrt(1.0 - cosAngle * cosAngle);
            const double angle = atan2(sinAngle, -cosAngle);
            const double rSinAngle = 1.0 / sinAngle;

            q1Scale = sin(angle * (u - 1.0)) * rSinAngle;
            q2Scale = sin(angle * u) * rSinAngle;
        }
        else
        {
            q1Scale = u - 1.0;
            q2Scale = u;
        }
    }

    result->v.x = q1->v.x * q1Scale + q2->v.x * q2Scale;
    result->v.y = q1->v.y * q1Scale + q2->v.y * q2Scale;
    result->v.z = q1->v.z * q1Scale + q2->v.z * q2Scale;
    result->w   = q1->w   * q1Scale + q2->w   * q2Scale;
}

FQuaternion fquat_q_conjugated(const FQuaternion * q)
{
    return (FQuaternion){{ -Q_X(*q), -Q_Y(*q), -Q_Z(*q) }, Q_W(*q) };
}

FQuaternion fquat_q_normalised(const FQuaternion * q)
{
    const Float magnitude = fquat_q_magnitude(q);

    return (FQuaternion){{ Q_X(*q) / magnitude, Q_Y(*q) / magnitude, Q_Z(*q) / magnitude }, Q_W(*q) / magnitude };
}

FQuaternion fquat_qq_multiply(const FQuaternion * restrict q1, const FQuaternion * restrict q2)
{
    FQuaternion result;
    fquat_qq_multiply_q(q1, q2, &result);

    return result;
}

FVector3 fquat_qv_multiply(const FQuaternion * q, const FVector3 * v)
{
    FVector3 result;
    fquat_qv_multiply_v(q, v, &result);

    return result;
}

FVector3 fquat_q_forward_vector(const FQuaternion * q)
{
    FVector3 forwardVector;
    fquat_qv_multiply_v(q, NP_WORLDF_FORWARD_VECTOR, &forwardVector);

    return forwardVector;
}

FVector3 fquat_q_up_vector(const FQuaternion * q)
{
    FVector3 upVector;
    fquat_qv_multiply_v(q, NP_WORLDF_Y_AXIS, &upVector);

    return upVector;
}

FVector3 fquat_q_right_vector(const FQuaternion * q)
{
    FVector3 rightVector;
    fquat_qv_multiply_v(q, NP_WORLDF_X_AXIS, &rightVector);

    return rightVector;
}

Matrix3 fquat_q_to_matrix3(const FQuaternion * q)
{
    Matrix3 result;
    fquat_q_to_matrix3_m(q, &result);

    return result;
}

FMatrix3 fquat_q_to_fmatrix3(const FQuaternion * q)
{
    FMatrix3 result;
    fquat_q_to_fmatrix3_m(q, &result);

    return result;    
}

Matrix4 fquat_q_to_matrix4(const FQuaternion * q)
{
    Matrix4 result;
    fquat_q_to_matrix4_m(q, &result);

    return result;    
}

FMatrix4 fquat_q_to_fmatrix4(const FQuaternion * q)
{
    FMatrix4 result;
    fquat_q_to_fmatrix4_m(q, &result);

    return result;    
}

FQuaternion fquat_m3_to_quaternion(const FMatrix3 * m)
{
    FQuaternion result;
    fquat_m3_to_quaternion_q(m, &result);

    return result;
}

FQuaternion fquat_m4_to_quaternion(const FMatrix4 * m)
{
    FQuaternion result;
    fquat_m4_to_quaternion_q(m, &result);

    return result;
}

const char * fquat_q_to_string(const FQuaternion * q)
{
    char * fquatstring;

    if ( asprintf(&fquatstring, "%f %f %f %f\n", Q_X(*q), Q_Y(*q), Q_Z(*q), Q_W(*q)) < 0 )
    {
        return NULL;
    }

    return fquatstring;
}

