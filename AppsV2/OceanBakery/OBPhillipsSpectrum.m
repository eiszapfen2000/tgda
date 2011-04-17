#import "Core/NPEngineCore.h"
#import "Core/Timer/NPTimer.h"
#import "OBGaussianRNG.h"
#import "OBPhillipsSpectrum.h"

#define FFTW_FREE(_pointer)        do {void *_ptr=(void *)(_pointer); fftw_free(_ptr); _pointer=NULL; } while (0)
#define FFTW_SAFE_FREE(_pointer)   { if ( (_pointer) != NULL ) FFTW_FREE((_pointer)); }

IVector2 globalResolution;
Vector2 globalResolutionD;
Vector2 globalSize;
Vector2 globalWindDirection;
Vector2 globalWindDirectionNormalised;
double globalL;
double globalLSquare;

inline double omegaForK(const Vector2 const * k)
{
    return sqrt(EARTH_ACCELERATION * v2_v_length(k));
}

inline double indexToKx(const int32_t index)
{
    const double n = -(globalResolutionD.x * 0.5) + (double)index;
    return (MATH_2_MUL_PI * n) / globalSize.x;
}

inline double indexToKy(const int32_t index)
{
    const double m = (globalResolutionD.y * 0.5) - (double)index;
    return (MATH_2_MUL_PI * m) / globalSize.y;
}

double getAmplitudeAt(const Vector2 const * k)
{
    const double kSquareLength = v2_v_square_length(k);

    /*
    if ( kSquareLength == 0.0 )
    {
        return 0.0;
    }
    */

    const Vector2 kNormalised = v2_v_normalised(k);

    double amplitude = PHILLIPS_CONSTANT;
    amplitude = amplitude * ( 1.0 / (kSquareLength * kSquareLength) );
    amplitude = amplitude * exp( -1.0 / (kSquareLength * globalLSquare) );

    //const double kdotw = v2_vv_dot_product(&kNormalised, &globalWindDirectionNormalised);
    const double kdotw = kNormalised.x * globalWindDirectionNormalised.x + kNormalised.y * globalWindDirectionNormalised.y;
    amplitude = amplitude * (kdotw * kdotw);

    return amplitude;
}

@implementation OBPhillipsSpectrum

- (id) init
{
    return [ self initWithName:@"Phillips Spectrum" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    alpha = PHILLIPS_CONSTANT;

    resolution.x = resolution.y = 0;
    size.x = size.y = 0.0;
    windDirection.x = windDirection.y = 0.0;

    needsUpdate = YES;
    lastTime = -1.0;

    gaussianRNG = nil;
    H0 = NULL;
    frequencySpectrum = NULL;

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(gaussianRNG);

    FFTW_SAFE_FREE(frequencySpectrum);
    FFTW_SAFE_FREE(H0);

    [ super dealloc ];
}

- (fftw_complex *) frequencySpectrum
{
    return frequencySpectrum;
}

- (void) setSize:(const Vector2)newSize
{
    if ( newSize.x > 0.0f && newSize.y > 0.0f )
    {
        size = newSize;
        globalSize = size;

        needsUpdate = YES;
    }
}

- (void) setResolution:(const IVector2)newResolution
{
    if ( newResolution.x > 0 && newResolution.y > 0 )
    {
        resolution = newResolution;
        globalResolution = resolution;
        globalResolutionD.x = (double)resolution.x;
        globalResolutionD.y = (double)resolution.y;

        needsUpdate = YES;
    }
}

- (void) setWindDirection:(const Vector2)newWindDirection
{
    windDirection = newWindDirection;
    globalWindDirection = windDirection;
    globalWindDirectionNormalised = v2_v_normalised(&globalWindDirection);

    globalL = v2_v_square_length(&globalWindDirection) / EARTH_ACCELERATION;
    globalLSquare = globalL * globalL;

    needsUpdate = YES;
}

- (void) setGaussianRNG:(id)newGaussianRNG
{
    ASSIGN(gaussianRNG,newGaussianRNG);

    needsUpdate = YES;
}

/*
- (float) omegaForK:(FVector2 *)k
{
    return (float)sqrt(EARTH_ACCELERATION * fv2_v_length(k));
}

- (float) indexToKx:(int32_t)index
{
    float n = -(resolution.x / 2.0f);
    n = n + (float)index;

    return (MATH_2_MUL_PI * n) / size.x;
}

- (float) indexToKy:(int32_t)index
{
    float m = (resolution.y / 2.0f);
    m = m - (float)index;

    return (MATH_2_MUL_PI * m) / size.y;
}

- (float) getAmplitudeAt:(FVector2 *)k
{
    float kSquareLength = fv2_v_square_length(k);

    if ( kSquareLength == 0.0f )
    {
        return 0.0f;
    }

    float windDirectionSquareLength  = fv2_v_square_length(&windDirection);
    float L = windDirectionSquareLength / EARTH_ACCELERATION;

    FVector2 windDirectionNormalised = fv2_v_normalised(&windDirection);
    FVector2 kNormalised = fv2_v_normalised(k);

    float amplitude = PHILLIPS_CONSTANT;
    amplitude = amplitude * ( 1.0f / (kSquareLength * kSquareLength) );
    amplitude = amplitude * (float)exp( -1.0 / (double)(kSquareLength * L * L) );

    float kdotw = fv2_vv_dot_product(&kNormalised, &windDirectionNormalised);
    amplitude = amplitude * (float)pow((double)kdotw, 2.0);

    return amplitude;
}
*/

- (void) generateH0
{
    double xi_r, xi_i, a;
    Vector2 k;

    NPTimer * t = [[ NPEngineCore instance ] timer ];

	if ( needsUpdate == YES )
	{
        FFTW_SAFE_FREE(H0);

		H0 = fftw_malloc(sizeof(fftw_complex) * resolution.x * resolution.y);
        [ t reset ];

        for ( int32_t i = 0; i < resolution.x; i++ )
        {
            for ( int32_t j = 0; j < resolution.y; j++ )
            {
			    //xi_r = [ gaussianRNG nextGaussianFPRandomNumber ];
			    //xi_i = [ gaussianRNG nextGaussianFPRandomNumber ];
                //xi_r = i * 0.35;
                //xi_i = j * 0.75;

                //k.x = [ self indexToKx:i ];
                //k.y = [ self indexToKy:j ];
                k.x = indexToKx(i);
                k.y = indexToKy(j);

                //a = sqrt([ self getAmplitudeAt:&k ]);
                a = sqrt(getAmplitudeAt(&k));

			    //H0[j + resolution.y * i][0] = MATH_1_DIV_SQRT_2 * xi_r * a;
			    //H0[j + resolution.y * i][1] = MATH_1_DIV_SQRT_2 * xi_i * a;
			    H0[j + resolution.y * i][0] = MATH_1_DIV_SQRT_2 * a;
			    H0[j + resolution.y * i][1] = MATH_1_DIV_SQRT_2 * a;

            }
        }

        needsUpdate = NO;

        [ t update ];
        fprintf(stdout, "H0 %f\n", [ t frameTime ]);
    }
}

- (void) generateHAtTime:(double)time
{
    Vector2 k;
    double omega;
    fftw_complex expOmega, expMinusOmega, H0expOmega, H0expMinusOmega, H0conjugate;
    int32_t indexForK, indexForConjugate;

    NPTimer * t = [[ NPEngineCore instance ] timer ];

	if ( time != lastTime )
	{
        FFTW_SAFE_FREE(frequencySpectrum);

		frequencySpectrum = fftw_malloc(sizeof(fftw_complex) * resolution.x * resolution.y);

        [ t reset ];

        for ( int32_t i = 0; i < resolution.x; i++ )
        {
            for ( int32_t j = 0; j < resolution.y; j++ )
            {
                indexForK = j + resolution.y * i;
                indexForConjugate = ((resolution.y - j) % resolution.y) + resolution.y * ((resolution.x - i) % resolution.x);

                //k.x = [ self indexToKx:i ];
                //k.y = [ self indexToKy:j ];
                k.x = indexToKx(i);
                k.y = indexToKy(j);

                //omega = [ self omegaForK:&k ];
                omega = omegaForK(&k);

                // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
                expOmega[0] = cos(omega * time);
                expOmega[1] = sin(omega * time);

                // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
                //expMinusOmega[0] =  cos(omega * time);
                //expMinusOmega[1] = -sin(omega * time);
                expMinusOmega[0] =  expOmega[0];
                expMinusOmega[1] = -expOmega[1];

                /* complex multiplication
                   x = a + i*b
                   y = c + i*d
                   xy = (ac-bd) + i(ad+bc)
                */

                // H0[indexForK] * exp(i*omega*t)
                H0expOmega[0] = H0[indexForK][0] * expOmega[0] - H0[indexForK][1] * expOmega[1];
                H0expOmega[1] = H0[indexForK][0] * expOmega[1] + H0[indexForK][1] * expOmega[0];


                H0conjugate[0] =  H0[indexForConjugate][0];
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

        [ t update ];
        fprintf(stdout, "H %f\n", [ t frameTime ]);
    }
}

- (void) generateTimeIndependentH
{
    [ self generateHAtTime:1.0 ];
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

typedef enum OBQuadrants
{
    OBQuadrant_1_3 =  1,
    OBQuadrant_2_4 = -1
}
OBQuadrants;

- (void) swapFrequencySpectrumQuadrants:(OBQuadrants)quadrants
{
    fftw_complex tmp;
    int32_t index, oppositeQuadrantIndex;

    int32_t startX = 0;
    int32_t endX = resolution.x / 2;
    int32_t startY, endY;

    switch ( quadrants )
    {
        case OBQuadrant_1_3:
        {
            startY = 0;
            endY = resolution.y/2;
            break;
        }

        case OBQuadrant_2_4:
        {
            startY = resolution.y/2;
            endY = resolution.y;
            break;
        }
    }

    for ( int32_t i = startX; i < endX; i++ )
    {
        for ( int32_t j = startY; j < endY; j++ )
        {
            index = j + resolution.y * i;
            oppositeQuadrantIndex = (j + ((resolution.y/2) * quadrants)) + resolution.y * (i + resolution.x/2);

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

    [ self swapFrequencySpectrumQuadrants:OBQuadrant_1_3 ];
    [ self swapFrequencySpectrumQuadrants:OBQuadrant_2_4 ];
}

- (void) generateFrequencySpectrumAtTime:(const double)time
{
    [ self generateH0 ];
    [ self generateHAtTime:time ];

    [ self swapFrequencySpectrumQuadrants:OBQuadrant_1_3 ];
    [ self swapFrequencySpectrumQuadrants:OBQuadrant_2_4 ];
}

@end
