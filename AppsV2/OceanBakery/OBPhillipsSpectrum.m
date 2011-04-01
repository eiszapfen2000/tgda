#import "OBPhillipsSpectrum.h"
#import "NP.h"

#define FFTWF_FREE(_pointer)        do {void *_ptr=(void *)(_pointer); fftwf_free(_ptr); _ptr=NULL; } while (0)
#define FFTWF_SAFE_FREE(_pointer)   { if ( (_pointer) != NULL ) FFTWF_FREE((_pointer)); }

@implementation OBPhillipsSpectrum

- (id) init
{
    return [ self initWithName:@"Phillips Spectrum" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    alpha = PHILLIPS_CONSTANT;

    resolution    = iv2_alloc_init();
    size          = fv2_alloc_init();
    windDirection = fv2_alloc_init();

    needsUpdate = YES;
    lastTime = -1.0;

    gaussianRNG = nil;
    H0 = NULL;
    frequencySpectrum = NULL;

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(gaussianRNG);

    FFTWF_SAFE_FREE(frequencySpectrum);
    FFTWF_SAFE_FREE(H0);

    fv2_free(size);
    iv2_free(resolution);
    fv2_free(windDirection);

    [ super dealloc ];
}

- (fftwf_complex *) frequencySpectrum
{
    return frequencySpectrum;
}

- (void) setSize:(FVector2 *)newSize
{
    if ( newSize->x > 0.0f && newSize->y > 0.0f )
    {
        size->x = newSize->x;
        size->y = newSize->y;

        needsUpdate = YES;
    }
}

- (void) setResolution:(IVector2 *)newResolution
{
    if ( newResolution->x > 0 && newResolution->y > 0 )
    {
        resolution->x = newResolution->x;
        resolution->y = newResolution->y;

        needsUpdate = YES;
    }
}

- (void) setWindDirection:(FVector2 *)newWindDirection
{
    windDirection->x = newWindDirection->x;
    windDirection->y = newWindDirection->y;

    needsUpdate = YES;
}

- (void) setGaussianRNG:(id)newGaussianRNG
{
    ASSIGN(gaussianRNG,newGaussianRNG);

    needsUpdate = YES;
}

- (Float) omegaForK:(FVector2 *)k
{
    return (Float)sqrt(EARTH_ACCELERATION * fv2_v_length(k));
}

- (Float) indexToKx:(Int)index
{
    Float n = -(resolution->x / 2.0f);
    n = n + (Float)index;

    return (MATH_2_MUL_PI * n) / size->x;
}

- (Float) indexToKy:(Int)index
{
    Float m = (resolution->y / 2.0f);
    m = m - (Float)index;

    return (MATH_2_MUL_PI * m) / size->y;
}

- (Float) getAmplitudeAt:(FVector2 *)k
{
    Float kSquareLength = fv2_v_square_length(k);

    if ( kSquareLength == 0.0f )
    {
        return 0.0f;
    }

    Float windDirectionSquareLength = fv2_v_square_length(windDirection);

    FVector2 windDirectionNormalised;
    fv2_v_normalise_v(windDirection, &windDirectionNormalised);

    FVector2 kNormalised;
    fv2_v_normalise_v(k, &kNormalised);

    Float L = windDirectionSquareLength / EARTH_ACCELERATION;

    Float amplitude = PHILLIPS_CONSTANT;
    amplitude = amplitude * ( 1.0f / (kSquareLength * kSquareLength) );
    amplitude = amplitude * (Float)exp( -1.0 / (Double)(kSquareLength * L * L) );

    Float kdotw = fv2_vv_dot_product(&kNormalised, &windDirectionNormalised);
    amplitude = amplitude * (Float)pow((Double)kdotw, 2.0);

    return amplitude;
}

- (void) generateH0
{
    Float xi_r, xi_i, a;
    FVector2 k;

	if ( needsUpdate == YES )
	{
        FFTWF_SAFE_FREE(H0);

		H0 = fftwf_malloc(sizeof(fftwf_complex) * resolution->x * resolution->y);

        for ( Int i = 0; i < resolution->x; i++ )
        {
            for ( Int j = 0; j < resolution->y; j++ )
            {
			    xi_r = [ gaussianRNG nextGaussianFPRandomNumber ];
			    xi_i = [ gaussianRNG nextGaussianFPRandomNumber ];

                k.x = [ self indexToKx:i ];
                k.y = [ self indexToKy:j ];

                a = sqrt([ self getAmplitudeAt:&k ]);

			    H0[j + resolution->y * i][0] = MATH_1_DIV_SQRT_2 * xi_r * a;
			    H0[j + resolution->y * i][1] = MATH_1_DIV_SQRT_2 * xi_i * a;
            }
        }

        needsUpdate = NO;
    }
}

- (void) generateHAtTime:(Float)time
{
    FVector2 k;
    Float omega;
    fftwf_complex expOmega, expMinusOmega, H0expOmega, H0expMinusOmega, H0conjugate;
    Int indexForK, indexForConjugate;

	if ( time != lastTime )
	{
        FFTWF_SAFE_FREE(frequencySpectrum);

		frequencySpectrum = fftwf_malloc(sizeof(fftwf_complex) * resolution->x * resolution->y);

        for ( Int i = 0; i < resolution->x; i++ )
        {
            for ( Int j = 0; j < resolution->y; j++ )
            {
                indexForK = j + resolution->y * i;
                indexForConjugate = ((resolution->y - j) % resolution->y) + resolution->y * ((resolution->x - i) % resolution->x);

                k.x = [ self indexToKx:i ];
                k.y = [ self indexToKy:j ];

                omega = [ self omegaForK:&k ];

                // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
                expOmega[0] = cos(omega * time);
                expOmega[1] = sin(omega * time);

                // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
                expMinusOmega[0] = cos(omega * time);
                expMinusOmega[1] = -sin(omega * time);

                /* complex multiplication
                   x = a + i*b
                   y = c + i*d
                   xy = (ac-bd) + i(ad+bc)
                */

                // H0[indexForK] * exp(i*omega*t)
                H0expOmega[0] = H0[indexForK][0] * expOmega[0] - H0[indexForK][1] * expOmega[1];
                H0expOmega[1] = H0[indexForK][0] * expOmega[1] + H0[indexForK][1] * expOmega[0];


                H0conjugate[0] = H0[indexForConjugate][0];
                H0conjugate[1] = -H0[indexForConjugate][1];

                // H0[indexForConjugate] * exp(-i*omega*t)
                
                H0expMinusOmega[0] = H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1];
                H0expMinusOmega[1] = H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0];

                /* complex addition
                   x = a + i*b
                   y = c + i*d
                   x+y = (a+c)+i(b+d)
                */

                // H = H0expOmega + H0expMinusomega
                frequencySpectrum[indexForK][0] = H0expOmega[0] + H0expMinusOmega[0];
                frequencySpectrum[indexForK][1] = H0expOmega[1] + H0expMinusOmega[1];
            }
        }

        lastTime = time;
    }
}

- (void) generateTimeIndependentH
{
    [ self generateHAtTime:1.0f ];
}

/*
Frequeny Spectrum Quadrant Layout

---------
| 1 | 2 |
---------
| 4 | 3 |
---------

*/

#define QUADRANT_1_AND_3     1
#define QUADRANT_2_AND_4    -1

- (void) swapFrequencySpectrumQuadrants:(NpState)quadrants
{
    fftw_complex tmp;
    Int index, oppositeQuadrantIndex;

    Int startX = 0;
    Int endX = resolution->x / 2;
    Int startY, endY;

    switch ( quadrants )
    {
        case QUADRANT_1_AND_3:
        {
            startY = 0;
            endY = resolution->y/2;
            break;
        }
        case QUADRANT_2_AND_4:
        {
            startY = resolution->y/2;
            endY = resolution->y;
            break;
        }
    }

    for ( Int i = startX; i < endX; i++ )
    {
        for ( Int j = startY; j < endY; j++ )
        {
            index = j + resolution->y * i;
            oppositeQuadrantIndex = (j + ((resolution->y/2) * quadrants)) + resolution->y * (i + resolution->x/2);

            tmp[0] = frequencySpectrum[index][0];
            tmp[1] = frequencySpectrum[index][1];

            frequencySpectrum[index][0] = frequencySpectrum[oppositeQuadrantIndex][0];
            frequencySpectrum[index][1] = frequencySpectrum[oppositeQuadrantIndex][1];

            frequencySpectrum[oppositeQuadrantIndex][0] = tmp[0];
            frequencySpectrum[oppositeQuadrantIndex][1] = tmp[1];
        }
    }
}

- (void) generateTimeIndependentFrequencySpectrum
{
    [ self generateH0 ];
    [ self generateTimeIndependentH ];

    [ self swapFrequencySpectrumQuadrants:QUADRANT_1_AND_3 ];
    [ self swapFrequencySpectrumQuadrants:QUADRANT_2_AND_4 ];
}

- (void) generateFrequencySpectrumAtTime:(Float)time
{
    [ self generateH0 ];
    [ self generateHAtTime:time ];

    [ self swapFrequencySpectrumQuadrants:QUADRANT_1_AND_3 ];
    [ self swapFrequencySpectrumQuadrants:QUADRANT_2_AND_4 ];
}

@end
