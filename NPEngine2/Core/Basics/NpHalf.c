#include <string.h>
#include "NpHalf.h"

//---------------------------------------------------
// Interpret an unsigned short bit pattern as a half,
// and convert that half to the corresponding float's
// bit pattern.
//---------------------------------------------------

float half_to_float(Half h)
{
    int s = (h >> 15) & 0x00000001;
    int e = (h >> 10) & 0x0000001f;
    int m =  h        & 0x000003ff;

    if (e == 0)
    {
	    if (m == 0)
	    {
	        //
	        // Plus or minus zero
	        //

	        return s << 31;
	    }
	    else
	    {
	        //
	        // Denormalized number -- renormalize it
	        //

	        while (!(m & 0x00000400))
	        {
		        m <<= 1;
		        e -=  1;
	        }

	        e += 1;
	        m &= ~0x00000400;
	    }
    }
    else if (e == 31)
    {
	    if (m == 0)
	    {
	        //
	        // Positive or negative infinity
	        //

	        return (s << 31) | 0x7f800000;
	    }
	    else
	    {
	        //
	        // Nan -- preserve sign and significand bits
	        //

	        return (s << 31) | 0x7f800000 | (m << 13);
	    }
    }

    //
    // Normalized number
    //

    e = e + (127 - 15);
    m = m << 13;

    //
    // Assemble s, e and m.
    //
    float fResult;
    uint32_t result = (s << 31) | (e << 23) | m;

    // Avoid strict aliasing issues
    memcpy(&fResult, &result, sizeof(float));

    return fResult;
}
