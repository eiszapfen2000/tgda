#import "TOOceanSurfaceGenerator.h"
#import "TOFrequencySpectrumGenerator.h"

#import "Core/RandomNumbers/NPRandomNumberGenerator.h"
#import "Core/RandomNumbers/NPGaussianRandomNumberGenerator.h"
#import "Core/RandomNumbers/NPRandomNumberGeneratorManager.h"
#import "Core/NPEngineCore.h"

@implementation TOOceanSurfaceGenerator

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"TOOceanSurfaceGenerator" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    firstRNGs = [[ NSMutableDictionary alloc ] init ];
    secondRNGs = [[ NSMutableDictionary alloc ] init ];

    [ self createRNGsForDictionary:firstRNGs ];
    [ self createRNGsForDictionary:secondRNGs ];

    gaussianRNG = [[[[ NPEngineCore instance ] randomNumberGeneratorManager ] gaussianGenerator ] retain ];

    frequencySpectrumGenerators = [[ NSMutableDictionary alloc ] init ];
    [ self createFSGsForDictionary:frequencySpectrumGenerators ];

    [ self reset ];

    return self;
}

- (void) dealloc
{
    [ firstRNGs release ];
    [ secondRNGs release ];
    [ gaussianRNG release ];

    [ super dealloc ];
}

- (void) reset
{
    resX = resY = -1;
    length = width = -1;

    [ gaussianRNG setFirstGenerator:[firstRNGs objectForKey:NP_RNG_TT800] ];
    [ gaussianRNG setSecondGenerator:[secondRNGs objectForKey:NP_RNG_TT800] ];
    
    ready = NO;
}

- (void) createRNGsForDictionary:(NSMutableDictionary *)dictionary
{
    [ dictionary setObject:[[[ NPEngineCore instance ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_TT800 ]
                    forKey:NP_RNG_TT800 ];

    [ dictionary setObject:[[[ NPEngineCore instance ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_CTG ]
                    forKey:NP_RNG_CTG ];

    [ dictionary setObject:[[[ NPEngineCore instance ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_MRG ]
                    forKey:NP_RNG_MRG ];

    [ dictionary setObject:[[[ NPEngineCore instance ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_CMRG ]
                    forKey:NP_RNG_CMRG ];
}

- (void) createFSGsForDictionary:(NSMutableDictionary *)dictionary
{
    [ dictionary setObject:[[ TOPhillipsFrequencySpectrumGenerator alloc ] initWithName:TO_FSG_PHILLIPS parent:self ] forKey:TO_FSG_PHILLIPS ];
}

- (Int) resX
{
    return resX;
}

- (void) setResX:(Int)newResX
{
    resX = newResX;
}

- (Int) resY
{
    return resY;
}

- (void) setResY:(Int)newResY
{
    resY = newResY;
}

- (Int) length
{
    return length;
}

- (void) setLength:(Int)newLength
{
    length = newLength;
}

- (Int) width
{
    return width;
}

- (void) setWidth:(Int)newWidth
{
    width = newWidth;
}

- (void) generateHeightfield
{
    Vector2 wind;
    wind.x = 10.0;
    wind.y = 9.0;

    TOPhillipsFrequencySpectrumGenerator * fsg = [ frequencySpectrumGenerators objectForKey:TO_FSG_PHILLIPS ];
    [ fsg setResX:resX ];
    [ fsg setResY:resY ];
    [ fsg setWidth:width ];
    [ fsg setLength:length ];
    [ fsg setGaussianRNG:gaussianRNG ];
    [ fsg setWindDirection:&wind ];
    [ fsg generateFrequencySpectrum ];

    heights = ALLOC_ARRAY(Double,resX*resY);

    fftw_plan plan;
    plan = fftw_plan_dft_c2r_2d(resX,resY,[fsg frequencySpectrum],heights,FFTW_ESTIMATE);

    NSLog(@"execute");
    fftw_execute(plan);
    NSLog(@"done");
    fftw_destroy_plan(plan);
}

@end

