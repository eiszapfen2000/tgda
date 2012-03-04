#import "ODConstants.h"
#import "ODGaussianRNG.h"
#import "ODPhillipsSpectrumFloat.h"

#define FFTW_FREE(_pointer)        do {void *_ptr=(void *)(_pointer); fftwf_free(_ptr); _pointer=NULL; } while (0)
#define FFTW_SAFE_FREE(_pointer)   { if ( (_pointer) != NULL ) FFTW_FREE((_pointer)); }

#define PHILLIPS_CONSTANT       0.0081f

typedef enum ODQuadrants
{
    ODQuadrant_1_3 =  1,
    ODQuadrant_2_4 = -1
}
ODQuadrants;

float omegaf_for_k(FVector2 const * const k)
{
    return sqrtf(EARTH_ACCELERATIONf * fv2_v_length(k));
}

float amplitudef(FVector2 const * const windDirection,
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

    float amplitude = PHILLIPS_CONSTANT;
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
	    H0 = fftw_malloc(sizeof(fftw_complex) * currentSettings.resolution.x * currentSettings.resolution.y);
    }

    const IVector2 resolution = currentSettings.resolution;
    const FVector2 size = (FVector2){currentSettings.size.x, currentSettings.size.y};
    const FVector2 windDirection = (FVector2){currentSettings.windDirection.x, currentSettings.windDirection.y};

    const float n = -(resolution.x / 2.0f);
    const float m =  (resolution.y / 2.0f);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    for ( int32_t i = 0; i < resolution.x; i++ )
    {
        for ( int32_t j = 0; j < resolution.y; j++ )
        {
            const double xi_r = gaussian_fprandomnumber();
            const double xi_i = gaussian_fprandomnumber();

            const float di = i;
            const float dj = j;

            const float kx = (n + di) * MATH_2_MUL_PI * dsizex;
            const float ky = (m - dj) * MATH_2_MUL_PI * dsizey;

            const FVector2 k = {kx, ky};
            const float a = sqrtf(amplitudef(&windDirection, &k));

            H0[j + resolution.y * i][0] = MATH_1_DIV_SQRT_2 * xi_r * a;
            H0[j + resolution.y * i][1] = MATH_1_DIV_SQRT_2 * xi_i * a;
        }
    }
}

- (fftwf_complex *) generateHAtTime:(const float)time
{
    const IVector2 resolution = currentSettings.resolution;
    const FVector2 size = (FVector2){currentSettings.size.x, currentSettings.size.y};

	fftwf_complex * frequencySpectrum
        = fftw_malloc(sizeof(fftwf_complex) * resolution.x * resolution.y);

    const float n = -(resolution.x / 2.0f);
    const float m =  (resolution.y / 2.0f);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    for ( int32_t i = 0; i < resolution.x; i++ )
    {
        for ( int32_t j = 0; j < resolution.y; j++ )
        {
            const int32_t indexForK = j + resolution.y * i;
            const int32_t indexForConjugate = ((resolution.y - j) % resolution.y) + resolution.y * ((resolution.x - i) % resolution.x);

            const float di = i;
            const float dj = j;

            const float kx = (n + di) * MATH_2_MUL_PI * dsizex;
            const float ky = (m - dj) * MATH_2_MUL_PI * dsizey;

            const FVector2 k = {kx, ky};
            //const double omega = [ self omegaForK:&k ];
            const float omega = omegaf_for_k(&k);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftwf_complex expOmega = { cosf(omega * time), sinf(omega * time) };

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

    return frequencySpectrum;
}

- (fftwf_complex *) generateTimeIndependentH
{
    return [ self generateHAtTime:1.0f ];
}

- (fftwf_complex *) generateHHCAtTime:(const float)time
{
    const IVector2 resolution = currentSettings.resolution;
    const FVector2 size = (FVector2){currentSettings.size.x, currentSettings.size.y};

    const IVector2 resolutionHC = { resolution.x, (resolution.y / 2) + 1 };
    const IVector2 quadrantResolution = { resolution.x / 2, resolution.y / 2 };

	fftwf_complex * frequencySpectrumHC
        = fftw_malloc(sizeof(fftwf_complex) * resolutionHC.x * resolutionHC.y);

    //const double n = -(resolution.x / 2.0);
    //const double m =  (resolution.y / 2.0);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    // first generate quadrant 3
    // kx starts at 0 and increases
    // ky starts at 0 and decreases

    const float q3n = 0.0f;
    const float q3m = 0.0f;

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

            const float di = i;
            const float dj = j;

            const float kx = (q3n + di) * MATH_2_MUL_PI * dsizex;
            const float ky = (q3m - dj) * MATH_2_MUL_PI * dsizey;

            const FVector2 k = {kx, ky};
//            const double omega = [ self omegaForK:&k ];
            const float omega = omegaf_for_k(&k);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftwf_complex expOmega = { cosf(omega * time), sinf(omega * time) };

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

    // second generate quadrant 4
    // kx starts at -resolution.x/2
    // ky starts at 0 and decreases

    const float q4n = -(resolution.x / 2.0f);
    const float q4m = 0.0f;

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

            const float di = i;
            const float dj = j;

            const float kx = (q4n + di) * MATH_2_MUL_PI * dsizex;
            const float ky = (q4m - dj) * MATH_2_MUL_PI * dsizey;

            const FVector2 k = {kx, ky};
//            const double omega = [ self omegaForK:&k ];
            const float omega = omegaf_for_k(&k);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftwf_complex expOmega = { cosf(omega * time), sinf(omega * time) };

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

    //printf("q2\n");
    // third generate first row of quadrant 2

    const float q2n = 0.0f;
    const float q2m = resolution.y / 2.0f;

    for ( int32_t i = 0; i < quadrantResolution.x; i++ )
    {
        const int32_t iInH0 = i + quadrantResolution.x;
        const int32_t jInH0 = 0;

        const int32_t indexForKInH0 = jInH0 + (resolution.y * iInH0);

        const int32_t indexForKConjugateInH0
            = ((resolution.y - jInH0) % resolution.y) + resolution.y * ((resolution.x - iInH0) % resolution.x);

        const int32_t indexHC = quadrantResolution.y + (i * resolutionHC.y);

        const float di = i;
        const float dj = 0;

        const float kx = (q2n + di) * MATH_2_MUL_PI * dsizex;
        const float ky = (q2m - dj) * MATH_2_MUL_PI * dsizey;

        const FVector2 k = {kx, ky};
//        const double omega = [ self omegaForK:&k ];
        const float omega = omegaf_for_k(&k);

        // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
        const fftwf_complex expOmega = { cosf(omega * time), sinf(omega * time) };

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

    //printf("q1\n");

    const float q1n = -(resolution.x / 2.0f);
    const float q1m =   resolution.y / 2.0f;

    // forth generate first row of quadrant 1
    for ( int32_t i = 0; i < quadrantResolution.x; i++ )
    {
        const int32_t iInH0 = i;
        const int32_t jInH0 = 0;

        const int32_t indexForKInH0 = jInH0 + (resolution.y * iInH0);

        const int32_t indexForKConjugateInH0
            = ((resolution.y - jInH0) % resolution.y) + resolution.y * ((resolution.x - iInH0) % resolution.x);

        const int32_t indexHC = quadrantResolution.y + ((i + quadrantResolution.x) * resolutionHC.y);

        const float di = i;
        const float dj = 0;

        const float kx = (q1n + di) * MATH_2_MUL_PI * dsizex;
        const float ky = (q1m - dj) * MATH_2_MUL_PI * dsizey;

        const FVector2 k = {kx, ky};
//        const double omega = [ self omegaForK:&k ];
        const float omega = omegaf_for_k(&k);

        // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
        const fftwf_complex expOmega = { cosf(omega * time), sinf(omega * time) };

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

    return frequencySpectrumHC;
}

- (fftwf_complex *) generateTimeIndependentHHC
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

- (fftwf_complex *) generateFrequencySpectrum:(const ODSpectrumSettings)settings
                                       atTime:(const double)time
{
    currentSettings = settings;

    [ self generateH0 ];

    fftwf_complex * spectrum = [ self generateHAtTime:time ];
    [ self swapFrequencySpectrum:spectrum quadrants:ODQuadrant_1_3 ];
    [ self swapFrequencySpectrum:spectrum quadrants:ODQuadrant_2_4 ];

    lastSettings = currentSettings;

    return spectrum;
}

- (fftwf_complex *) generateFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                         atTime:(const double)time
{
    currentSettings = settings;

    [ self generateH0 ];

    fftwf_complex * spectrum = [ self generateHHCAtTime:time ];
    lastSettings = currentSettings;

    return spectrum;
}

@end

