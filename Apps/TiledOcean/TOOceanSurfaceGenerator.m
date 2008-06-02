#import <AppKit/AppKit.h>

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
    V_X(size) = V_Y(size) = -1.0;
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

- (void) setLength:(Double)newLength
{
    V_X(size) = newLength;

    [ self checkSizeForReadiness ];
}

- (void) setWidth:(Double)newWidth
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
    NSAutoreleasePool * apool = [[ NSAutoreleasePool alloc ] init ];

    //[[ NSNotificationCenter defaultCenter ] postNotificationName:@"TOOceanSurfaceGenerationDidStart" object:self ];

    NSLog(@"thread");

    [ fsg generateFrequencySpectrum ];

    fftw_plan plan;
    fftw_plan_with_nthreads(numberOfThreads);
    plan = fftw_plan_dft_c2r_2d([fsg resX],[fsg resY],[fsg frequencySpectrum],heights,FFTW_ESTIMATE);
    fftw_execute(plan);
    fftw_destroy_plan(plan);

    NSLog(@"thread done");

    NSMutableDictionary * d = [[ NSMutableDictionary alloc ] init ];
    [ d setObject:fsg forKey:@"FSG" ];
    NSNotification * anot = [ NSNotification notificationWithName:@"TOOceanSurfaceGenerationDidEnd" object:self userInfo:d ];

    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:)
                    withObject:anot
                 waitUntilDone:NO];

    [ d release ];

    [ apool release ];
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

- (Float *) buildVertexArrayUsingFSG:(TOFrequencySpectrumGenerator *)fsg
{
    NSLog(@"creating vertex array");
    //NSLog(@"%d %d %d",[fsg resX],[fsg resY], [fsg resX] * [fsg resY] * 3);
    Float * vertexArray = ALLOC_ARRAY(Float, [fsg resX] * [fsg resY] * 3);
//    Float xStep = (Float)V_X(resolution) / (Float)V_X(size);
    Float xStep = (Float)V_X(size) / (Float)V_X(resolution);
    Float yStep = (Float)V_Y(size) / (Float)V_Y(resolution);

    Int resY = [ fsg resY ];
    Int resX = [ fsg resX ];

    Int index = 0;

    for ( Int i = 0; i < resX; i++ )
    {
        for ( Int j = 0; j < resY; j++ )
        {
            index = (resY * i + j) * 3;
            //NSLog(@"%d",index);
            vertexArray[index]   = (Float)i * xStep;
            vertexArray[index+1] = (Float)heights[(resY * i + j)];
            vertexArray[index+2] = (Float)j * yStep;
			//NSLog(@"%f %f %f",vertexArray[index],vertexArray[index+1],vertexArray[index+2]);
        }
    }
    NSLog(@"done");

    return vertexArray;
}

- (Int *) buildIndexArrayUsingFSG:(TOFrequencySpectrumGenerator *)fsg
{
    NSLog(@"build index array");
    Int resY = [ fsg resY ];
    Int resX = [ fsg resX ];

    Int triangleCount = (resX-1) * (resY-1) * 2;
    //NSLog(@"tris: %d",triangleCount);
    Int indexCount = triangleCount * 3;
    //NSLog(@"indices: %d",indexCount);

    Int * indexArray = ALLOC_ARRAY(Int, indexCount);

    Int baseIndex;
    Int indicesQuad[4];
    Float heightDifferenceOne;
    Float heightDifferenceTwo;

    for ( Int i = 0; i < (resX-1); i++ )
    {
        for ( Int j = 0; j < (resY-1); j++ )
        {
            //NSLog(@"%d %d",i,j);
            baseIndex = (i*(resY-1) + j) * 6;
            //NSLog(@"%d",baseIndex);

            indicesQuad[0] = i*resY + j;
            indicesQuad[1] = i*resY + j + 1;
            indicesQuad[2] = (i+1)*resY + j;
            indicesQuad[3] = (i+1)*resY + j + 1;
            //NSLog(@"%d %d %d %d",indicesQuad[0],indicesQuad[1],indicesQuad[2],indicesQuad[3]);

            heightDifferenceOne = (Float)fabs(heights[indicesQuad[0]] - heights[indicesQuad[3]]);
            heightDifferenceTwo = (Float)fabs(heights[indicesQuad[2]] - heights[indicesQuad[1]]);

            //First Triangle
            indexArray[baseIndex] = indicesQuad[0];
            indexArray[baseIndex+1] = indicesQuad[1];

            if ( heightDifferenceOne < heightDifferenceTwo )
            {
                indexArray[baseIndex+2] = indicesQuad[2];
                indexArray[baseIndex+5] = indicesQuad[1];
            }
            else
            {
                indexArray[baseIndex+2] = indicesQuad[3];
                indexArray[baseIndex+5] = indicesQuad[0];
            }

            //Second Triangle
            indexArray[baseIndex+3] = indicesQuad[3];
            indexArray[baseIndex+4] = indicesQuad[2];
            //NSLog(@"lol");
        }
    }

    NSLog(@"done");

    return indexArray;
}

@end

