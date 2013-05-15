#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSPointerArray.h>
#import <Foundation/NSThread.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/Container/NSPointerArray+NPEngine.h"
#import "Core/Thread/NPSemaphore.h"
#import "Core/Timer/NPTimer.h"
#import "Core/File/NSFileManager+NPEngine.h"
#import "Core/File/NPLocalPathManager.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/NPOrthographic.h"
#import "Graphics/NPEngineGraphics.h"
#import "ODProjector.h"
#import "ODBasePlane.h"
#import "Ocean/ODPhillipsSpectrum.h"
#import "ODHeightfieldQueue.h"
#import "ODOceanEntity.h"

void print_complex_spectrum(const IVector2 resolution, fftwf_complex * spectrum)
{
    for ( int32_t j = 0; j < resolution.y; j++ )
    {
        for ( int32_t k = 0; k < resolution.x; k++ )
        {
            printf("%f %fi ", spectrum[j * resolution.x + k][0], spectrum[j * resolution.x + k][1]);
        }

        printf("\n");
    }
}

void print_half_complex_spectrum(const IVector2 resolution, fftwf_complex * spectrum)
{
    for ( int32_t j = 0; j < resolution.y; j++ )
    {
        for ( int32_t k = 0; k < ((resolution.x/2)+1); k++ )
        {
            printf("%f %fi ", spectrum[j * ((resolution.x/2)+1) + k][0], spectrum[j * ((resolution.x/2)+1) + k][1]);
        }

        printf("\n");
    }
}

static const Vector2 defaultWindDirection = {10.0, 0.5};
static const int32_t resolutions[4] = {64, 128, 256, 512};
static const NSUInteger defaultResolutionIndex = 2;
static const double OneDivSixty = 1.0 / 60.0;

@interface ODOceanEntity (Private)

- (void) startupFFTW;
- (void) shutdownFFTW;
- (void) generate:(id)argument;
- (void) transform:(id)argument;

@end

@implementation ODOceanEntity (Private)

- (void) startupFFTW
{
    NSArray * paths
            = NSSearchPathForDirectoriesInDomains(
                NSApplicationSupportDirectory,
                NSUserDomainMask,
                YES);

    // Normally only need the first path
    NSString * wisdomFolder
        = [[ paths objectAtIndex:0 ] stringByAppendingPathComponent:@"OceanDemo" ];
    
    // Create the path if it doesn't exist
    NSError * e = nil;
    BOOL success
        = [[ NSFileManager defaultManager ]
                    createDirectoryAtPath:wisdomFolder
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&e ];

    BOOL obtainedWisdom = NO;

    NSString * wisdomFileName
        = [ wisdomFolder stringByAppendingPathComponent:@"wisdom" ];

    if ( [[ NSFileManager defaultManager ] isFile:wisdomFileName ] == YES )
    {
        printf("Loading FFTW wisdom...\n");

        if ( fftw_import_wisdom_from_filename([ wisdomFileName UTF8String ]) != 0 )
        {
            printf("FFTW Wisdom obtained.\n");
            obtainedWisdom = YES;
        }

        if ( obtainedWisdom == NO )
        {
            printf("Unable to import FFTW Wisdom.\n");
        }
    }
    else
    {
        [[ NSFileManager defaultManager ] createEmptyFileAtPath:wisdomFileName ];
    }

    for ( uint32_t i = 0; i < ODOCEANENTITY_NUMBER_OF_RESOLUTIONS; i++)
    {
        const size_t arraySize = resolutions[i] * resolutions[i];

        float * realTarget = fftwf_alloc_real(arraySize);
        fftwf_complex * source = fftwf_alloc_complex(arraySize);
        fftwf_complex * complexTarget = fftwf_alloc_complex(arraySize);

        halfComplexPlans[i]
            = fftwf_plan_dft_c2r_2d(resolutions[i],
                                    resolutions[i],
                                    source,
                                    realTarget,
                                    FFTW_MEASURE);

        complexPlans[i]
            = fftwf_plan_dft_2d(resolutions[i],
                                resolutions[i],
                                source,
                                complexTarget,
                                FFTW_BACKWARD,
                                FFTW_MEASURE);


        fftwf_free(source);
        fftwf_free(complexTarget);
        fftwf_free(realTarget);
    }

    if ( obtainedWisdom == NO )
    {
        if ( fftw_export_wisdom_to_filename([ wisdomFileName UTF8String ]) != 0 )
        {
            printf("FFTW Wisdom stored\n");
        }
    }
}

- (void) shutdownFFTW
{
    for ( uint32_t i = 0; i < ODOCEANENTITY_NUMBER_OF_RESOLUTIONS; i++ )
    {
        if ( halfComplexPlans[i] != NULL )
        {
            fftwf_destroy_plan(halfComplexPlans[i]);
        }

        if ( complexPlans[i] != NULL )
        {
            fftwf_destroy_plan(complexPlans[i]);
        }
    }

    fftw_forget_wisdom();
}

- (void) generate:(id)argument
{
    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    NPTimer * timer = [[ NPTimer alloc ] initWithName:@"Thread Timer" ];
    ODPhillipsSpectrum * s = [[ ODPhillipsSpectrum alloc ] init ];

    float generationTime = 0.0;

    while ( [[ NSThread currentThread ] isCancelled ] == NO )
    {    
        [ generateCondition lock ];

        while ( generateData == NO )
        {
            [ generateCondition wait ];
        }

        [ generateCondition unlock ];

        NSAutoreleasePool * innerPool = [ NSAutoreleasePool new ];

        if ( [[ NSThread currentThread ] isCancelled ] == NO )
        {
            ODSpectrumSettings settings;
            NSUInteger resIndex;

            {
                [ resultQueueMutex lock ];
                settings = spectrumSettings;
                resIndex = resolutionIndex;
                [ resultQueueMutex unlock ];
            }

            const int32_t res = resolutions[resIndex];
            settings.resolution = (IVector2){res, res};

            OdHeightfieldData * result = NULL;

            {
                [ resultQueueMutex lock ];
                result = heightfield_alloc_init_with_resolution_and_size(settings.resolution, settings.size);
                [ resultQueueMutex unlock ];
            }

            fftwf_complex * complexHeights   = fftwf_alloc_complex(res * res);
            fftwf_complex * complexGradientX = fftwf_alloc_complex(res * res);
            fftwf_complex * complexGradientZ = fftwf_alloc_complex(res * res);

            [ timer update ];

            result->timeStamp = generationTime;

            OdFrequencySpectrumFloat complexSpectrum
                = [ s generateFloatFrequencySpectrum:settings atTime:generationTime ];

            generationTime += 1.0f/60.0f;
            //NSLog(@"%f", generationTime);

            [ timer update ];

            const float fpsHC = [ timer frameTime ];

            /*
            printf("spectrum\n");
            print_complex_spectrum(settings.resolution, complexSpectrum.waveSpectrum);
            fflush(stdout);
            printf("spectrumHC\n");
            print_half_complex_spectrum(settings.resolution, halfcomplexSpectrum);
            fflush(stdout);
            */

            /*
            [ timer update ];
            fftwf_plan plan;
            plan = fftwf_plan_dft_2d(settings.resolution.x,
                                    settings.resolution.y,
                                    complexSpectrum,
                                    complexHeights,
                                    FFTW_BACKWARD,
                                    FFTW_ESTIMATE);

            fftwf_execute(plan);
            fftwf_destroy_plan(plan);
            [ timer update ];

            const float fpsIFFTC = [ timer frameTime ];
            */

            [ timer update ];

            //fftwf_execute_dft_c2r(halfComplexPlans[resIndex], halfcomplexSpectrum.waveSpectrum, result->data32f);
            fftwf_execute_dft(complexPlans[resIndex], complexSpectrum.waveSpectrum, complexHeights);
            fftwf_execute_dft(complexPlans[resIndex], complexSpectrum.gradientX, complexGradientX);
            fftwf_execute_dft(complexPlans[resIndex], complexSpectrum.gradientZ, complexGradientZ);

            [ timer update ];

            //NSLog(@"%f", [timer frameTime]);

            const int32_t numberOfElements = res * res;
            for ( int32_t i = 0; i < numberOfElements; i++ )
            {
                result->heights32f[i] = complexHeights[i][0];
                result->gradientX[i]  = complexGradientX[i][0];
                result->gradientZ[i]  = complexGradientZ[i][0];
            }

            [ timer update ];

            const float fpsIFFTHC = [ timer frameTime ];
            heightfield_hf_compute_min_max(result);
            heightfield_hf_compute_min_max_gradients(result);

            [ timer update ];
            
            //NSLog(@"MinX: %f MaxX: %f MinZ: %f MaxZ: %f", result->minGradientX, result->maxGradientX, result->minGradientZ, result->maxGradientZ);

            fftwf_free(complexSpectrum.waveSpectrum);
            fftwf_free(complexSpectrum.gradientX);
            fftwf_free(complexSpectrum.gradientZ);
            fftwf_free(complexHeights);
            fftwf_free(complexGradientX);
            fftwf_free(complexGradientZ);


            NSUInteger queueCount = 0;
            {
                [ resultQueueMutex lock ];
                [ resultQueue addHeightfield:result ];
                queueCount = [ resultQueue count ];
                [ resultQueueMutex unlock ];
            }

            //NSLog(@"%lu", queueCount);

            [ generateCondition lock ];
            generateData = ( queueCount < 16 ) ? YES : NO;
            [ generateCondition unlock ];
        }

        DESTROY(innerPool);
    }    

    DESTROY(s);
    DESTROY(timer);
    DESTROY(pool);
}

- (void) transform:(id)argument
{
    NSLog(@"Transform");
}

@end

@implementation ODOceanEntity

- (id) init
{
    return [ self initWithName:@"ODOceanEntity" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    resultQueueMutex = [[ NSLock alloc ] init ];
    generateCondition = [[ NSCondition alloc ] init ];
    transformCondition = [[ NSCondition alloc ] init ];

    generateData = NO;
    transformData = NO;

    lastResolutionIndex = ULONG_MAX;
    resolutionIndex = defaultResolutionIndex;

    lastWindDirection = (Vector2){DBL_MAX, DBL_MAX};
    windDirection = defaultWindDirection;

    resultQueue = [[ ODHeightfieldQueue alloc ] init ];

    projector = [[ ODProjector alloc ] initWithName:@"Projector" ];
    basePlane = [[ ODBasePlane alloc ] initWithName:@"BasePlane" ];
    [ basePlane setProjector:projector ];

    heightfield = [[ NPTexture2D alloc ] initWithName:@"Height Texture" ];
    gradientX = [[ NPTexture2D alloc ] initWithName:@"Height Texture X Gradient" ];
    gradientZ = [[ NPTexture2D alloc ] initWithName:@"Height Texture Z Gradient" ];

    [ heightfield setTextureFilter:NpTexture2DFilterLinear ];
    [ gradientX   setTextureFilter:NpTexture2DFilterLinear ];
    [ gradientZ   setTextureFilter:NpTexture2DFilterLinear ];

    [ heightfield setTextureWrap:NpTextureWrapRepeat ];
    [ gradientX   setTextureWrap:NpTextureWrapRepeat ];
    [ gradientZ   setTextureWrap:NpTextureWrapRepeat ];

    timeStamp =  DBL_MAX;

    heightRange    = (FVector2){.x = FLT_MAX, .y = -FLT_MAX};
    gradientXRange = (FVector2){.x = 0.0f, .y = 1.0f};
    gradientZRange = (FVector2){.x = 0.0f, .y = 1.0f};

    return self;
}

- (void) dealloc
{
    DESTROY(heightfield);
    DESTROY(gradientX);
    DESTROY(gradientZ);
    DESTROY(projector);
    DESTROY(basePlane);
    DESTROY(resultQueue);
    DESTROY(resultQueueMutex);
    DESTROY(generateCondition);
    DESTROY(transformCondition);

    [ super dealloc ];
}

- (void) start
{
    [ self startupFFTW ];

    if ( generatorThread == nil )
    {
        generatorThread
            = [[ NSThread alloc ]
                    initWithTarget:self
                          selector:@selector(generate:)
                            object:nil ];
    }

    if ( transformThread == nil )
    {
        transformThread
            = [[ NSThread alloc ]
                    initWithTarget:self
                          selector:@selector(transform:)
                            object:nil ];
    }

    [ generatorThread start ];
    [ transformThread start ];
} 

- (void) stop
{
    if ( generatorThread != nil )
    {
        if ( [ generatorThread isExecuting ] == YES )
        {
            // cancel thread
            [ generatorThread cancel ];

            // wake thread up a last time so it exits its main loop
            [ generateCondition lock ];
            generateData = YES;
            [ generateCondition signal ];
            [ generateCondition unlock ];

            // since NSThreads are created in detached mode
            // we have to join by hand
            while ( [ generatorThread isFinished ] == NO )
            {
                struct timespec request;
                request.tv_sec = (time_t)0;
                request.tv_nsec = 1000000L;
                nanosleep(&request, 0);
            }
        }

        DESTROY(generatorThread);
    }

    if ( transformThread != nil )
    {
        if ( [ transformThread isExecuting ] == YES )
        {
            // cancel thread
            [ transformThread cancel ];

            // wake thread up a last time so it exits its main loop
            [ transformCondition lock ];
            transformData = YES;
            [ transformCondition signal ];
            [ transformCondition unlock ];

            // since NSThreads are created in detached mode
            // we have to join by hand
            while ( [ transformThread isFinished ] == NO )
            {
                struct timespec request;
                request.tv_sec = (time_t)0;
                request.tv_nsec = 1000000L;
                nanosleep(&request, 0);
            }
        }

        DESTROY(transformThread);
    }

    [ self shutdownFFTW ];
}

- (ODProjector *) projector
{
    return projector;
}

- (ODBasePlane *) basePlane
{
    return basePlane;
}

- (NPTexture2D *) heightfield
{
    return heightfield;
}

- (FVector2) heightRange
{
    return heightRange;
}

- (void) setCamera:(ODCamera *)newCamera
{
    [ projector setCamera:newCamera ];
}

- (void) update:(const double)frameTime
{
    //NSLog(@"update");
    
    [ projector update:frameTime ];
    [ basePlane update:frameTime ];

    const double totalElapsedTime
        = [[[ NPEngineCore instance ] timer ] totalElapsedTime ];

    /*
    // time did not advance more than half of 1/60
    // simply use current heightfield again
    if ((timeStamp + 0.5 * OneDivSixty) <= totalElapsedTime)
    {
        NSLog(@"EARLY %f %f", timeStamp, totalElapsedTime);
        return;
    }
    */

    NSUInteger queueCount = 0;
    OdHeightfieldData * hf = NULL;

    {
        [ resultQueueMutex lock ];

        queueCount = [ resultQueue count ];

        // in case spectrum generation settings changed
        // update the generator thread's' settings and clear
        // the resultQueue of still therein residing data
        if ( windDirection.x != lastWindDirection.x
             || windDirection.y != lastWindDirection.y
             || resolutionIndex != lastResolutionIndex )
        {
            spectrumSettings.windDirection = windDirection;
            spectrumSettings.size = (Vector2){5.0, 5.0};

            //const int32_t res = resolutions[resolutionIndex];
            //spectrumSettings.resolution = (IVector2){res, res};

            lastWindDirection = windDirection;
            lastResolutionIndex = resolutionIndex;

            [ resultQueue removeAllHeightfields ];

            queueCount = 0;
        }

        //printf("Queue %lu\n", queueCount);

        // get heightfield data
        if ( queueCount != 0 )
        {
            //NSLog(@"SEARCH %f", totalElapsedTime);

            NSUInteger f = NSNotFound;
            double queueMinTimeStamp =  DBL_MAX;
            double queueMaxTimeStamp = -DBL_MAX;

            for ( NSUInteger i = 0; i < queueCount; i++ )
            {
                OdHeightfieldData * h = [ resultQueue heightfieldAtIndex:i ];
                //NSLog(@"TS %f", h->timeStamp);
                const double x = totalElapsedTime - 0.5 * OneDivSixty;
                const double y = totalElapsedTime + 0.5 * OneDivSixty;
                const double hTimeStamp = h->timeStamp;

                queueMinTimeStamp = MIN(queueMinTimeStamp, hTimeStamp);
                queueMaxTimeStamp = MAX(queueMaxTimeStamp, hTimeStamp);

                if ( hTimeStamp >= x && hTimeStamp < y )
                {
                    f = i;
                    //NSLog(@"FOUND %lu", f);
                }
            }

            //NSLog(@"MIN %f MAX %f", queueMinTimeStamp, queueMaxTimeStamp);

            if ( f != NSNotFound )
            {
                hf = [ resultQueue heightfieldAtIndex:f ];

                NSRange range = NSMakeRange(0, f);
                [ resultQueue removeHeightfieldsInRange:range ];
                //NSLog(@"Range %lu %lu", range.location, range.length);                
            }
            else
            {
                //NSLog(@"Not found");
                hf = [ resultQueue heightfieldAtIndex:0 ];
            }
        }

        queueCount = [ resultQueue count ];
        [ resultQueueMutex unlock ];
    }

    // update condition variable
    // in case we have 16 or more heightfields in our buffer
    // the generating thread will be put to sleep
    {
        [ generateCondition lock ];
        generateData = ( queueCount < 16 ) ? YES : NO;
        [ generateCondition signal ];
        [ generateCondition unlock ];
    }

    // update texture and associated min max
    if ( hf != NULL )
    {
        timeStamp = hf->timeStamp;

        heightRange    = (FVector2){.x = hf->minHeight,    .y = hf->maxHeight   };
        gradientXRange = (FVector2){.x = hf->minGradientX, .y = hf->maxGradientX};
        gradientZRange = (FVector2){.x = hf->minGradientZ, .y = hf->maxGradientZ};

        //printf("stamp %f\n", hf->timeStamp);

        const NSUInteger numberOfBytes
            = hf->resolution.x * hf->resolution.y * sizeof(float);

        NSData * textureData
            = [ NSData dataWithBytesNoCopy:hf->heights32f
                                    length:numberOfBytes
                              freeWhenDone:NO ];

        NSData * gradientXData
            = [ NSData dataWithBytesNoCopy:hf->gradientX
                                    length:numberOfBytes
                              freeWhenDone:NO ];

        NSData * gradientZData
            = [ NSData dataWithBytesNoCopy:hf->gradientZ
                                    length:numberOfBytes
                              freeWhenDone:NO ];

        [ heightfield generateUsingWidth:hf->resolution.x
                                  height:hf->resolution.y
                             pixelFormat:NpImagePixelFormatR
                              dataFormat:NpImageDataFormatFloat32
                                 mipmaps:NO
                                    data:textureData ];

        [ gradientX generateUsingWidth:hf->resolution.x
                                height:hf->resolution.y
                           pixelFormat:NpImagePixelFormatR
                            dataFormat:NpImageDataFormatFloat32
                               mipmaps:NO
                                  data:gradientXData ];

        [ gradientZ generateUsingWidth:hf->resolution.x
                                height:hf->resolution.y
                           pixelFormat:NpImagePixelFormatR
                            dataFormat:NpImageDataFormatFloat32
                               mipmaps:NO
                                  data:gradientZData ];

        //NSLog(@"%f %f", totalElapsedTime, timeStamp);
    }
}

- (void) renderBasePlane
{
    [ basePlane render ];
}

/*
[[[ NPEngineGraphics instance ] orthographic ] activate ];
[[[ NPEngineGraphics instance ] textureBindingState ] setTexture:heightfield texelUnit:0 ];
[[[ NPEngineGraphics instance ] textureBindingState ] activate ];
[[ effect techniqueWithName:@"texture" ] activate ];
glBegin(GL_QUADS);
    glVertexAttrib2f(NpVertexStreamTexCoords0, 0.0f, 1.0f);
    glVertex2i(0, 0);
    glVertexAttrib2f(NpVertexStreamTexCoords0, 1.0f, 1.0f);
    glVertex2i(1, 0);
    glVertexAttrib2f(NpVertexStreamTexCoords0, 1.0f, 0.0f);
    glVertex2i(1, 1);
    glVertexAttrib2f(NpVertexStreamTexCoords0, 0.0f, 0.0f);
    glVertex2i(0, 1);
glEnd();

[[[ NPEngineGraphics instance ] orthographic ] deactivate ];
*/

@end

