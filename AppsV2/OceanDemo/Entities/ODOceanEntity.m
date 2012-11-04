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


// TODO: use a freelist for instances of OdHeightfieldData
typedef struct
{
    IVector2 resolution;
    Vector2 size;
    double timeStamp;
    float * data32f;
    float dataMin;
    float dataMax;
}
OdHeightfieldData;

static const Vector2 defaultWindDirection = {10.0, 0.5};
static const int32_t resolutions[4] = {64, 128, 256, 512};
static const NSUInteger defaultResolutionIndex = 3;
static const double OneDivSixty = 1.0 / 60.0;

@interface ODOceanEntity (Private)

- (void) startupFFTW;
- (void) shutdownFFTW;
- (void) generate:(id)argument;

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

        float * target = ALLOC_ARRAY(float, arraySize);
        fftwf_complex * source = fftwf_malloc(sizeof(fftwf_complex) * arraySize);

        plans[i]
            = fftwf_plan_dft_c2r_2d(resolutions[i],
                                    resolutions[i],
                                    source,
                                    target,
                                    FFTW_MEASURE);

        fftwf_free(source);
        FREE(target);
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
        if ( plans[i] != NULL )
        {
            fftwf_destroy_plan(plans[i]);
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
        [ condition lock ];

        while ( generateData == NO )
        {
            [ condition wait ];
        }

        [ condition unlock ];

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

            float * c2r = ALLOC_ARRAY(float, settings.resolution.x * settings.resolution.y);

            OdHeightfieldData * result = ALLOC(OdHeightfieldData);
            result->size = settings.size;
            result->resolution = settings.resolution;
            result->data32f = NULL;

            [ timer update ];

            //const float totalTime = [ timer totalElapsedTime ];
            //result->timeStamp = totalTime;
            result->timeStamp = generationTime;

            fftwf_complex * halfcomplexSpectrum
                = [ s generateFloatFrequencySpectrumHC:settings atTime:generationTime ];

            generationTime += 1.0f/60.0f;
            //NSLog(@"%f", generationTime);

            [ timer update ];

            const float fpsHC = [ timer frameTime ];

            /*
            printf("spectrum\n");
            print_complex_spectrum(settings.resolution, complexSpectrum);
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

            fftwf_execute_dft_c2r(plans[resIndex], halfcomplexSpectrum, c2r);

            [ timer update ];

            const float fpsIFFTHC = [ timer frameTime ];

            float maxSurfaceHeight = -FLT_MAX;
            float minSurfaceHeight =  FLT_MAX;
            int32_t numberOfElements = settings.resolution.x * settings.resolution.y;
            for ( int32_t i = 0; i < numberOfElements; i++ )
            {
                maxSurfaceHeight = MAX(maxSurfaceHeight, c2r[i]);
                minSurfaceHeight = MIN(minSurfaceHeight, c2r[i]);
            }

            [ timer update ];
            
            const float fpsMinMax = [ timer frameTime ];

            
            printf("PHILLIPS HC: %f IFFT: %f Min: %f Max: %f MinMaxTime: %f\n", fpsHC, fpsIFFTHC, minSurfaceHeight, maxSurfaceHeight, fpsMinMax);
            fflush(stdout);
            

            fftwf_free(halfcomplexSpectrum);

            result->data32f = c2r;
            result->dataMin = minSurfaceHeight;
            result->dataMax = maxSurfaceHeight;

            {
                [ resultQueueMutex lock ];
                [ resultQueue addPointer:result ];
                [ resultQueueMutex unlock ];
            }
        }

        DESTROY(innerPool);
    }    

    DESTROY(s);
    DESTROY(timer);
    DESTROY(pool);
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
    timeQueueMutex = [[ NSLock alloc ] init ];
    condition = [[ NSCondition alloc ] init ];

    generateData = NO;

    lastResolutionIndex = ULONG_MAX;
    resolutionIndex = defaultResolutionIndex;

    lastWindDirection = (Vector2){DBL_MAX, DBL_MAX};
    windDirection = defaultWindDirection;

    NSPointerFunctionsOptions options
        = NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality;
    resultQueue = [[ NSPointerArray alloc ] initWithOptions:options ];

    timeQueue = [[ NSMutableArray alloc ] initWithCapacity:16 ];

    projector = [[ ODProjector alloc ] initWithName:@"Projector" ];
    basePlane = [[ ODBasePlane alloc ] initWithName:@"BasePlane" ];
    [ basePlane setProjector:projector ];

    heightfield = [[ NPTexture2D alloc ] initWithName:@"Height Texture" ];
    [ heightfield setTextureFilter:NpTexture2DFilterLinear ];
    [ heightfield setTextureWrap:NpTextureWrapRepeat ];

    minHeight =  FLT_MAX;
    maxHeight = -FLT_MAX;
    timeStamp =  DBL_MAX;

    return self;
}

- (void) dealloc
{
    DESTROY(heightfield);
    DESTROY(projector);
    DESTROY(basePlane);

    NSUInteger count = [ resultQueue count ];
    while (count != 0)
    {
        OdHeightfieldData * hf = [ resultQueue pointerAtIndex:0 ];
        if ( hf != NULL )
        {
            SAFE_FREE(hf->data32f);
            FREE(hf);
        }
        [ resultQueue removePointerAtIndex:0 ];
        count = [ resultQueue count ];
    }

    [ timeQueue removeAllObjects ];

    DESTROY(resultQueue);
    DESTROY(timeQueue);
    DESTROY(resultQueueMutex);
    DESTROY(timeQueueMutex);
    DESTROY(condition);

    [ super dealloc ];
}

- (void) start
{
    [ self startupFFTW ];

    if ( thread == nil )
    {
        thread
            = [[ NSThread alloc ]
                    initWithTarget:self
                          selector:@selector(generate:)
                            object:nil ];
    }

    [ thread start ];
} 

- (void) stop
{
    if ( thread != nil )
    {
        if ( [ thread isExecuting ] == YES )
        {
            // cancel thread
            [ thread cancel ];

            // wake thread up a last time so it exits its main loop
            [ condition lock ];
            generateData = YES;
            [ condition signal ];
            [ condition unlock ];

            // since NSThreads are created in detached mode
            // we have to join by hand
            while ( [ thread isFinished ] == NO )
            {
                struct timespec request;
                request.tv_sec = (time_t)0;
                request.tv_nsec = 1000000L;
                nanosleep(&request, 0);
            }
        }

        DESTROY(thread);
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

- (float) minHeight
{
    return minHeight;
}

- (float) maxHeight
{
    return maxHeight;
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
    BOOL deleteHFData = NO;

    /*
    {
        [ timeQueueMutex lock ];
        [ timeQueueMutex unlock ];
    }
    */

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

            NSUInteger count = queueCount;
            while (count != 0)
            {
                OdHeightfieldData * hf = [ resultQueue pointerAtIndex:0 ];
                if ( hf != NULL )
                {
                    SAFE_FREE(hf->data32f);
                    FREE(hf);
                }
                [ resultQueue removePointerAtIndex:0 ];
                count = [ resultQueue count ];
            }

            queueCount = count;
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
                OdHeightfieldData * h = [ resultQueue pointerAtIndex:i ];
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
                hf = [ resultQueue pointerAtIndex:f ];

                for ( NSUInteger i = 0; i < f; i++ )
                {
                    OdHeightfieldData * h = [ resultQueue pointerAtIndex:i ];
                    SAFE_FREE(h->data32f);
                    FREE(h);
                }

                NSRange range = NSMakeRange(0, f);
                //NSLog(@"Range %lu %lu", range.location, range.length);

                [ resultQueue removePointersInRange:range ];
            }
            else
            {
                hf = [ resultQueue pointerAtIndex:0 ];
                [ resultQueue removePointerAtIndex:0 ];
                deleteHFData = YES;
            }
            /*

            queueCount = [ resultQueue count ];
            */
        }

        queueCount = [ resultQueue count ];
        [ resultQueueMutex unlock ];
    }

    // update condition variable
    // in case we have 16 or more heightfields in our buffer
    // the generating thread will be put to sleep
    {
        [ condition lock ];
        generateData = ( queueCount < 16 ) ? YES : NO;
        [ condition signal ];
        [ condition unlock ];
    }

    // update texture and associated min max
    if ( hf != NULL )
    {
        minHeight = hf->dataMin;
        maxHeight = hf->dataMax;
        timeStamp = hf->timeStamp;

        //printf("stamp %f\n", hf->timeStamp);

        const NSUInteger numberOfBytes
            = hf->resolution.x * hf->resolution.y * sizeof(float);

        NSData * textureData
            = [ NSData dataWithBytesNoCopy:hf->data32f
                                    length:numberOfBytes
                              freeWhenDone:NO ];

        [ heightfield generateUsingWidth:hf->resolution.x
                                  height:hf->resolution.y
                             pixelFormat:NpImagePixelFormatR
                              dataFormat:NpImageDataFormatFloat32
                                 mipmaps:NO
                                    data:textureData ];

        if ( deleteHFData == YES )
        {
            SAFE_FREE(hf->data32f);
            FREE(hf);
        }

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

