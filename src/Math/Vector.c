#include "Vector.h"

#include <math.h>

Double v2_v_square_length(const Vector2 * const v)
{
    return ( V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) );
}

Double v3_v_square_length(const Vector3 * const v)
{
    return ( V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) + V_Z(*v) * V_Z(*v) );
}

Double v2_v_length(const Vector2 * const v)
{
    return sqrt(v2_v_square_length(v));
}

Double v3_v_length(const Vector3 * const v)
{
    return sqrt(v3_v_square_length(v));
}

void v2_v_normalise_v(const Vector2 * const v, Vector2 * normalised)
{
    Double length = v2_v_length(v);
    V_X(*normalised) = V_X(*v)/length;
    V_Y(*normalised) = V_Y(*v)/length;
}

void v3_v_normalise_v(const Vector3 * const v, Vector3 * normalised)
{
    Double length = v3_v_length(v);
    V_X(*normalised) = V_X(*v)/length;
    V_Y(*normalised) = V_Y(*v)/length;
    V_Z(*normalised) = V_Z(*v)/length;
}

void v2_v_normalise(Vector2 * v)
{
    Double length = v2_v_length(v);
    V_X(*v) = V_X(*v)/length;
    V_Y(*v) = V_Y(*v)/length;
}

void v3_v_normalise(Vector3 * v)
{
    Double length = v3_v_length(v);
    V_X(*v) = V_X(*v)/length;
    V_Y(*v) = V_Y(*v)/length;
    V_Z(*v) = V_Z(*v)/length;
}

Double v2_vv_dot_product(const Vector2 * const v, const Vector2 * const w)
{
    return ( V_X(*v) * V_X(*w) + V_Y(*v) * V_Y(*w) );
}

Double v3_vv_dot_product(const Vector3 * const v, const Vector3 * const w)
{
    return ( V_X(*v) * V_X(*w) + V_Y(*v) * V_Y(*w) + V_Z(*v) * V_Z(*w) );
}

void v3_vv_cross_product_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result)
{
    V_X(*result) = V_Y(*v) * V_Z(*w) - V_Z(*v) * V_Y(*w);
    V_Y(*result) = V_Z(*v) * V_X(*w) - V_X(*v) * V_Z(*w);
    V_Z(*result) = V_X(*v) * V_Y(*w) - V_Y(*v) * V_X(*w);
}

void v2_vv_add_v(const Vector2 * const v, const Vector2 * const w, Vector2 * result)
{
    V_X(*result) = V_X(*v) + V_X(*w);
    V_Y(*result) = V_Y(*v) + V_Y(*w);
}

void v3_vv_add_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result)
{
    V_X(*result) = V_X(*v) + V_X(*w);
    V_Y(*result) = V_Y(*v) + V_Y(*w);
    V_Z(*result) = V_Z(*v) + V_Z(*w);
}

void v2_vv_sub_v(const Vector2 * const v, const Vector2 * const w, Vector2 * result)
{
    V_X(*result) = V_X(*v) - V_X(*w);
    V_Y(*result) = V_Y(*v) - V_Y(*w);
}

void v3_vv_sub_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result)
{
    V_X(*result) = V_X(*v) - V_X(*w);
    V_Y(*result) = V_Y(*v) - V_Y(*w);
    V_Z(*result) = V_Z(*v) - V_Z(*w);
}

