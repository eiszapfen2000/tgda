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
    V_X(resolution) = V_Y(resolution) = -1;
    V_X(size) = V_Y(size) = -1;
    wind.x = wind.y = 0.0;
    numberOfThreads = -1;

    [ gaussianRNG setFirstGenerator:[firstRNGs objectForKey:NP_RNG_TT800] ];
    [ gaussianRNG setSecondGenerator:[secondRNGs objectForKey:NP_RNG_TT800] ];

    currentFSGTypeName = TO_FSG_PHILLIPS;
    
    resOK = NO;
    sizeOK = NO;
    rngOK = YES;
    threadsOK = NO;
}

- (BOOL) ready
{
    NSLog(@"%d %d %d %d",resOK,sizeOK,rngOK,threadsOK);

    return ( resOK && sizeOK && rngOK && threadsOK );
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
    [ dictionary setObject:[[ TOSWOPFrequencySpectrumGenerator alloc ] initWithName:TO_FSG_SWOP parent:self ] forKey:TO_FSG_SWOP ];
}

- (void) checkResolutionForReadiness
{
    if ( V_X(resolution) > 0 && V_Y(resolution) > 0 )
    {
        resOK = YES;
    }
}

- (void) checkSizeForReadiness
{
    if ( V_X(size) > 0 && V_Y(size) > 0 )
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

- (void) checkThreadsForReadiness
{
    if ( numberOfThreads > 0 )
    {
        threadsOK = YES;
    }
}

- (void) setResX:(Int)newResX
{
    V_X(resolution) = newResX;

    [ self checkResolutionForReadiness ];
}

- (void) setResY:(Int)newResY
{
    V_Y(resolution) = newResY;

    [ self checkResolutionForReadiness ];
}

- (void) setLength:(Int)newLength
{
    V_X(size) = newLength;

    [ self checkSizeForReadiness ];
}

- (void) setWidth:(Int)newWidth
{
    V_Y(size) = newWidth;

    [ self checkSizeForReadiness ];
}

- (void) setCurrentFSGTypeName:(NSString *)newCurrentFSGTypeName
{
    if ( currentFSGTypeName != newCurrentFSGTypeName )
    {
        [ currentFSGTypeName release ];
        currentFSGTypeName = [ newCurrentFSGTypeName retain ];
    }
}

- (void) setWindX:(Double)newWindX
{
    V_X(wind) = newWindX;
}

- (void) setWindY:(Double)newWindY
{
    V_Y(wind) = newWindY;
}

- (void) setNumberOfThreads:(Int)newNumberOfThreads
{
    numberOfThreads = newNumberOfThreads;

    [ self checkThreadsForReadiness ];
}

- (void) setFrequencySpectrumGeneratorParameters:(TOPhillipsFrequencySpectrumGenerator *)fsg
{
    [ fsg setResX:V_X(resolution) ];
    [ fsg setResY:V_Y(resolution) ];
    [ fsg setWidth:V_X(size) ];
    [ fsg setLength:V_Y(size) ];
    [ fsg setGaussianRNG:gaussianRNG ];
    [ fsg setWindDirection:&wind ];
    [ fsg setNumberOfThreads:numberOfThreads ];
}

- (void) brak:(TOPhillipsFrequencySpectrumGenerator *)fsg
{
    NSLog(@"thread");

    [ fsg generateFrequencySpectrum ];

    fftw_plan plan;
    fftw_plan_with_nthreads(numberOfThreads);
    plan = fftw_plan_dft_c2r_2d([fsg resX],[fsg resY],[fsg frequencySpectrum],heights,FFTW_ESTIMATE);
    fftw_execute(plan);
    fftw_destroy_plan(plan);

    NSLog(@"thread done");

    [[ NSNotificationCenter defaultCenter ] postNotificationName:@"TOOceanSurfaceGenerationDidEnd" object:self ];
}

- (void) generateHeightfield
{
    if ( [ self ready ] == YES )
    {
        TOPhillipsFrequencySpectrumGenerator * fsg = [ frequencySpectrumGenerators objectForKey:currentFSGTypeName ];
        [ self setFrequencySpectrumGeneratorParameters:fsg ];

        heights = ALLOC_ARRAY(Double,V_X(resolution)*V_Y(resolution));

        [ NSThread detachNewThreadSelector:@selector(brak:) toTarget:self withObject:fsg ];
    }
}

- (void) buildVertexArray
{

}

@end

