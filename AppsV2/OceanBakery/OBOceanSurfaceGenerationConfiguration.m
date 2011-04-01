#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import "OBRNG.h"
#import "OBGaussianRNG.h"
#import "OBOceanSurfaceGenerationConfiguration.h"
#import "OBOceanSurfaceManager.h"
#import "OBOceanSurface.h"
#import "OBOceanSurfaceSlice.h"
#import "OBPFrequencySpectrumGeneration.h"

@implementation OBOceanSurfaceGenerationConfiguration

- (id) init
{
    return [ self initWithName:@"OceanSurfaceGenerationConfiguration" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName manager:nil ];
}

- (id) initWithName:(NSString *)newName
            manager:(OBOceanSurfaceManager *)manager
{
    self = [ super initWithName:newName ];

    resolution.x = resolution.y = 0;
    size.x = size.y = 0.0f;
    windDirection.x = windDirection.y = 0.0f;

    generatorName = nil;
    outputFileName = nil;
    timeStamps = NULL;

    oceanSurfaceManager = manager;

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(generatorName);
    SAFE_DESTROY(outputFileName);
    SAFE_DESTROY(gaussianRNG);

    SAFE_FREE(timeStamps);

    [ super dealloc ];
}

- (NSString *) outputFileName
{
    return outputFileName;
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * config = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSLog(@"");
    NSString * resX = [[ config objectForKey:@"Resolution" ] objectAtIndex:0 ];
    NSString * resY = [[ config objectForKey:@"Resolution" ] objectAtIndex:1 ];
    resolution.x = [ resX intValue ];
    resolution.y = [ resY intValue ];
    NSLog(@"Resolution: %d x %d", resolution.x, resolution.y);

    NSString * width  = [[ config objectForKey:@"Size" ] objectAtIndex:0 ];
    NSString * length = [[ config objectForKey:@"Size" ] objectAtIndex:1 ];
    size.x = [ width  floatValue ];
    size.y = [ length floatValue ];
    NSLog(@"Size: %f km x %f km", size.x, size.y);

    generatorName = [[ config objectForKey:@"Generator" ] retain ];
    NSLog(@"Frequency Spectrum Generator: %@", generatorName);

    NSString * windX = [[ config objectForKey:@"WindDirection" ] objectAtIndex:0 ];
    NSString * windY = [[ config objectForKey:@"WindDirection" ] objectAtIndex:1 ];
    windDirection.x = [ windX floatValue ];
    windDirection.y = [ windY floatValue ];
    NSLog(@"Wind Direction: ( %f, %f )", windDirection.x, windDirection.y);

    id gaussianRNGConfig = [ config objectForKey:@"RNG" ];
    NSString * firstGeneratorName  = [ gaussianRNGConfig objectForKey:@"FirstGenerator"  ];
    NSString * secondGeneratorName = [ gaussianRNGConfig objectForKey:@"SecondGenerator" ];
    NSString * firstGeneratorSeed  = [ gaussianRNGConfig objectForKey:@"FirstSeed"  ];
    NSString * secondGeneratorSeed = [ gaussianRNGConfig objectForKey:@"SecondSeed" ];

    /*
    id firstGenerator  = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:firstGeneratorName  ];
    id secondGenerator = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:secondGeneratorName ];
    [ firstGenerator  reseed:[firstGeneratorSeed  integerValue]];
    [ secondGenerator reseed:[secondGeneratorSeed integerValue]];
    */

    id firstGenerator  = [[ OBRNG alloc ] initWithName:@"First RNG"  parameters:firstGeneratorName  ];
    id secondGenerator = [[ OBRNG alloc ] initWithName:@"Second RNG" parameters:secondGeneratorName ];
    [ firstGenerator  seed:[firstGeneratorSeed  integerValue]];
    [ secondGenerator seed:[secondGeneratorSeed integerValue]];

    gaussianRNG = 
        [[ OBGaussianRNG alloc ]
                initWithName:@"Gaussian"
              firstGenerator:firstGenerator
             secondGenerator:secondGenerator ];

    RELEASE(firstGenerator);
    RELEASE(secondGenerator);

    numberOfSlices  = [[ config objectForKey:@"Slices"  ] intValue ];
    numberOfThreads = [[ config objectForKey:@"Threads" ] intValue ];
    NSLog(@"Number of Slices: %d", numberOfSlices);
    NSLog(@"Number of Threads: %d", numberOfThreads);

    NSArray * timeStampArray = [ config objectForKey:@"TimeStamps" ];
    NSUInteger timeStampCount = [ timeStampArray count ];

    if ( timeStampCount != numberOfSlices )
    {
        NSLog(@"Timestamp element count does not match number of slices");
        numberOfSlices = timeStampCount;
    }

    timeStamps = ALLOC_ARRAY(Float, timeStampCount);
    for ( NSUInteger i = 0; i < timeStampCount; i++ )
    {
        timeStamps[i] = [[ timeStampArray objectAtIndex:i ] floatValue ];
        NSLog(@"%f", timeStamps[i]);
    }

    outputFileName = [[ config objectForKey:@"Output" ] retain ];

    return YES;
}

- (OBOceanSurface *) process
{
    id <OBPFrequencySpectrumGeneration> generator
        = [[ oceanSurfaceManager frequencySpectrumGenerators ] objectForKey:generatorName ];

    [ generator setSize:&size ];
    [ generator setResolution:&resolution ];
    [ generator setWindDirection:&windDirection ];
    [ generator setGaussianRNG:gaussianRNG ];

    OBOceanSurface * oceanSurface = [[ OBOceanSurface alloc ] initWithName:@"" ];
    [ oceanSurface setResolution:resolution ];
    [ oceanSurface setSize:size ];
    [ oceanSurface setWindDirection:windDirection ];

    fftwf_plan_with_nthreads(numberOfThreads);
    fftwf_complex * complexHeights = fftwf_malloc(sizeof(fftwf_complex) * resolution.x * resolution.y);

    for ( int32_t i = 0; i < numberOfSlices; i++ )
    {
        [ generator generateFrequencySpectrumAtTime:timeStamps[i] ];

        fftwf_plan plan;
        plan = fftwf_plan_dft_2d(resolution.x,
                                 resolution.y,
                                 [generator frequencySpectrum],
                                 complexHeights,
                                 FFTW_BACKWARD,
                                 FFTW_ESTIMATE);
        fftwf_execute(plan);
        fftwf_destroy_plan(plan);

        Float * heights = ALLOC_ARRAY(Float,resolution.x*resolution.y);

        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            for ( int32_t k = 0; k < resolution.y; k++ )
            {
                heights[k + resolution.y * j] = complexHeights[k + resolution.y * j][0];
            }
        }

        OBOceanSurfaceSlice * slice = [[ OBOceanSurfaceSlice alloc ] initWithName:[NSString stringWithFormat:@"%d", i ]];
        [ slice setTime:timeStamps[i] ];
        [ slice setHeights:heights elementCount:(uint32_t)(resolution.x * resolution.y) ];
        [ oceanSurface addSlice:slice ];
        [ slice release ];
    }

    fftwf_free(complexHeights);

    return [ oceanSurface autorelease ];
}

@end
