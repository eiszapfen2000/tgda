#include <string.h>
#include "NpHalf.h"

//---------------------------------------------------
// Interpret an unsigned short bit pattern as a half,
// and convert that half to the corresponding float's
// bit pattern.
//---------------------------------------------------

float half_to_float(Half h)
{
    float fResult;

    uint32_t s = (h >> 15) & 0x00000001;
    uint32_t e = (h >> 10) & 0x0000001f;
    uint32_t m =  h        & 0x000003ff;

    if (e == 0)
    {
	    if (m == 0)
	    {
	        //
	        // Plus or minus zero
	        //
            uint32_t result = s << 31;

            memcpy(&fResult, &result, sizeof(float));
	        return fResult;
	    }
	    else
	    {
	        //
	        // Denormalized number -- renormalize it
	        //

	        while (!(m & 0x00000400u))
	        {
		        m <<= 1;
		        e -=  1;
	        }

	        e += 1;
	        m &= ~0x00000400u;
	    }
    }
    else if (e == 31)
    {
	    if (m == 0)
	    {
	        //
	        // Positive or negative infinity
	        //

            uint32_t result = (s << 31) | 0x7f800000u;

            memcpy(&fResult, &result, sizeof(float));
	        return fResult;
	    }
	    else
	    {
	        //
	        // Nan -- preserve sign and significand bits
	        //

            uint32_t result = (s << 31) | 0x7f800000u | (m << 13);

            memcpy(&fResult, &result, sizeof(float));
	        return fResult;
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
    uint32_t result = (s << 31) | (e << 23) | m;

    // Avoid strict aliasing issues
    memcpy(&fResult, &result, sizeof(float));

    return fResult;
}
