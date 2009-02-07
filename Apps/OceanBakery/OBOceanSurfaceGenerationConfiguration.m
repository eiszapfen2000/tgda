#import "OBOceanSurfaceGenerationConfiguration.h"
#import "OBOceanSurfaceManager.h"
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
    size = iv2_alloc_init();
    windDirection = fv2_alloc_init();
    generatorName = nil;
    outputFileName = nil;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * config = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NPLOG(@"");
    NSString * resX = [[ config objectForKey:@"Resolution" ] objectAtIndex:0 ];
    NSString * resY = [[ config objectForKey:@"Resolution" ] objectAtIndex:1 ];
    resolution->x = [ resX intValue ];
    resolution->y = [ resY intValue ];
    NPLOG(@"Resolution: %d x %d",resolution->x,resolution->y);

    NSString * width  = [[ config objectForKey:@"Size" ] objectAtIndex:0 ];
    NSString * length = [[ config objectForKey:@"Size" ] objectAtIndex:1 ];
    size->x = [ width  intValue ];
    size->y = [ length intValue ];
    NPLOG(@"Size: %d km x %d km",size->x,size->y);

    generatorName = [[ config objectForKey:@"Generator" ] retain ];
    NPLOG(@"Frequency Spectrum Generator: %@",generatorName);

    NSString * windX = [[ config objectForKey:@"WindDirection" ] objectAtIndex:0 ];
    NSString * windY = [[ config objectForKey:@"WindDirection" ] objectAtIndex:1 ];
    windDirection->x = [ windX floatValue ];
    windDirection->y = [ windY floatValue ];
    NPLOG(@"Wind Direction: ( %f, %f )",windDirection->x,windDirection->y);

    id gaussianRNGConfig = [ config objectForKey:@"RNG" ];
    NSString * firstGeneratorName  = [ gaussianRNGConfig objectForKey:@"FirstGenerator"  ];
    NSString * secondGeneratorName = [ gaussianRNGConfig objectForKey:@"SecondGenerator" ];
    NSString * firstGeneratorSeed  = [ gaussianRNGConfig objectForKey:@"FirstSeed"  ];
    NSString * secondGeneratorSeed = [ gaussianRNGConfig objectForKey:@"SecondSeed" ];
    id firstGenerator  = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:firstGeneratorName  ];
    id secondGenerator = [[[ NP Core ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:secondGeneratorName ];
    [ firstGenerator  reseed:[firstGeneratorSeed  integerValue]];
    [ secondGenerator reseed:[secondGeneratorSeed integerValue]];

    gaussianRNG = [[[ NP Core ] randomNumberGeneratorManager ] gaussianGeneratorWithFirstGenerator:firstGenerator
                                                                                andSecondGenerator:secondGenerator ];


    numberOfThreads = [[ config objectForKey:@"Threads" ] intValue ];
    NPLOG(@"Number of Threads: %d",numberOfThreads);

    outputFileName = [[ config objectForKey:@"Output" ] retain ];

    return YES;
}

- (void) activate
{
    [(OBOceanSurfaceManager *)parent setCurrentConfiguration:self ];    
}

- (void) deactivate
{
    [(OBOceanSurfaceManager *)parent setCurrentConfiguration:nil ];
}

- (void) process
{
    id <OBPFrequencySpectrumGeneration> generator = [[(OBOceanSurfaceManager *)parent frequencySpectrumGenerators ] objectForKey:generatorName ];
    [ generator setSize:size ];
    [ generator setResolution:resolution ];
    [ generator setWindDirection:windDirection ];
    [ generator setGaussianRNG:gaussianRNG ];
    [ generator setNumberOfThreads:numberOfThreads ];
    [ generator generateFrequencySpectrum ];

    fftwf_complex * complexHeights = fftwf_malloc(sizeof(fftwf_complex) * resolution->x * resolution->y);

    fftwf_plan plan;
    fftwf_plan_with_nthreads(numberOfThreads);

    plan = fftwf_plan_dft_2d(resolution->x,
                             resolution->y,
                             [generator frequencySpectrum],
                             complexHeights,
                             FFTW_BACKWARD,
                             FFTW_ESTIMATE);
    fftwf_execute(plan);
    fftwf_destroy_plan(plan);

    Float * heights = ALLOC_ARRAY(Float,resolution->x*resolution->y);

    for ( Int i = 0; i < resolution->x; i++ )
    {
        for ( Int j = 0; j < resolution->y; j++ )
        {
            NSLog(@"%f %f", complexHeights[j + resolution->y * i][0], complexHeights[j + resolution->y * i][1]);
            heights[j + resolution->y * i] = complexHeights[j + resolution->y * i][0];
        }
    }

    fftwf_free(complexHeights);
}

@end
