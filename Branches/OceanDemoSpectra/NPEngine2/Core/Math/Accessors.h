#ifndef _NP_MATH_ACCESSORS_H_
#define _NP_MATH_ACCESSORS_H_

#define VECTOR_X(_v)    (_v).x
#define VECTOR_Y(_v)    (_v).y
#define VECTOR_Z(_v)    (_v).z
#define VECTOR_W(_v)    (_v).w

#define V_X VECTOR_X
#define V_Y VECTOR_Y
#define V_Z VECTOR_Z
#define V_W VECTOR_W

#define QUATERNION_V(_q)    (_q).v
#define QUATERNION_X(_q)    (_q).v.x
#define QUATERNION_Y(_q)    (_q).v.y
#define QUATERNION_Z(_q)    (_q).v.z
#define QUATERNION_W(_q)    (_q).w

#define Q_V QUATERNION_V
#define Q_X QUATERNION_X
#define Q_Y QUATERNION_Y
#define Q_Z QUATERNION_Z
#define Q_W QUATERNION_W

#define M_ELEMENTS(_m)            (_m).elements
#define M_ELEMENT(_m, _col, _row) (_m).elements[(_col)][(_row)]
#define M_EL                       M_ELEMENT

#endif
