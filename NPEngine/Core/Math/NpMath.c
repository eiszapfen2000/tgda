#include "NpMath.h"

void npmath_initialise()
{
    npmath_fmatrix_initialise();
    npmath_fquaternion_initialise();
    npmath_fvector_initialise();

    npmath_matrix_initialise();
    npmath_quaternion_initialise();
    npmath_vector_initialise();

    npmath_ivector_initialise();

    npmath_plane_initialise();
    npmath_fplane_initialise();
    npmath_ray_initialise();
    npmath_fray_initialise();

    npmath_frectangle_initialise();
}
