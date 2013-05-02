#import "ODConstants.h"
#import "ODPhillipsSpectrumFloat.h"

#define FFTW_FREE(_pointer)        do {void *_ptr=(void *)(_pointer); fftwf_free(_ptr); _pointer=NULL; } while (0)
#define FFTW_SAFE_FREE(_pointer)   { if ( (_pointer) != NULL ) FFTW_FREE((_pointer)); }

typedef enum ODQuadrants
{
    ODQuadrant_1_3 =  1,
    ODQuadrant_2_4 = -1
}
ODQuadrants;

static inline float omegaf_for_k(FVector2 const * const k)
{
    return sqrtf(EARTH_ACCELERATIONf * fv2_v_length(k));
}

static float amplitudef(FVector2 const * const windDirection,
                 FVector2 const * const k)
{
    const float kSquareLength = fv2_v_square_length(k);

    if ( kSquareLength == 0.0f )
    {
        return 0.0f;
    }

    const float windDirectionSquareLength 
        = fv2_v_square_length(windDirection);

    const float L = windDirectionSquareLength / EARTH_ACCELERATIONf;

    const FVector2 windDirectionNormalised = fv2_v_normalised(windDirection);
    const FVector2 kNormalised = fv2_v_normalised(k);

    float amplitude = PHILLIPS_CONSTANTf;
    amplitude = amplitude * ( 1.0f / (kSquareLength * kSquareLength) );
    amplitude = amplitude * expf( -1.0f / (kSquareLength * L * L) );

    const float kdotw = fv2_vv_dot_product(&kNormalised, &windDirectionNormalised);
    amplitude = amplitude * kdotw * kdotw;

    return amplitude;
}

@implementation ODPhillipsSpectrumFloat

- (id) init
{
    return [ self initWithName:@"Phillips Spectrum Float" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    H0 = NULL;

    gaussianRNG = odgaussianrng_alloc_init();

    lastSettings.resolution = (IVector2){INT_MAX, INT_MAX};
    currentSettings.resolution = (IVector2){0, 0};

    lastSettings.size = (Vector2){DBL_MAX, DBL_MAX};
    currentSettings.size = (Vector2){0.0, 0.0};

    lastSettings.windDirection = (Vector2){DBL_MAX, DBL_MAX};
    currentSettings.windDirection = (Vector2){0.0, 0.0};

    return self;
}

- (void) dealloc
{
    FFTW_SAFE_FREE(H0);
    odgaussianrng_free(gaussianRNG);

    [ super dealloc ];
}

- (void) generateH0
{
    if ( currentSettings.size.x == lastSettings.size.x
         && currentSettings.size.y == lastSettings.size.y
         && currentSettings.windDirection.x == lastSettings.windDirection.x
         && currentSettings.windDirection.y == lastSettings.windDirection.y
         && currentSettings.resolution.x == lastSettings.resolution.x
         && currentSettings.resolution.y == lastSettings.resolution.y )
    {
        return;
    }

    if ( currentSettings.resolution.x != lastSettings.resolution.x
         || currentSettings.resolution.y != lastSettings.resolution.y )
    {
        FFTW_SAFE_FREE(H0);
	    H0 = fftwf_malloc(sizeof(fftwf_complex) * currentSettings.resolution.x * currentSettings.resolution.y);
    }

    const IVector2 resolution = currentSettings.resolution;
    const FVector2 size = (FVector2){currentSettings.size.x, currentSettings.size.y};
    const FVector2 windDirection = (FVector2){currentSettings.windDirection.x, currentSettings.windDirection.y};

    const float n = -(resolution.x / 2.0f);
    const float m =  (resolution.y / 2.0f);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            //const float xi_r = (float)gaussian_fprandomnumber();
            //const float xi_i = (float)gaussian_fprandomnumber();
            const float xi_r = (float)odgaussianrng_get_next(gaussianRNG);
            const float xi_i = (float)odgaussianrng_get_next(gaussianRNG);


            const float di = i;
            const float dj = j;

            const float kx = (n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (m - di) * MATH_2_MUL_PIf * dsizey;

            const FVector2 k = {kx, ky};
            const float a = sqrtf(amplitudef(&windDirection, &k));

            H0[j + resolution.x * i][0] = MATH_1_DIV_SQRT_2f * xi_r * a;
            H0[j + resolution.x * i][1] = MATH_1_DIV_SQRT_2f * xi_i * a;
        }
    }
}

- (OdFrequencySpectrumFloat) generateHAtTime:(const float)time
{
    const IVector2 resolution = currentSettings.resolution;
    const FVector2 size = (FVector2){currentSettings.size.x, currentSettings.size.y};

	fftwf_complex * frequencySpectrum
        = fftwf_malloc(sizeof(fftwf_complex) * resolution.x * resolution.y);

    const float n = -(resolution.x / 2.0f);
    const float m =  (resolution.y / 2.0f);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            const int32_t indexForK = j + resolution.x * i;
            const int32_t indexForConjugate = ((resolution.x - j) % resolution.x) + resolution.x * ((resolution.y - i) % resolution.y);

            const float di = i;
            const float dj = j;

            const float kx = (n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (m - di) * MATH_2_MUL_PIf * dsizey;

            const FVector2 k = {kx, ky};
            //const double omega = [ self omegaForK:&k ];
            const float omega = omegaf_for_k(&k);
            const float omegaT = fmodf(omega * time, MATH_2_MUL_PIf);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftwf_complex expOmega = { cosf(omegaT), sinf(omegaT) };

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            const fftwf_complex expMinusOmega = { expOmega[0], -expOmega[1] };

            /* complex multiplication
               x = a + i*b
               y = c + i*d
               xy = (ac-bd) + i(ad+bc)
            */

            // H0[indexForK] * exp(i*omega*t)
            const fftwf_complex H0expOmega
                = { H0[indexForK][0] * expOmega[0] - H0[indexForK][1] * expOmega[1],
                    H0[indexForK][0] * expOmega[1] + H0[indexForK][1] * expOmega[0] };

            const fftwf_complex H0conjugate
                = { H0[indexForConjugate][0], -H0[indexForConjugate][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftwf_complex H0expMinusOmega
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

    OdFrequencySpectrumFloat result
        = {.waveSpectrum = frequencySpectrum, .gradientX = NULL, .gradientZ = NULL };

    return result;
}

- (OdFrequencySpectrumFloat) generateTimeIndependentH
{
    return [ self generateHAtTime:1.0f ];
}

- (OdFrequencySpectrumFloat) generateHHCAtTime:(const float)time
{
    const IVector2 resolution = currentSettings.resolution;
    const FVector2 size = (FVector2){currentSettings.size.x, currentSettings.size.y};

    const IVector2 resolutionHC = { (resolution.x / 2) + 1, resolution.y };
    const IVector2 quadrantResolution = { resolution.x / 2, resolution.y / 2 };

	fftwf_complex * frequencySpectrumHC
        = fftwf_malloc(sizeof(fftwf_complex) * resolutionHC.x * resolutionHC.y);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    // first generate quadrant 3
    // kx starts at 0 and increases
    // ky starts at 0 and decreases

    const float q3n = 0.0f;
    const float q3m = 0.0f;

    //[ timer update ];

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        for ( int32_t j = 0; j < quadrantResolution.x; j++ )
        {
            const int32_t iInH0 = i + quadrantResolution.y;
            const int32_t jInH0 = j + quadrantResolution.x;

            const int32_t indexForKInH0 = jInH0 + (resolution.x * iInH0);

            const int32_t indexForKConjugateInH0
                = ((resolution.x - jInH0) % resolution.x) + resolution.x * ((resolution.y - iInH0) % resolution.y);

            const int32_t indexHC = j + (resolutionHC.x * i);

            //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

            const float di = i;
            const float dj = j;

            const float kx = (q3n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (q3m - di) * MATH_2_MUL_PIf * dsizey;

            const FVector2 k = {kx, ky};
            const float omega = omegaf_for_k(&k);
            const float omegaT = fmodf(omega * time, MATH_2_MUL_PIf);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftwf_complex expOmega = { cosf(omegaT), sinf(omegaT) };

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            const fftwf_complex expMinusOmega = { expOmega[0], -expOmega[1] };

            // H0[indexForK] * exp(i*omega*t)
            const fftwf_complex H0expOmega
                = { H0[indexForKInH0][0] * expOmega[0] - H0[indexForKInH0][1] * expOmega[1],
                    H0[indexForKInH0][0] * expOmega[1] + H0[indexForKInH0][1] * expOmega[0] };

            const fftwf_complex H0conjugate
                = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftwf_complex H0expMinusOmega
                = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                    H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

            // H = H0expOmega + H0expMinusomega
            frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
            frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
        }
    }

    // second generate quadrant 2
    // kx starts at 0 and increases
    // ky starts at resolution.y/2 and decreases

    const float q2n = 0.0f;
    const float q2m = resolution.y / 2.0f;

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        for ( int32_t j = 0; j < quadrantResolution.x; j++ )
        {
            const int32_t iInH0 = i;
            const int32_t jInH0 = j + quadrantResolution.x;

            const int32_t indexForKInH0 = jInH0 + (resolution.x * iInH0);

            const int32_t indexForKConjugateInH0
                = ((resolution.x - jInH0) % resolution.x) + resolution.x * ((resolution.y - iInH0) % resolution.y);

            const int32_t indexHC = j + (resolutionHC.x * (i + quadrantResolution.y));

            //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

            const float di = i;
            const float dj = j;

            const float kx = (q2n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (q2m - di) * MATH_2_MUL_PIf * dsizey;

            const FVector2 k = {kx, ky};
            const float omega = omegaf_for_k(&k);
            const float omegaT = fmodf(omega * time, MATH_2_MUL_PIf);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftwf_complex expOmega = { cosf(omegaT), sinf(omegaT) };

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            const fftwf_complex expMinusOmega = { expOmega[0], -expOmega[1] };

            // H0[indexForK] * exp(i*omega*t)
            const fftwf_complex H0expOmega
                = { H0[indexForKInH0][0] * expOmega[0] - H0[indexForKInH0][1] * expOmega[1],
                    H0[indexForKInH0][0] * expOmega[1] + H0[indexForKInH0][1] * expOmega[0] };

            const fftwf_complex H0conjugate
                = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftwf_complex H0expMinusOmega
                = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                    H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

            // H = H0expOmega + H0expMinusomega
            frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
            frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
        }
    }

    // third generate first column of quadrant 1
    // kx equals -resolution.x/2
    // ky starts at resolution.y/2 and decreases

    const float q1n = -(resolution.x / 2.0f);
    const float q1m = resolution.y / 2.0f;

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        const int32_t jInH0 = 0;
        const int32_t iInH0 = i;
        const int32_t j = 0;

        const int32_t indexForKInH0 = jInH0 + (resolution.x * iInH0);

        const int32_t indexForKConjugateInH0
            = ((resolution.x - jInH0) % resolution.x) + resolution.x * ((resolution.y - iInH0) % resolution.y);

        const int32_t indexHC = quadrantResolution.x + (resolutionHC.x * (i + quadrantResolution.y));

        //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

        const float di = i;
        const float dj = j;

        const float kx = (q1n + dj) * MATH_2_MUL_PIf * dsizex;
        const float ky = (q1m - di) * MATH_2_MUL_PIf * dsizey;

        const FVector2 k = {kx, ky};
        const float omega = omegaf_for_k(&k);
        const float omegaT = fmodf(omega * time, MATH_2_MUL_PIf);

        // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
        const fftwf_complex expOmega = { cosf(omegaT), sinf(omegaT) };

        // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
        const fftwf_complex expMinusOmega = { expOmega[0], -expOmega[1] };

        // H0[indexForK] * exp(i*omega*t)
        const fftwf_complex H0expOmega
            = { H0[indexForKInH0][0] * expOmega[0] - H0[indexForKInH0][1] * expOmega[1],
                H0[indexForKInH0][0] * expOmega[1] + H0[indexForKInH0][1] * expOmega[0] };

        const fftwf_complex H0conjugate
            = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

        // H0[indexForConjugate] * exp(-i*omega*t)
        const fftwf_complex H0expMinusOmega
            = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

        // H = H0expOmega + H0expMinusomega
        frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
        frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
    }

    // third generate first column of quadrant 4
    // kx equals -resolution.x/2
    // ky starts at 0.0 and decreases

    const float q4n = -(resolution.x / 2.0f);
    const float q4m = 0.0f;

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        const int32_t jInH0 = 0;
        const int32_t iInH0 = i + quadrantResolution.y;
        const int32_t j = 0;

        const int32_t indexForKInH0 = jInH0 + (resolution.x * iInH0);

        const int32_t indexForKConjugateInH0
            = ((resolution.x - jInH0) % resolution.x) + resolution.x * ((resolution.y - iInH0) % resolution.y);

        const int32_t indexHC = quadrantResolution.x + (resolutionHC.x * i);

        //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

        const float di = i;
        const float dj = j;

        const float kx = (q4n + dj) * MATH_2_MUL_PIf * dsizex;
        const float ky = (q4m - di) * MATH_2_MUL_PIf * dsizey;

        const FVector2 k = {kx, ky};
        const float omega = omegaf_for_k(&k);
        const float omegaT = fmodf(omega * time, MATH_2_MUL_PIf);

        // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
        const fftwf_complex expOmega = { cosf(omegaT), sinf(omegaT) };

        // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
        const fftwf_complex expMinusOmega = { expOmega[0], -expOmega[1] };

        // H0[indexForK] * exp(i*omega*t)
        const fftwf_complex H0expOmega
            = { H0[indexForKInH0][0] * expOmega[0] - H0[indexForKInH0][1] * expOmega[1],
                H0[indexForKInH0][0] * expOmega[1] + H0[indexForKInH0][1] * expOmega[0] };

        const fftwf_complex H0conjugate
            = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

        // H0[indexForConjugate] * exp(-i*omega*t)
        const fftwf_complex H0expMinusOmega
            = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

        // H = H0expOmega + H0expMinusomega
        frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
        frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
    }

    OdFrequencySpectrumFloat result
        = {.waveSpectrum = frequencySpectrumHC, .gradientX = NULL, .gradientZ = NULL };

    return result;
}

- (OdFrequencySpectrumFloat) generateTimeIndependentHHC
{
    return [ self generateHHCAtTime:1.0f ];
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

- (void) swapFrequencySpectrum:(fftwf_complex *)spectrum
                     quadrants:(ODQuadrants)quadrants
{
    const IVector2 resolution = currentSettings.resolution;

    fftwf_complex tmp;
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

- (OdFrequencySpectrumFloat) generateFloatFrequencySpectrum:(const ODSpectrumSettings)settings
                                                     atTime:(const float)time
{
    currentSettings = settings;

    [ self generateH0 ];

    OdFrequencySpectrumFloat result = [ self generateHAtTime:time ];
    [ self swapFrequencySpectrum:result.waveSpectrum quadrants:ODQuadrant_1_3 ];
    [ self swapFrequencySpectrum:result.waveSpectrum quadrants:ODQuadrant_2_4 ];

    lastSettings = currentSettings;

    return result;
}

- (OdFrequencySpectrumFloat) generateFloatFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                                       atTime:(const float)time
{
    currentSettings = settings;

    [ self generateH0 ];
    OdFrequencySpectrumFloat result= [ self generateHHCAtTime:time ];
    lastSettings = currentSettings;

    return result;
}

@end

