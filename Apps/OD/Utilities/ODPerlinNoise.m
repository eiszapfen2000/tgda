//#import "Core/Basics/NpMemory.h"
#import "ODPerlinNoise.h"
#import "NP.h"

@implementation ODPerlinNoise

- (id) init
{
    return [ self initWithName:@"OD Perlin Noise Generator" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    return [ self initWithName:newName parent:newParent size:16 ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent size:(Int)newSize
{
    self =  [ super initWithName:newName parent:newParent ];

    size = newSize;
    permutationTable = ALLOC_ARRAY(Byte,size);

    rng = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_TT800 ];

    for ( Int i = 0; i < size; i++ )
    {
        permutationTable[i] = i;
    }

    Int j, tmp;
    for ( Int i = 0; i < size; i++ )
    {
        j = (Int)[ rng nextUniformIntegerRandomNumber ] & (size - 1);

        tmp = permutationTable[i];
        permutationTable[i] = permutationTable[j];
        permutationTable[j] = tmp;
    }

    gradientX = ALLOC_ARRAY(Float,size);
    gradientY = ALLOC_ARRAY(Float,size);
    gradientZ = ALLOC_ARRAY(Float,size);

    for ( Int i = 0; i < size; i++ )
    {
        gradientX[i] = (Float)[ rng nextUniformIntegerRandomNumber ]/(Float)(PRNG_SAFE_MAX/2) - 1.0f;
        gradientY[i] = (Float)[ rng nextUniformIntegerRandomNumber ]/(Float)(PRNG_SAFE_MAX/2) - 1.0f;
        gradientZ[i] = (Float)[ rng nextUniformIntegerRandomNumber ]/(Float)(PRNG_SAFE_MAX/2) - 1.0f;
    }

    return self;
}

- (void) dealloc
{
    SAFE_FREE(gradientZ);
    SAFE_FREE(gradientY);
    SAFE_FREE(gradientX);

    SAFE_FREE(permutationTable);

    [ super dealloc ];
}

- (Float) noise1D:(Float)x
{
    Float floorx = floorf(x);
    Int qx0 = (Int)floorx;
    Int qx1 = qx0 + 1;
    Float tx0 = x - (Float)qx0;
    Float tx1 = tx0 - 1.0f;

    qx0 = qx0 & (size - 1);
    qx1 = qx1 & (size - 1);

    Float v0 = gradientX[qx0] * tx0;
    Float v1 = gradientX[qx1] * tx1;

    Float wx = (3.0f - 2.0f * tx0) * tx0 * tx0;
    Float v = v0 - wx * (v0 - v1);

    return v;
}

- (Float) noise2D:(FVector2)x
{
	// Compute what gradients to use
	Int qx0 = (Int)floorf(x.x);
	Int qx1 = qx0 + 1;
	Float tx0 = x.x - (Float)qx0;
	Float tx1 = tx0 - 1;

	Int qy0 = (Int)floorf(x.y);
	Int qy1 = qy0 + 1;
	Float ty0 = x.y - (Float)qy0;
	Float ty1 = ty0 - 1;

	// Make sure we don't come outside the lookup table
	qx0 = qx0 & (size - 1);
	qx1 = qx1 & (size - 1);

	qy0 = qy0 & (size - 1);
	qy1 = qy1 & (size - 1);

	// Permutate values to get pseudo randomly chosen gradients
	Int q00 = permutationTable[(qy0 + permutationTable[qx0]) & (size - 1)];
	Int q01 = permutationTable[(qy0 + permutationTable[qx1]) & (size - 1)];

	Int q10 = permutationTable[(qy1 + permutationTable[qx0]) & (size - 1)];
	Int q11 = permutationTable[(qy1 + permutationTable[qx1]) & (size - 1)];

	// Compute the dotproduct between the vectors and the gradients
	Float v00 = gradientX[q00]*tx0 + gradientY[q00]*ty0;
	Float v01 = gradientX[q01]*tx1 + gradientY[q01]*ty0;

	Float v10 = gradientX[q10]*tx0 + gradientY[q10]*ty1;
	Float v11 = gradientX[q11]*tx1 + gradientY[q11]*ty1;

	// Modulate with the weight function
	Float wx = (3.0f - 2.0f * tx0) * tx0 * tx0;
	Float v0 = v00 - wx * (v00 - v01);
	Float v1 = v10 - wx * (v10 - v11);

	Float wy = (3.0f - 2.0f * ty0) * ty0 * ty0;
	Float v = v0 - wy * (v0 - v1);

	return v;
}

- (Float) noise3D:(FVector3)x
{
	// Compute what gradients to use
	Int qx0 = (Int)floorf(x.x);
	Int qx1 = qx0 + 1;
	Float tx0 = x.x - (Float)qx0;
	Float tx1 = tx0 - 1;

	Int qy0 = (Int)floorf(x.y);
	Int qy1 = qy0 + 1;
	Float ty0 = x.y - (Float)qy0;
	Float ty1 = ty0 - 1;

	Int qz0 = (Int)floorf(x.z);
	Int qz1 = qz0 + 1;
	Float tz0 = x.z - (Float)qz0;
	Float tz1 = tz0 - 1;

	// Make sure we don't come outside the lookup table
	qx0 = qx0 & (size -1);
	qx1 = qx1 & (size -1);

	qy0 = qy0 & (size -1);
	qy1 = qy1 & (size -1);

	qz0 = qz0 & (size -1);
	qz1 = qz1 & (size -1);

	// Permutate values to get pseudo randomly chosen gradients
	Int q000 = permutationTable[(qz0 + permutationTable[(qy0 + permutationTable[qx0]) & (size -1)]) & (size -1)];
	Int q001 = permutationTable[(qz0 + permutationTable[(qy0 + permutationTable[qx1]) & (size -1)]) & (size -1)];

	Int q010 = permutationTable[(qz0 + permutationTable[(qy1 + permutationTable[qx0]) & (size -1)]) & (size -1)];
	Int q011 = permutationTable[(qz0 + permutationTable[(qy1 + permutationTable[qx1]) & (size -1)]) & (size -1)];

	Int q100 = permutationTable[(qz1 + permutationTable[(qy0 + permutationTable[qx0]) & (size -1)]) & (size -1)];
	Int q101 = permutationTable[(qz1 + permutationTable[(qy0 + permutationTable[qx1]) & (size -1)]) & (size -1)];

	Int q110 = permutationTable[(qz1 + permutationTable[(qy1 + permutationTable[qx0]) & (size -1)]) & (size -1)];
	Int q111 = permutationTable[(qz1 + permutationTable[(qy1 + permutationTable[qx1]) & (size -1)]) & (size -1)];

	// Compute the dotproduct between the vectors and the gradients
	Float v000 = gradientX[q000]*tx0 + gradientY[q000]*ty0 + gradientZ[q000]*tz0;
	Float v001 = gradientX[q001]*tx1 + gradientY[q001]*ty0 + gradientZ[q001]*tz0;  

	Float v010 = gradientX[q010]*tx0 + gradientY[q010]*ty1 + gradientZ[q010]*tz0;
	Float v011 = gradientX[q011]*tx1 + gradientY[q011]*ty1 + gradientZ[q011]*tz0;

	Float v100 = gradientX[q100]*tx0 + gradientY[q100]*ty0 + gradientZ[q100]*tz1;
	Float v101 = gradientX[q101]*tx1 + gradientY[q101]*ty0 + gradientZ[q101]*tz1;  

	Float v110 = gradientX[q110]*tx0 + gradientY[q110]*ty1 + gradientZ[q110]*tz1;
	Float v111 = gradientX[q111]*tx1 + gradientY[q111]*ty1 + gradientZ[q111]*tz1;

	// Modulate with the weight function
	Float wx = (3 - 2*tx0)*tx0*tx0;
	Float v00 = v000 - wx*(v000 - v001);
	Float v01 = v010 - wx*(v010 - v011);
	Float v10 = v100 - wx*(v100 - v101);
	Float v11 = v110 - wx*(v110 - v111);

	Float wy = (3 - 2*ty0)*ty0*ty0;
	Float v0 = v00 - wy*(v00 - v01);
	Float v1 = v10 - wy*(v10 - v11);

	Float wz = (3 - 2*tz0)*tz0*tz0;
	Float v = v0 - wz*(v0 - v1);

	return v;
}

@end
