#import "OBOceanSurfaceGenerationConfiguration.h"
#import "OBOceanSurfaceManager.h"
#import "OBOceanSurface.h"
#import "OBOceanSurfaceSlice.h"
#import "OBPFrequencySpectrumGeneration.h"
#import "NP.h"

@implementation OBOceanSurfaceGenerationConfiguration

- (id) init
{
    return [ self initWithName:@"OceanSurfaceGenerationConfiguration" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    resolution = iv2_alloc_init();
    size = fv2_alloc_init();
    windDirection = fv2_alloc_init();
    generatorName = nil;
    outputFileName = nil;
    timeStamps = NULL;

    return self;
}

- (void) dealloc
{
    iv2_free(resolution);
    fv2_free(size);
    fv2_free(windDirection);

    TEST_RELEASE(generatorName);
    TEST_RELEASE(outputFileName);
    TEST_RELEASE(gaussianRNG);

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

    NPLOG(@"");
    NSString * resX = [[ config objectForKey:@"Resolution" ] objectAtIndex:0 ];
    NSString * resY = [[ config objectForKey:@"Resolution" ] objectAtIndex:1 ];
    resolution->x = [ resX intValue ];
    resolution->y = [ resY intValue ];
    NPLOG(@"Resolution: %d x %d", resolution->x, resolution->y);

    NSString * width  = [[ config objectForKey:@"Size" ] objectAtIndex:0 ];
    NSString * length = [[ config objectForKey:@"Size" ] objectAtIndex:1 ];
    size->x = [ width  floatValue ];
    size->y = [ length floatValue ];
    NPLOG(@"Size: %f km x %f km", size->x, size->y);

    generatorName = [[ config objectForKey:@"Generator" ] retain ];
    NPLOG(@"Frequency Spectrum Generator: %@", generatorName);

    NSString * windX = [[ config objectForKey:@"WindDirection" ] objectAtIndex:0 ];
    NSString * windY = [[ config objectForKey:@"WindDirection" ] objectAtIndex:1 ];
    windDirection->x = [ windX floatValue ];
    windDirection->y = [ windY floatValue ];
    NPLOG(@"Wind Direction: ( %f, %f )", windDirection->x, windDirection->y);

    id gaussianRNGConfig = [ config objectForKey:@"RNG" ];
    NSString * firstGeneratorName  = [ gaussianRNGConfig objectForKey:@"FirstGenerator"  ];
    NSString * secondGeneratorName = [ gaussianRNGConfig objectForKey:@"SecondGenerator" ];
    NSString * firstGeneratorSeed  = [ gaussianRNGConfig objectForKey:@"FirstSeed"  ];
    NSString * secondGeneratorSeed = [ gaussianRNGConfig objectForKey:@"SecondSeed" ];

    id firstGenerator  = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:firstGeneratorName  ];
    id secondGenerator = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:secondGeneratorName ];
    [ firstGenerator  reseed:[firstGeneratorSeed  integerValue]];
    [ secondGenerator reseed:[secondGeneratorSeed integerValue]];

    gaussianRNG = [[ NPGaussianRandomNumberGenerator alloc ] initWithName:@"Gaussian"
                                                                   parent:self
                                                           firstGenerator:firstGenerator
                                                          secondGenerator:secondGenerator ];

    numberOfSlices  = [[ config objectForKey:@"Slices"  ] intValue ];
    numberOfThreads = [[ config objectForKey:@"Threads" ] intValue ];
    NPLOG(@"Number of Slices: %d", numberOfSlices);
    NPLOG(@"Number of Threads: %d", numberOfThreads);

    NSArray * timeStampArray = [ config objectForKey:@"TimeStamps" ];
    Int timeStampCount = (Int)[ timeStampArray count ];

    if ( timeStampCount != numberOfSlices )
    {
        NPLOG_WARNING(@"Timestamp element count does not match number of slices");
        numberOfSlices = timeStampCount;
    }

    timeStamps = ALLOC_ARRAY(Float, timeStampCount);
    for ( int i = 0; i < timeStampCount; i++ )
    {
        timeStamps[i] = [[ timeStampArray objectAtIndex:i ] floatValue ];
    }

    outputFileName = [[ config objectForKey:@"Output" ] retain ];

    return YES;
}

- (OBOceanSurface *) process
{
    id <OBPFrequencySpectrumGeneration> generator = [[(OBOceanSurfaceManager *)parent frequencySpectrumGenerators ] objectForKey:generatorName ];
    [ generator setSize:size ];
    [ generator setResolution:resolution ];
    [ generator setWindDirection:windDirection ];
    [ generator setGaussianRNG:gaussianRNG ];

    OBOceanSurface * oceanSurface = [[ OBOceanSurface alloc ] initWithName:@"" parent:nil resolution:resolution ];

    fftwf_plan_with_nthreads(numberOfThreads);
    fftwf_complex * complexHeights = fftwf_malloc(sizeof(fftwf_complex) * resolution->x * resolution->y);

    for ( Int i = 0; i < numberOfSlices; i++ )
    {
        [ generator generateFrequencySpectrumAtTime:timeStamps[i] ];

        fftwf_plan plan;
        plan = fftwf_plan_dft_2d(resolution->x,
                                 resolution->y,
                                 [generator frequencySpectrum],
                                 complexHeights,
                                 FFTW_BACKWARD,
                                 FFTW_ESTIMATE);
        fftwf_execute(plan);
        fftwf_destroy_plan(plan);

        Float * heights = ALLOC_ARRAY(Float,resolution->x*resolution->y);

        for ( Int j = 0; j < resolution->x; j++ )
        {
            for ( Int k = 0; k < resolution->y; k++ )
            {
                heights[k + resolution->y * j] = complexHeights[k + resolution->y * j][0];
            }
        }

        OBOceanSurfaceSlice * slice = [[ OBOceanSurfaceSlice alloc ] initWithName:[NSString stringWithFormat:@"%d", i] parent:nil ];
        [ slice setTime:timeStamps[i] ];
        [ slice setHeights:heights elementCount:(UInt)(resolution->x * resolution->y) ];
        [ oceanSurface addSlice:slice ];
        [ slice release ];
    }

    fftwf_free(complexHeights);

    return [ oceanSurface autorelease ];
}

@end
