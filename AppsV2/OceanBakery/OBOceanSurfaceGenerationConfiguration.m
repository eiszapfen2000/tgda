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
    size.x = size.y = 0.0;
    windDirection.x = windDirection.y = 0.0;

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

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
{
    NSDictionary * config
        = [ NSDictionary dictionaryWithContentsOfFile:fileName ];

    if ( config == nil )
    {
        return NO;
    }


    fprintf(stdout, "\n");
    NSString * resX = [[ config objectForKey:@"Resolution" ] objectAtIndex:0 ];
    NSString * resY = [[ config objectForKey:@"Resolution" ] objectAtIndex:1 ];
    resolution.x = [ resX intValue ];
    resolution.y = [ resY intValue ];
    fprintf(stdout, "Resolution: %d x %d\n", resolution.x, resolution.y);

    NSString * width  = [[ config objectForKey:@"Size" ] objectAtIndex:0 ];
    NSString * length = [[ config objectForKey:@"Size" ] objectAtIndex:1 ];
    size.x = [ width  doubleValue ];
    size.y = [ length doubleValue ];
    fprintf(stdout, "Size: %f km x %f km\n", size.x, size.y);

    generatorName = [[ config objectForKey:@"Generator" ] retain ];
    fprintf(stdout, "Frequency Spectrum Generator: %s\n", [ generatorName UTF8String ]);

    NSString * windX = [[ config objectForKey:@"WindDirection" ] objectAtIndex:0 ];
    NSString * windY = [[ config objectForKey:@"WindDirection" ] objectAtIndex:1 ];
    windDirection.x = [ windX doubleValue ];
    windDirection.y = [ windY doubleValue ];
    fprintf(stdout, "Wind Direction: ( %f, %f )\n", windDirection.x, windDirection.y);

    id gaussianRNGConfig = [ config objectForKey:@"RNG" ];
    NSString * firstRNGName  = [ gaussianRNGConfig objectForKey:@"FirstGenerator"  ];
    NSString * secondRNGName = [ gaussianRNGConfig objectForKey:@"SecondGenerator" ];
    NSString * firstRNGSeed  = [ gaussianRNGConfig objectForKey:@"FirstSeed"  ];
    NSString * secondRNGSeed = [ gaussianRNGConfig objectForKey:@"SecondSeed" ];

    id firstRNG  = [[ OBRNG alloc ] initWithName:@"First RNG"  rng:firstRNGName  ];
    id secondRNG = [[ OBRNG alloc ] initWithName:@"Second RNG" rng:secondRNGName ];
    [ firstRNG  seed:[firstRNGSeed  integerValue]];
    [ secondRNG seed:[secondRNGSeed integerValue]];

    gaussianRNG = 
        [[ OBGaussianRNG alloc ]
                initWithName:@"Gaussian"
              firstGenerator:firstRNG
             secondGenerator:secondRNG ];

    DESTROY(firstRNG);
    DESTROY(secondRNG);

    numberOfSlices  = [[ config objectForKey:@"Slices"  ] integerValue ];
    numberOfThreads = [[ config objectForKey:@"Threads" ] integerValue ];
    fprintf(stdout, "Number of Slices: %lu\n",  numberOfSlices);
    fprintf(stdout, "Number of Threads: %lu\n", numberOfThreads);

    NSArray * timeStampArray = [ config objectForKey:@"TimeStamps" ];
    NSUInteger timeStampCount = [ timeStampArray count ];

    if ( timeStampCount != numberOfSlices )
    {
        fprintf(stdout, "Timestamp element count does not match number of slices\n");
        numberOfSlices = timeStampCount;
    }

    timeStamps = ALLOC_ARRAY(double, timeStampCount);
    for ( NSUInteger i = 0; i < timeStampCount; i++ )
    {
        timeStamps[i] = [[ timeStampArray objectAtIndex:i ] doubleValue ];
        fprintf(stdout, "%f\n", timeStamps[i]);
    }

    outputFileName = [[ config objectForKey:@"Output" ] retain ];

    return YES;
}

- (OBOceanSurface *) process
{
    // get matching frequency generator
    id <OBPFrequencySpectrumGeneration> generator
        = [[ oceanSurfaceManager frequencySpectrumGenerators ] objectForKey:generatorName ];

    // configure generator
    [ generator setSize:size ];
    [ generator setResolution:resolution ];
    [ generator setWindDirection:windDirection ];
    [ generator setGaussianRNG:gaussianRNG ];

    // allocate and initialise ocean surface which will
    // contain the data generated
    OBOceanSurface * oceanSurface = [[ OBOceanSurface alloc ] initWithName:@"" ];
    [ oceanSurface setResolution:resolution ];
    [ oceanSurface setSize:size ];
    [ oceanSurface setWindDirection:windDirection ];

    // set threads
    fftw_plan_with_nthreads(numberOfThreads);

    // allocate result array
    // use a fftw_complex array since I do not have the
    // balls to screw around with the half-complex stuff
    fftw_complex * complexHeights = fftw_malloc(sizeof(fftw_complex) * resolution.x * resolution.y);

    for ( NSUInteger i = 0; i < numberOfSlices; i++ )
    {
        // generate frequency spectrum for specific timestamp
        [ generator generateFrequencySpectrumAtTime:timeStamps[i] ];

        // inverse FFT on generated frequency spectrum
        fftw_plan plan;
        plan = fftw_plan_dft_2d(resolution.x,
                                resolution.y,
                                [generator frequencySpectrum],
                                complexHeights,
                                FFTW_BACKWARD,
                                FFTW_ESTIMATE);
        fftw_execute(plan);
        fftw_destroy_plan(plan);

        // allocate array for real result data
        double * heights = ALLOC_ARRAY(double, resolution.x * resolution.y);

        // write real part to result array
        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            for ( int32_t k = 0; k < resolution.y; k++ )
            {
                heights[k + resolution.y * j] = complexHeights[k + resolution.y * j][0];
            }
        }

        // allocate and initialise slice with heights
        // for current timestamp
        OBOceanSurfaceSlice * slice = [[ OBOceanSurfaceSlice alloc ] initWithName:[NSString stringWithFormat:@"%d", i ]];
        [ slice setTime:timeStamps[i] ];
        [ slice setHeights:heights numberOfElements:(uint32_t)(resolution.x * resolution.y) ];
        [ oceanSurface addSlice:slice ];
        [ slice release ];
    }

    // delete complex result array
    fftw_free(complexHeights);

    return AUTORELEASE(oceanSurface);
}

@end
