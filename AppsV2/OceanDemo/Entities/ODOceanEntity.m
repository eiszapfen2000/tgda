#define _GNU_SOURCE
#import <fenv.h>
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
#import "ODOceanBaseMesh.h"
#import "ODOceanBaseMeshes.h"
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

static const Vector2 defaultWindDirection = {2.8, 1.2};
static const Vector2 defaultSize = {50.0, 50.0};
static const int32_t resolutions[4] = {64, 128, 256, 512};
static const NSUInteger defaultResolutionIndex = 2;
static const double OneDivSixty = 1.0 / 60.0;

static size_t index_for_resolution(int32_t resolution)
{
    switch ( resolution )
    {
        case 64:
            return 0;
        case 128:
            return 1;
        case 256:
            return 2;
        case 512:
            return 3;
        default:
            return SIZE_MAX;
    }
}

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
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

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
                [ settingsMutex lock ];
                settings.windDirection = generatorWindDirection;
                settings.size = generatorSize;
                resIndex = generatorResolutionIndex;
                [ settingsMutex unlock ];
            }

            const int32_t res = resolutions[resIndex];
            settings.resolution = (IVector2){res, res};


            OdFrequencySpectrumFloat complexSpectrum
                = [ s generateFloatFrequencySpectrum:settings atTime:generationTime ];

            generationTime += 1.0f/60.0f;

            NSUInteger queueCount = 0;
            {
                [ spectrumQueueMutex lock ];
                [ spectrumQueue addPointer:&complexSpectrum ];
                queueCount = [ spectrumQueue count ];
                [ spectrumQueueMutex unlock ];
            }

            //NSLog(@"GENERATE %f", complexSpectrum.timestamp);

            [ generateCondition lock ];
            generateData = ( queueCount < 16 ) ? YES : NO;
            [ generateCondition unlock ];

            [ transformCondition lock ];
            transformData = YES;
            [ transformCondition signal ];
            [ transformCondition unlock ];
        }

        DESTROY(innerPool);
    }

    DESTROY(s);
    DESTROY(timer);
    DESTROY(pool);
}

- (void) transform:(id)argument
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    while ( [[ NSThread currentThread ] isCancelled ] == NO )
    {    
        [ transformCondition lock ];

        while ( transformData == NO )
        {
            [ transformCondition wait ];
        }

        [ transformCondition unlock ];

        NSAutoreleasePool * innerPool = [ NSAutoreleasePool new ];

        if ( [[ NSThread currentThread ] isCancelled ] == NO )
        {
            OdFrequencySpectrumFloat item
                = { .timestamp = FLT_MAX, .resolution = {.x = 0, .y = 0}, .size = {.x = 0.0, .y = 0.0},
                    .waveSpectrum = NULL, .gradientX = NULL, .gradientZ = NULL };

            NSUInteger spectrumCount = 0;

            {
                [ spectrumQueueMutex lock ];
                if ( [ spectrumQueue count ] != 0 )
                {
                    OdFrequencySpectrumFloat * tempItem = [ spectrumQueue pointerAtIndex:0 ];

                    if ( tempItem != NULL )
                    {
                        item = *tempItem;
                    }

                    [ spectrumQueue removePointerAtIndex:0 ];
                    spectrumCount = [ spectrumQueue count ];
                }
                [ spectrumQueueMutex unlock ];
            }

            if ( item.timestamp == FLT_MAX || item.resolution.x == 0 || item.resolution.y == 0
                 || item.size.x == 0.0 || item.size.y == 0.0 || item.waveSpectrum == NULL
                 || item.gradientX == NULL || item.gradientZ == NULL )
            {
                continue;
            }

            OdHeightfieldData * result = NULL;

            {
                [ heightfieldQueueMutex lock ];
                result = heightfield_alloc_init_with_resolution_and_size(item.resolution, item.size);
                [ heightfieldQueueMutex unlock ];
            }

            const size_t index = index_for_resolution(item.resolution.x);
            const size_t numberOfElements = item.resolution.x * item.resolution.y;

            NSAssert1(index != SIZE_MAX, @"Invalid resolution %d", item.resolution.x);
            NSAssert1(numberOfElements != 0, @"Invalid number of elements %lu", numberOfElements);
            NSAssert(item.size.x != 0.0 && item.size.y != 0.0, @"Invalid size");

            //NSLog(@"TRANSFORM %f", item.timestamp);

            fftwf_complex * complexHeights       = fftwf_alloc_complex(numberOfElements);
            fftwf_complex * complexGradientX     = fftwf_alloc_complex(numberOfElements);
            fftwf_complex * complexGradientZ     = fftwf_alloc_complex(numberOfElements);
            fftwf_complex * complexDisplacementX = fftwf_alloc_complex(numberOfElements);
            fftwf_complex * complexDisplacementZ = fftwf_alloc_complex(numberOfElements);

            //fftwf_execute_dft_c2r(halfComplexPlans[resIndex], halfcomplexSpectrum.waveSpectrum, result->data32f);
            fftwf_execute_dft(complexPlans[index], item.waveSpectrum,  complexHeights);
            fftwf_execute_dft(complexPlans[index], item.gradientX,     complexGradientX);
            fftwf_execute_dft(complexPlans[index], item.gradientZ,     complexGradientZ);
            fftwf_execute_dft(complexPlans[index], item.displacementX, complexDisplacementX);
            fftwf_execute_dft(complexPlans[index], item.displacementZ, complexDisplacementZ);

            result->timeStamp = item.timestamp;
            for ( size_t i = 0; i < numberOfElements; i++ )
            {
                result->heights32f[i] = complexHeights[i][0];
                result->supplementalData32f[i].x = complexGradientX[i][0];
                result->supplementalData32f[i].y = complexGradientZ[i][0];
                result->supplementalData32f[i].z = complexDisplacementX[i][0];
                result->supplementalData32f[i].w = complexDisplacementZ[i][0];
            }

            heightfield_hf_compute_min_max(result);
            heightfield_hf_compute_min_max_gradients(result);
            heightfield_hf_compute_min_max_displacements(result);

            {
                [ heightfieldQueueMutex lock ];
                [ resultQueue addHeightfield:result ];
                [ heightfieldQueueMutex unlock ];
            }

            [ transformCondition lock ];
            transformData = ( spectrumCount != 0 ) ? YES : NO;
            [ transformCondition unlock ];

            fftwf_free(item.waveSpectrum);
            fftwf_free(item.gradientX);
            fftwf_free(item.gradientZ);
            fftwf_free(item.displacementX);
            fftwf_free(item.displacementZ);
            fftwf_free(complexHeights);
            fftwf_free(complexGradientX);
            fftwf_free(complexGradientZ);
            fftwf_free(complexDisplacementX);
            fftwf_free(complexDisplacementZ);
        }

        DESTROY(innerPool);
    }

    DESTROY(pool);
}

@end

static NSUInteger od_freq_spectrum_size(const void * item)
{
    return sizeof(OdFrequencySpectrumFloat);
}

@implementation ODOceanEntity

- (id) init
{
    return [ self initWithName:@"ODOceanEntity" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    spectrumQueueMutex    = [[ NSLock alloc ] init ];
    heightfieldQueueMutex = [[ NSLock alloc ] init ];
    settingsMutex         = [[ NSLock alloc ] init ];

    generateCondition  = [[ NSCondition alloc ] init ];
    transformCondition = [[ NSCondition alloc ] init ];

    generateData  = NO;
    transformData = NO;

    lastResolutionIndex = ULONG_MAX;
    resolutionIndex = generatorResolutionIndex = defaultResolutionIndex;

    lastWindDirection = (Vector2){DBL_MAX, DBL_MAX};
    windDirection = generatorWindDirection = defaultWindDirection;

    lastSize = (Vector2){DBL_MAX, DBL_MAX};
    size = generatorSize = defaultSize;

    const NSUInteger options
        = NSPointerFunctionsMallocMemory
          | NSPointerFunctionsStructPersonality
          | NSPointerFunctionsCopyIn;

    NSPointerFunctions * pFunctions
        = [ NSPointerFunctions pointerFunctionsWithOptions:options ];
    [ pFunctions setSizeFunction:&od_freq_spectrum_size];

    spectrumQueue = [[ NSPointerArray alloc ] initWithPointerFunctions:pFunctions ];

    resultQueue = [[ ODHeightfieldQueue alloc ] init ];

    projector = [[ ODProjector alloc ] initWithName:@"Projector" ];
    basePlane = [[ ODBasePlane alloc ] initWithName:@"BasePlane" ];
    [ basePlane setProjector:projector ];

    heightfield      = [[ NPTexture2D alloc ] initWithName:@"Height Texture" ];
    supplementalData = [[ NPTexture2D alloc ] initWithName:@"Height Texture Supplements" ];

    [ heightfield      setTextureFilter:NpTexture2DFilterLinear ];
    [ supplementalData setTextureFilter:NpTexture2DFilterLinear ];

    [ heightfield      setTextureWrap:NpTextureWrapRepeat ];
    [ supplementalData setTextureWrap:NpTextureWrapRepeat ];

    baseMeshes = [[ ODOceanBaseMeshes alloc ] init ];
    NSAssert(YES == [ baseMeshes generateWithResolutions:resolutions numberOfResolutions:4 ], @"");
    baseMeshIndex = ULONG_MAX;
    baseMeshScale = (FVector2){.x = 1.0f, .y = 1.0f};

    timeStamp = DBL_MAX;

    heightRange    = (FVector2){.x = 0.0f, .y = 0.0f};
    gradientXRange = (FVector2){.x = 0.0f, .y = 1.0f};
    gradientZRange = (FVector2){.x = 0.0f, .y = 1.0f};
    displacementXRange = (FVector2){.x = 0.0f, .y = 1.0f};
    displacementZRange = (FVector2){.x = 0.0f, .y = 1.0f};

    animated = YES;

    return self;
}

- (void) dealloc
{
    DESTROY(baseMeshes);
    DESTROY(heightfield);
    DESTROY(supplementalData);
    DESTROY(projector);
    DESTROY(basePlane);
    DESTROY(resultQueue);
    DESTROY(spectrumQueue);
    DESTROY(spectrumQueueMutex);
    DESTROY(heightfieldQueueMutex);
    DESTROY(settingsMutex);
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

- (NPTexture2D *) supplementalData
{
    return supplementalData;
}

- (FVector2) heightRange
{
    return heightRange;
}

- (FVector2) baseMeshScale
{
    return baseMeshScale;
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

    BOOL settingsChanged = NO;

    // in case spectrum generation settings changed
    // update the generator thread's' settings and clear
    // the resultQueue of still therein residing data
    if ( windDirection.x != lastWindDirection.x
         || windDirection.y != lastWindDirection.y
         || size.x != lastSize.x
         || size.y != lastSize.y
         || resolutionIndex != lastResolutionIndex )
    {
        lastWindDirection = windDirection;
        lastSize = size;
        lastResolutionIndex = resolutionIndex;
        settingsChanged = YES;
    }

    if ( settingsChanged == YES )
    {
        [ settingsMutex lock ];
        generatorWindDirection = windDirection;
        generatorSize = size;
        generatorResolutionIndex = resolutionIndex;
        [ settingsMutex unlock ];

        [ spectrumQueueMutex lock ];
        [ spectrumQueue removeAllPointers ];
        [ spectrumQueueMutex unlock ];

        [ heightfieldQueueMutex lock ];
        [ resultQueue removeAllHeightfields ];
        [ heightfieldQueueMutex unlock ];
    }


    NSUInteger queueCount = 0;
    OdHeightfieldData * hf = NULL;


    {
        [ heightfieldQueueMutex lock ];

        queueCount = [ resultQueue count ];

        // get heightfield data
        if ( queueCount != 0 )
        {
            NSUInteger f = NSNotFound;
            double queueMinTimeStamp =  DBL_MAX;
            double queueMaxTimeStamp = -DBL_MAX;

            for ( NSUInteger i = 0; i < queueCount; i++ )
            {
                OdHeightfieldData * h = [ resultQueue heightfieldAtIndex:i ];
                const double x = totalElapsedTime - 0.5 * OneDivSixty;
                const double y = totalElapsedTime + 0.5 * OneDivSixty;
                const double hTimeStamp = h->timeStamp;

                queueMinTimeStamp = MIN(queueMinTimeStamp, hTimeStamp);
                queueMaxTimeStamp = MAX(queueMaxTimeStamp, hTimeStamp);

                if ( hTimeStamp >= x && hTimeStamp < y )
                {
                    f = i;
                }
            }

            if ( f != NSNotFound )
            {
                hf = [ resultQueue heightfieldAtIndex:f ];

                NSRange range = NSMakeRange(0, f);
                [ resultQueue removeHeightfieldsInRange:range ];
            }
            else
            {
                hf = [ resultQueue heightfieldAtIndex:0 ];
            }
        }

        queueCount = [ resultQueue count ];
        [ heightfieldQueueMutex unlock ];
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
    if ( hf != NULL && animated == YES)
    {
        timeStamp = hf->timeStamp;

        heightRange    = (FVector2){.x = hf->minHeight,    .y = hf->maxHeight   };
        gradientXRange = (FVector2){.x = hf->minGradientX, .y = hf->maxGradientX};
        gradientZRange = (FVector2){.x = hf->minGradientZ, .y = hf->maxGradientZ};
        displacementXRange = (FVector2){.x = hf->minDisplacementX, .y = hf->maxDisplacementX};
        displacementZRange = (FVector2){.x = hf->minDisplacementZ, .y = hf->maxDisplacementZ};

        //printf("stamp %f\n", hf->timeStamp);
        //NSLog(@"X:%f %f Z:%f %f", displacementXRange.x, displacementXRange.y, displacementZRange.x, displacementZRange.y);

        {
            baseMeshIndex = index_for_resolution(hf->resolution.x);

            const double resX = hf->resolution.x;
            const double resY = hf->resolution.y;
            baseMeshScale.x = hf->size.x * 10.0 / resX;
            baseMeshScale.y = hf->size.y * 10.0 / resY;

            const NSUInteger numberOfBytes
                = hf->resolution.x * hf->resolution.y * sizeof(float);

            NSData * textureData
                = [ NSData dataWithBytesNoCopy:hf->heights32f
                                        length:numberOfBytes
                                  freeWhenDone:NO ];

            NSData * supplemental
                = [ NSData dataWithBytesNoCopy:hf->supplementalData32f
                                        length:numberOfBytes * 4
                                  freeWhenDone:NO ];

            [ heightfield generateUsingWidth:hf->resolution.x
                                      height:hf->resolution.y
                                 pixelFormat:NpImagePixelFormatR
                                  dataFormat:NpImageDataFormatFloat32
                                     mipmaps:NO
                                        data:textureData ];

            [ supplementalData generateUsingWidth:hf->resolution.x
                                           height:hf->resolution.y
                                      pixelFormat:NpImagePixelFormatRGBA
                                       dataFormat:NpImageDataFormatFloat32
                                          mipmaps:NO
                                             data:supplemental ];

            [ baseMeshes updateIndex:baseMeshIndex withData:textureData ];
        }
    }

//    NSLog(@"%f", timeStamp);
}

- (void) renderBasePlane
{
    [ basePlane render ];
}

- (void) renderBaseMesh
{
    if ( baseMeshIndex != ULONG_MAX )
    {
        [ baseMeshes renderMeshAtIndex:baseMeshIndex ];
    }
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

