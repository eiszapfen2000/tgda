#import "ODConstants.h"
#import "ODPhillipsSpectrumDouble.h"

#define FFTW_FREE(_pointer)        do {void *_ptr=(void *)(_pointer); fftw_free(_ptr); _pointer=NULL; } while (0)
#define FFTW_SAFE_FREE(_pointer)   { if ( (_pointer) != NULL ) FFTW_FREE((_pointer)); }

typedef enum ODQuadrants
{
    ODQuadrant_1_3 =  1,
    ODQuadrant_2_4 = -1
}
ODQuadrants;

static inline double omega_for_k(Vector2 const * const k)
{
    return sqrt(EARTH_ACCELERATION * v2_v_length(k));
}

static double amplitude(Vector2 const * const windDirectionNormalised,
                        Vector2 const * const k,
                        const double L)
{
    const double kSquareLength = v2_v_square_length(k);

    if ( kSquareLength == 0.0 )
    {
        return 0.0;
    }

    const Vector2 kNormalised = v2_v_normalised(k);

    double amplitude = PHILLIPS_CONSTANT;
    amplitude = amplitude * ( 1.0 / (kSquareLength * kSquareLength) );
    amplitude = amplitude * exp( -1.0 / (kSquareLength * L * L) );

    const double kdotw = v2_vv_dot_product(&kNormalised, windDirectionNormalised);
    amplitude = amplitude * kdotw * kdotw;

    return amplitude;
}

@implementation ODPhillipsSpectrumDouble

- (id) init
{
    return [ self initWithName:@"Phillips Spectrum Double" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    H0 = NULL;

    gaussianRNG = odgaussianrng_alloc_init();

    lastSettings.geometryResolution = iv2_max();
    lastSettings.gradientResolution = iv2_max();
    lastSettings.size = v2_max();
    lastSettings.windDirection = v2_max();
    lastSettings.windSpeed = DBL_MAX;
    lastSettings.dampening = DBL_MAX;

    currentSettings.geometryResolution = iv2_zero();
    currentSettings.gradientResolution = iv2_zero();
    currentSettings.size = v2_zero();
    currentSettings.windDirection = v2_zero();
    currentSettings.windSpeed = 0.0;
    currentSettings.dampening = 0.0;

    return self;
}

- (void) dealloc
{
    FFTW_SAFE_FREE(H0);
    odgaussianrng_free(gaussianRNG);

    [ super dealloc ];
}

- (void) generateH0:(BOOL)force
{
    if ( currentSettings.size.x == lastSettings.size.x
         && currentSettings.size.y == lastSettings.size.y
         && currentSettings.windDirection.x == lastSettings.windDirection.x
         && currentSettings.windDirection.y == lastSettings.windDirection.y
         && currentSettings.windSpeed == lastSettings.windSpeed
         && currentSettings.dampening == lastSettings.dampening
         && currentSettings.geometryResolution.x == lastSettings.geometryResolution.x
         && currentSettings.geometryResolution.y == lastSettings.geometryResolution.y
         && currentSettings.gradientResolution.x == lastSettings.gradientResolution.x
         && currentSettings.gradientResolution.y == lastSettings.gradientResolution.y
         && force == NO )
    {
        return;
    }

    if ( currentSettings.gradientResolution.x != lastSettings.gradientResolution.x
         || currentSettings.gradientResolution.y != lastSettings.gradientResolution.y )
    {
        FFTW_SAFE_FREE(H0);
	    H0 = fftw_alloc_complex(currentSettings.gradientResolution.x * currentSettings.gradientResolution.y);
    }

    const IVector2 resolution = currentSettings.gradientResolution;
    const Vector2 size = currentSettings.size;
    const Vector2 windDirection = currentSettings.windDirection;
    const Vector2 windDirectionNormalised = v2_v_normalised(&windDirection);

    const double windDirectionSquareLength 
        = v2_v_square_length(&windDirection);

    const double L = windDirectionSquareLength / EARTH_ACCELERATION;

    const double n = -(resolution.x / 2.0);
    const double m =  (resolution.y / 2.0);

    const double dsizex = 1.0 / size.x;
    const double dsizey = 1.0 / size.y;

    for ( int32_t i = 0; i < resolution.x; i++ )
    {
        for ( int32_t j = 0; j < resolution.y; j++ )
        {
            const double xi_r = odgaussianrng_get_next(gaussianRNG);
            const double xi_i = odgaussianrng_get_next(gaussianRNG);

            const double di = i;
            const double dj = j;

            const double kx = (n + di) * MATH_2_MUL_PI * dsizex;
            const double ky = (m - dj) * MATH_2_MUL_PI * dsizey;

            const Vector2 k = {kx, ky};
            const double a = sqrt(amplitude(&windDirectionNormalised, &k, L));

            H0[j + resolution.y * i][0] = MATH_1_DIV_SQRT_2 * xi_r * a;
            H0[j + resolution.y * i][1] = MATH_1_DIV_SQRT_2 * xi_i * a;
        }
    }
}

- (OdFrequencySpectrumDouble) generateHAtTime:(const double)time
{
    const IVector2 resolution = currentSettings.gradientResolution;
    const Vector2 size = currentSettings.size;

	fftw_complex * frequencySpectrum
        = fftw_alloc_complex(resolution.x * resolution.y);

    const double n = -(resolution.x / 2.0);
    const double m =  (resolution.y / 2.0);

    const double dsizex = 1.0 / size.x;
    const double dsizey = 1.0 / size.y;

    for ( int32_t i = 0; i < resolution.x; i++ )
    {
        for ( int32_t j = 0; j < resolution.y; j++ )
        {
            const int32_t indexForK = j + resolution.y * i;
            const int32_t indexForConjugate = ((resolution.y - j) % resolution.y) + resolution.y * ((resolution.x - i) % resolution.x);

            const double di = i;
            const double dj = j;

            const double kx = (n + di) * MATH_2_MUL_PI * dsizex;
            const double ky = (m - dj) * MATH_2_MUL_PI * dsizey;

            const Vector2 k = {kx, ky};
            //const double omega = [ self omegaForK:&k ];
            const double omega = omega_for_k(&k);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftw_complex expOmega = { cos(omega * time), sin(omega * time) };

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            const fftw_complex expMinusOmega = { expOmega[0], -expOmega[1] };

            /* complex multiplication
               x = a + i*b
               y = c + i*d
               xy = (ac-bd) + i(ad+bc)
            */

            // H0[indexForK] * exp(i*omega*t)
            const fftw_complex H0expOmega
                = { H0[indexForK][0] * expOmega[0] - H0[indexForK][1] * expOmega[1],
                    H0[indexForK][0] * expOmega[1] + H0[indexForK][1] * expOmega[0] };

            const fftw_complex H0conjugate
                = { H0[indexForConjugate][0], -H0[indexForConjugate][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftw_complex H0expMinusOmega
                = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                    H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

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

    OdFrequencySpectrumDouble result
        = { .timestamp     = time,
            .geometryResolution = resolution,
            .gradientResolution = resolution,
            .size          = currentSettings.size,
            .waveSpectrum  = frequencySpectrum,
            .gradientX     = NULL,
            .gradientZ     = NULL,
            .displacementX = NULL,
            .displacementZ = NULL };

    return result;
}

- (OdFrequencySpectrumDouble) generateTimeIndependentH
{
    return [ self generateHAtTime:1.0 ];
}

- (OdFrequencySpectrumDouble) generateHHCAtTime:(const double)time
{
    const IVector2 resolution = currentSettings.gradientResolution;
    const Vector2 size = currentSettings.size;

    const IVector2 resolutionHC = { resolution.x, (resolution.y / 2) + 1 };
    const IVector2 quadrantResolution = { resolution.x / 2, resolution.y / 2 };

	fftw_complex * frequencySpectrumHC
        = fftw_alloc_complex(resolutionHC.x * resolutionHC.y);

    //const double n = -(resolution.x / 2.0);
    //const double m =  (resolution.y / 2.0);

    const double dsizex = 1.0 / size.x;
    const double dsizey = 1.0 / size.y;

    // first generate quadrant 3
    // kx starts at 0 and increases
    // ky starts at 0 and decreases

    const double q3n = 0.0;
    const double q3m = 0.0;

    for ( int32_t i = 0; i < quadrantResolution.x; i++ )
    {
        for ( int32_t j = 0; j < quadrantResolution.y; j++ )
        {
            const int32_t iInH0 = i + quadrantResolution.x;
            const int32_t jInH0 = j + quadrantResolution.y;

            const int32_t indexForKInH0 = jInH0 + (resolution.y * iInH0);

            const int32_t indexForKConjugateInH0
                = ((resolution.y - jInH0) % resolution.y) + resolution.y * ((resolution.x - iInH0) % resolution.x);

            const int32_t indexHC = j + (i * resolutionHC.y);

            //printf("%d %d %d %d %d %d\n", i, j, iInH0, jInH0, indexForKInH0, indexForKConjugateInH0);

            const double di = i;
            const double dj = j;

            const double kx = (q3n + di) * MATH_2_MUL_PI * dsizex;
            const double ky = (q3m - dj) * MATH_2_MUL_PI * dsizey;

            const Vector2 k = {kx, ky};
//            const double omega = [ self omegaForK:&k ];
            const double omega = omega_for_k(&k);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftw_complex expOmega = { cos(omega * time), sin(omega * time) };

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            const fftw_complex expMinusOmega = { expOmega[0], -expOmega[1] };

            // H0[indexForK] * exp(i*omega*t)
            const fftw_complex H0expOmega
                = { H0[indexForKInH0][0] * expOmega[0] - H0[indexForKInH0][1] * expOmega[1],
                    H0[indexForKInH0][0] * expOmega[1] + H0[indexForKInH0][1] * expOmega[0] };

            const fftw_complex H0conjugate
                = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftw_complex H0expMinusOmega
                = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                    H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

            // H = H0expOmega + H0expMinusomega
            frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
            frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
        }
    }

    // second generate quadrant 4
    // kx starts at -resolution.x/2
    // ky starts at 0 and decreases

    const double q4n = -(resolution.x / 2.0);
    const double q4m = 0.0;

    for ( int32_t i = 0; i < quadrantResolution.x; i++ )
    {
        for ( int32_t j = 0; j < quadrantResolution.y; j++ )
        {
            const int32_t iInH0 = i;
            const int32_t jInH0 = j + quadrantResolution.y;

            const int32_t indexForKInH0 = jInH0 + (resolution.y * iInH0);

            const int32_t indexForKConjugateInH0
                = ((resolution.y - jInH0) % resolution.y) + resolution.y * ((resolution.x - iInH0) % resolution.x);

            const int32_t indexHC = j + ((i + quadrantResolution.x) * resolutionHC.y);

            const double di = i;
            const double dj = j;

            const double kx = (q4n + di) * MATH_2_MUL_PI * dsizex;
            const double ky = (q4m - dj) * MATH_2_MUL_PI * dsizey;

            const Vector2 k = {kx, ky};
//            const double omega = [ self omegaForK:&k ];
            const double omega = omega_for_k(&k);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftw_complex expOmega = { cos(omega * time), sin(omega * time) };

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            const fftw_complex expMinusOmega = { expOmega[0], -expOmega[1] };

            // H0[indexForK] * exp(i*omega*t)
            const fftw_complex H0expOmega
                = { H0[indexForKInH0][0] * expOmega[0] - H0[indexForKInH0][1] * expOmega[1],
                    H0[indexForKInH0][0] * expOmega[1] + H0[indexForKInH0][1] * expOmega[0] };

            const fftw_complex H0conjugate
                = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftw_complex H0expMinusOmega
                = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                    H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

            // H = H0expOmega + H0expMinusomega
            frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
            frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
        }
    }

    //printf("q2\n");
    // third generate first row of quadrant 2

    const double q2n = 0.0;
    const double q2m = resolution.y / 2.0;

    for ( int32_t i = 0; i < quadrantResolution.x; i++ )
    {
        const int32_t iInH0 = i + quadrantResolution.x;
        const int32_t jInH0 = 0;

        const int32_t indexForKInH0 = jInH0 + (resolution.y * iInH0);

        const int32_t indexForKConjugateInH0
            = ((resolution.y - jInH0) % resolution.y) + resolution.y * ((resolution.x - iInH0) % resolution.x);

        const int32_t indexHC = quadrantResolution.y + (i * resolutionHC.y);

        const double di = i;
        const double dj = 0;

        const double kx = (q2n + di) * MATH_2_MUL_PI * dsizex;
        const double ky = (q2m - dj) * MATH_2_MUL_PI * dsizey;

        const Vector2 k = {kx, ky};
//        const double omega = [ self omegaForK:&k ];
        const double omega = omega_for_k(&k);

        // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
        const fftw_complex expOmega = { cos(omega * time), sin(omega * time) };

        // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
        const fftw_complex expMinusOmega = { expOmega[0], -expOmega[1] };

        // H0[indexForK] * exp(i*omega*t)
        const fftw_complex H0expOmega
            = { H0[indexForKInH0][0] * expOmega[0] - H0[indexForKInH0][1] * expOmega[1],
                H0[indexForKInH0][0] * expOmega[1] + H0[indexForKInH0][1] * expOmega[0] };

        const fftw_complex H0conjugate
            = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

        // H0[indexForConjugate] * exp(-i*omega*t)
        const fftw_complex H0expMinusOmega
            = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

        // H = H0expOmega + H0expMinusomega
        frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
        frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
    }

    //printf("q1\n");

    const double q1n = -(resolution.x / 2.0);
    const double q1m =   resolution.y / 2.0;

    // forth generate first row of quadrant 1
    for ( int32_t i = 0; i < quadrantResolution.x; i++ )
    {
        const int32_t iInH0 = i;
        const int32_t jInH0 = 0;

        const int32_t indexForKInH0 = jInH0 + (resolution.y * iInH0);

        const int32_t indexForKConjugateInH0
            = ((resolution.y - jInH0) % resolution.y) + resolution.y * ((resolution.x - iInH0) % resolution.x);

        const int32_t indexHC = quadrantResolution.y + ((i + quadrantResolution.x) * resolutionHC.y);

        const double di = i;
        const double dj = 0;

        const double kx = (q1n + di) * MATH_2_MUL_PI * dsizex;
        const double ky = (q1m - dj) * MATH_2_MUL_PI * dsizey;

        const Vector2 k = {kx, ky};
//        const double omega = [ self omegaForK:&k ];
        const double omega = omega_for_k(&k);

        // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
        const fftw_complex expOmega = { cos(omega * time), sin(omega * time) };

        // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
        const fftw_complex expMinusOmega = { expOmega[0], -expOmega[1] };

        // H0[indexForK] * exp(i*omega*t)
        const fftw_complex H0expOmega
            = { H0[indexForKInH0][0] * expOmega[0] - H0[indexForKInH0][1] * expOmega[1],
                H0[indexForKInH0][0] * expOmega[1] + H0[indexForKInH0][1] * expOmega[0] };

        const fftw_complex H0conjugate
            = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

        // H0[indexForConjugate] * exp(-i*omega*t)
        const fftw_complex H0expMinusOmega
            = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

        // H = H0expOmega + H0expMinusomega
        frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
        frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
    }

    OdFrequencySpectrumDouble result
        = { .timestamp     = time,
            .geometryResolution = resolution,
            .gradientResolution = resolution,
            .size          = currentSettings.size,
            .waveSpectrum  = frequencySpectrumHC,
            .gradientX     = NULL,
            .gradientZ     = NULL,
            .displacementX = NULL,
            .displacementZ = NULL };

    return result;
}

- (OdFrequencySpectrumDouble) generateTimeIndependentHHC
{
    return [ self generateHHCAtTime:1.0 ];
}

/*
Frequeny Spectrum Quadrant Layout

---------
| 1 | 2 |
---------
| 4 | 3 |
---------

*/

/*
If I want to generate less data and use a complex 2 real transform
I need to take the quadrant swapping into account, it's not enough
to simply generate data for quadrant 1 and 2.
Basically I need quadrant 4 and 3, but quadrant 3 has to be moved
to quadrant 4's left side.
Either screw around with two for loops or choose k the
right way.
*/

- (void) swapFrequencySpectrum:(fftw_complex *)spectrum
                     quadrants:(ODQuadrants)quadrants
{
    const IVector2 resolution = currentSettings.gradientResolution;

    fftw_complex tmp;
    int32_t index, oppositeQuadrantIndex;

    int32_t startX = 0;
    int32_t endX = resolution.x / 2;
    int32_t startY = 0;
    int32_t endY   = 0;

    switch ( quadrants )
    {
        case ODQuadrant_1_3:
        {
            startY = 0;
            endY = resolution.y/2;
            break;
        }

        case ODQuadrant_2_4:
        {
            startY = resolution.y/2;
            endY = resolution.y;
            break;
        }
    }

    const int32_t halfResX = resolution.x / 2;
    const int32_t halfResY = resolution.y / 2;

    for ( int32_t i = startX; i < endX; i++ )
    {
        for ( int32_t j = startY; j < endY; j++ )
        {
            index = j + resolution.y * i;
            oppositeQuadrantIndex = (j + (halfResY * quadrants)) + resolution.y * (i + halfResX);

            tmp[0] = spectrum[index][0];
            tmp[1] = spectrum[index][1];

            spectrum[index][0] = spectrum[oppositeQuadrantIndex][0];
            spectrum[index][1] = spectrum[oppositeQuadrantIndex][1];

            spectrum[oppositeQuadrantIndex][0] = tmp[0];
            spectrum[oppositeQuadrantIndex][1] = tmp[1];
        }
    }
}

- (OdFrequencySpectrumDouble) generateDoubleFrequencySpectrum:(const ODSpectrumSettings)settings
                                                       atTime:(const double)time
{
    currentSettings = settings;

    [ self generateH0:YES ];

    OdFrequencySpectrumDouble result = [ self generateHAtTime:time ];
    [ self swapFrequencySpectrum:result.waveSpectrum quadrants:ODQuadrant_1_3 ];
    [ self swapFrequencySpectrum:result.waveSpectrum quadrants:ODQuadrant_2_4 ];

    if ( result.gradientX != NULL )
    {
        [ self swapFrequencySpectrum:result.gradientX quadrants:ODQuadrant_1_3 ];
        [ self swapFrequencySpectrum:result.gradientX quadrants:ODQuadrant_2_4 ];
    }

    if ( result.gradientZ != NULL )
    {
        [ self swapFrequencySpectrum:result.gradientZ quadrants:ODQuadrant_1_3 ];
        [ self swapFrequencySpectrum:result.gradientZ quadrants:ODQuadrant_2_4 ];
    }

    lastSettings = currentSettings;

    return result;
}

- (OdFrequencySpectrumDouble) generateDoubleFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                                         atTime:(const double)time
{
    currentSettings = settings;

    [ self generateH0:YES ];
    OdFrequencySpectrumDouble result= [ self generateHHCAtTime:time ];
    lastSettings = currentSettings;

    return result;
}

@end
