#import "TOFrequencySpectrumGenerator.h"
#import "Core/RandomNumbers/NPGaussianRandomNumberGenerator.h"

@implementation TOFrequencySpectrumGenerator

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"TOFrequencySpectrumGenerator" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    [ self reset ];

    return self;
}

- (void) dealloc
{
    [ self resetFrequencySpectrum ];

    [ super dealloc ];
}

- (void) reset
{
    resX = resY = -1;
    width = length = -1;

    if ( gaussianRNG != nil )
    {
        [ gaussianRNG release ];
        gaussianRNG = nil;
    }

    [ self resetFrequencySpectrum ];

    resOK = NO;
    sizeOK = NO;
    rngOK = NO;
}

- (BOOL) ready
{
    return ( resOK && sizeOK && rngOK );
}

- (void) checkResolutionForReadiness
{
    if ( resX > 0 && resY > 0 )
    {
        resOK = YES;
    }
}

- (void) checkSizeForReadiness
{
    if ( length > 0 && width > 0 )
    {
        sizeOK = YES;
    }
}

- (void) checkGaussianRNGForReadiness
{
    if ( gaussianRNG != nil )
    {
        if ( [ gaussianRNG ready ] == YES )
        {
            rngOK = YES;
        }
    }
}

- (void) checkForReadiness
{
    [ self checkSizeForReadiness ];
    [ self checkResolutionForReadiness ];
    [ self checkGaussianRNGForReadiness ];
}

- (void) setResX:(Int)newResX
{
    resX = newResX;

    [ self checkResolutionForReadiness ];
}

- (void) setResY:(Int)newResY
{
    resY = newResY;

    [ self checkResolutionForReadiness ];
}

- (void) setWidth:(Int)newWidth
{
    width = newWidth;

    [ self checkSizeForReadiness ];
}

- (void) setLength:(Int)newLength
{
    length = newLength;

    [ self checkSizeForReadiness ];
}

- (void) setGaussianRNG:(NPGaussianRandomNumberGenerator *)newGaussianRNG
{
    if ( gaussianRNG != newGaussianRNG )
    {
        [ gaussianRNG release ];
        gaussianRNG = [ newGaussianRNG retain ];
    }

    [ self checkGaussianRNGForReadiness ];
}

- (void) resetFrequencySpectrum
{
    if ( frequencySpectrum != NULL )
    {
        fftw_free(frequencySpectrum);
        frequencySpectrum = NULL;
    }
}

- (fftw_complex *) frequencySpectrum
{
    return frequencySpectrum;
}

@end

@implementation TOPhillipsFrequencySpectrumGenerator

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"TOPhillipsFrequencySpectrumGenerator" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    H0 = NULL;
    H = NULL;

    [ self reset ];

    return self;
}

- (void) dealloc
{
    [ self resetH ];
    [ self resetH0 ];

    [ super dealloc ];
}

- (void) resetH0
{
    if ( H0 != NULL )
    {
        fftw_free(H0);
        H0 = NULL;
    }
}

- (void) resetH
{
    if ( H != NULL )
    {
        fftw_free(H);
        H = NULL;
    }
}

- (void) reset
{
    U10 = -1;
    V_X(windDirection) = V_Y(windDirection) = 0.0;
    windOK = NO;

    alpha = PHILLIPS_CONSTANT;

    [ self resetH ];
    [ self resetH0 ];

    [ super reset ];
}

- (BOOL) ready
{
    return ( [ super ready ] && windOK );
}

- (void) checkWindDirectionForReadiness
{
    if ( V_X(windDirection) != 0.0 && V_Y(windDirection) != 0.0 )
    {
        windOK = YES;
    }
}

- (void) checkForReadiness
{
    [ super checkForReadiness ];

    [ self checkWindDirectionForReadiness ];
}

- (void) setWindDirection:(Vector2 *)newWindDirection
{
    windDirection = *newWindDirection;

    [ self checkWindDirectionForReadiness ];
}

- (Double) indexToKx:(Int)index
{
    Double n = -(resX / 2.0);
    n = n + (Double)index;

    return (MATH_2_MUL_PI * n) / width;
}

- (Double) indexToKy:(Int)index
{
    Double m = -(resY / 2.0);
    m = m + (Double)index;

    return (MATH_2_MUL_PI * m) / length;
}

- (Double) getAmplitudeAt:(Vector2 *)k
{
    Double kSquareLength = v2_v_square_length(k);
    Double windDirectionSquareLength = v2_v_square_length(&windDirection);

    Vector2 windDirectionNormalised;
    v2_v_normalise_v(&windDirection, &windDirectionNormalised);

    Vector2 kNormalised;
    v2_v_normalise_v(k, &kNormalised);

    Double L = windDirectionSquareLength / EARTH_ACCELERATION;

    Double amplitude = PHILLIPS_CONSTANT;
    amplitude = amplitude * ( 1.0 / (kSquareLength * kSquareLength) );
    amplitude = amplitude * exp( -1.0 / (kSquareLength * L * L) );
    amplitude = amplitude * pow(v2_vv_dot_product(&kNormalised, &windDirectionNormalised), 2.0);

    return amplitude;
}

- (void) generateH0
{
    Double xi_r, xi_i, a;
    Vector2 k;

	if ( !H0 )
	{
		H0 = (fftw_complex *)fftw_malloc(sizeof(fftw_complex)*resX*resY);
	}

    for ( Int i = 0; i < resX; i++ )
    {
        for ( Int j = 0; j < resY; j++ )
        {
			xi_r = [ gaussianRNG nextGaussianFPRandomNumber ];
			xi_i = [ gaussianRNG nextGaussianFPRandomNumber ];

            k.x = [ self indexToKx:i ];
            k.y = [ self indexToKy:j ];

            a = sqrt([ self getAmplitudeAt:&k ]);

			H0[j + resY * i][0] = MATH_1_DIV_SQRT_2 * xi_r * a;
			H0[j + resY * i][1] = MATH_1_DIV_SQRT_2 * xi_i * a;
        }
    }
}

/*- (void) generateH
{
    int i, j, index;
    int ni, nj, nindex;
    ArFFTReal e1r, e1i, e2r, e2i, c1r, c1i, c2r, c2i;
    Vec2D k;
    double w;

    for ( Int i = 0; i < gridRes / 2; i++ )
    {
        for ( j = 0; j < gridRes; j++ )
        {
            index = i * gridRes + j;

            ni = (gridRes - 1) - i;
            nj = (gridRes - 1) - j;
            nindex = ni * gridRes + nj;

            XC(k) = [ self index_to_k : i ];
            //printf("index_to_k %f\n",XC(k));
            YC(k) = [ self index_to_k : j ];
            //printf("index_to_k %f\n",YC(k));

            w = [ self k_to_omega : &k ];
            //printf("k_to_omega %f\n",w);

            e1r = cos(w * t);
            e1i = sin(w * t);

            e2r = e1r;
            e2i = -e1i;

            c1r = H0r[index] * e1r - H0i[index] * e1i;
            c1i = H0r[index] * e1i + H0i[index] * e1r;

            c2r = H0r[nindex] * e2r - H0i[nindex] * e2i;
            c2i = H0r[nindex] * e2i + H0i[nindex] * e2r;

            Hr[index] = c1r + c2r;
            Hi[index] = c1i + c2i;
            //printf("Hr %f Hi %f\n",Hr[index],Hi[index]);

            Hr[nindex] = Hr[index];
            Hi[nindex] = -Hi[index];
            //printf("n Hr %f Hi %f\n",Hr[nindex],Hi[nindex]);
        }
    }
}*/

- (void) generateFrequencySpectrum
{
    if ( [ self ready ] == YES )
    {
        [ self generateH0 ];
    }
}

@end
