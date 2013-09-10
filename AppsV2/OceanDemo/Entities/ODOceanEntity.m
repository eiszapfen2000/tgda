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
#import "Core/World/NPTransformationState.h"
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

static void print_complex_spectrum(const IVector2 resolution, fftwf_complex * spectrum)
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

static void print_half_complex_spectrum(const IVector2 resolution, fftwf_complex * spectrum)
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

static const double defaultWindSpeed = 4.5;
static const Vector2 defaultWindDirection = {1.0, 0.0};
static const double defaultSize = 80.0;
static const double defaultDampening = 0.001;
static const int32_t resolutions[8] = {8, 16, 32, 64, 128, 256, 512, 1024};
static const NSUInteger defaultGeometryResolutionIndex = 4;
static const NSUInteger defaultGradientResolutionIndex = 4;
static const double OneDivSixty = 1.0 / 60.0;

static size_t index_for_resolution(int32_t resolution)
{
    switch ( resolution )
    {
        case 8:
            return 0;
        case 16:
            return 1;
        case 32:
            return 2;
        case 64:
            return 3;
        case 128:
            return 4;
        case 256:
            return 5;
        case 512:
            return 6;
        case 1024:
            return 7;
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
            NSUInteger geometryResIndex;
            NSUInteger gradientResIndex;

            {
                [ settingsMutex lock ];

                settings.windDirection = defaultWindDirection;
                settings.windSpeed = generatorWindSpeed;
                settings.size = (Vector2){generatorSize, generatorSize};
                settings.dampening = generatorDampening;
                geometryResIndex = generatorGeometryResolutionIndex;
                gradientResIndex = generatorGradientResolutionIndex;

                [ settingsMutex unlock ];
            }

            const int32_t geometryRes = resolutions[geometryResIndex];
            //const int32_t gradientRes = resolutions[gradientResIndex];
            #warning FIXME
            const int32_t gradientRes = geometryRes;
            settings.geometryResolution = (IVector2){geometryRes, geometryRes};
            settings.gradientResolution = (IVector2){gradientRes, gradientRes};

            [ timer update ];

            OdFrequencySpectrumFloat complexSpectrum
                = [ s generateFloatFrequencySpectrum:settings
                                              atTime:generationTime
                                generateBaseGeometry:NO ];

            [ timer update ];

            //NSLog(@"Gen Time %f", [ timer frameTime ]);

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

            NSUInteger hfCount = 0;

            {
                [ heightfieldQueueMutex lock ];
                hfCount = [ resultQueue count ];
                [ heightfieldQueueMutex unlock ];
            }

            if ( hfCount < 16 )
            {
                OdFrequencySpectrumFloat item
                    = { .timestamp = FLT_MAX,
                        .geometryResolution = {.x = 0, .y = 0},
                        .gradientResolution = {.x = 0, .y = 0},
                        .size          = {.x = 0.0, .y = 0.0},
                        .waveSpectrum  = NULL,
                        .gradientX     = NULL,
                        .gradientZ     = NULL,
                        .displacementX = NULL,
                        .displacementZ = NULL };

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

                BOOL process = YES;

                if ( item.timestamp == FLT_MAX || item.geometryResolution.x == 0
                     || item.geometryResolution.y == 0 || item.gradientResolution.x == 0
                     || item.gradientResolution.y == 0 || item.size.x == 0.0
                     || item.size.y == 0.0 || item.waveSpectrum == NULL )
                {
                    process = NO;
                }

                if ( process == YES )
                {
                    OdHeightfieldData * result = NULL;

                    {
                        [ heightfieldQueueMutex lock ];
                        result = heightfield_alloc_init_with_resolution_and_size(item.gradientResolution, item.size);
                        [ heightfieldQueueMutex unlock ];
                    }

                    const size_t index = index_for_resolution(item.gradientResolution.x);
                    const size_t numberOfElements = item.gradientResolution.x * item.gradientResolution.y;

                    NSAssert1(index != SIZE_MAX, @"Invalid resolution %d", item.gradientResolution.x);

                    //NSLog(@"TRANSFORM %f", item.timestamp);

                    fftwf_complex * complexHeights = fftwf_alloc_complex(numberOfElements);
                    fftwf_execute_dft(complexPlans[index], item.waveSpectrum, complexHeights);
                    result->timeStamp = item.timestamp;

                    for ( size_t i = 0; i < numberOfElements; i++ )
                    {
                        result->heights32f[i] = complexHeights[i][0];
                    }

                    heightfield_hf_compute_min_max(result);

                    if ( item.gradientX != NULL && item.gradientZ != NULL )
                    {
                        fftwf_complex * complexGradientX     = fftwf_alloc_complex(numberOfElements);
                        fftwf_complex * complexGradientZ     = fftwf_alloc_complex(numberOfElements);

                        fftwf_execute_dft(complexPlans[index], item.gradientX, complexGradientX);
                        fftwf_execute_dft(complexPlans[index], item.gradientZ, complexGradientZ);

                        for ( size_t i = 0; i < numberOfElements; i++ )
                        {
                            result->supplementalData32f[i].x = complexGradientX[i][0];
                            result->supplementalData32f[i].y = complexGradientZ[i][0];
                        }

                        heightfield_hf_compute_min_max_gradients(result);

                        fftwf_free(complexGradientX);
                        fftwf_free(complexGradientZ);
                    }

                    if ( item.displacementX != NULL && item.displacementZ != NULL )
                    {
                        fftwf_complex * complexDisplacementX = fftwf_alloc_complex(numberOfElements);
                        fftwf_complex * complexDisplacementZ = fftwf_alloc_complex(numberOfElements);

                        fftwf_execute_dft(complexPlans[index], item.displacementX, complexDisplacementX);
                        fftwf_execute_dft(complexPlans[index], item.displacementZ, complexDisplacementZ);

                        for ( size_t i = 0; i < numberOfElements; i++ )
                        {
                            result->supplementalData32f[i].z = complexDisplacementX[i][0];
                            result->supplementalData32f[i].w = complexDisplacementZ[i][0];
                        }

                        heightfield_hf_compute_min_max_displacements(result);

                        fftwf_free(complexDisplacementX);
                        fftwf_free(complexDisplacementZ);
                    }

                    //fftwf_execute_dft_c2r(halfComplexPlans[resIndex], halfcomplexSpectrum.waveSpectrum, result->data32f);

                    {
                        [ heightfieldQueueMutex lock ];
                        [ resultQueue addHeightfield:result ];
                        [ heightfieldQueueMutex unlock ];
                    }

                    [ transformCondition lock ];
                    transformData = ( spectrumCount != 0 ) ? YES : NO;
                    [ transformCondition unlock ];

                    fftwf_free(complexHeights);
                }

                fftwf_free(item.waveSpectrum);
                fftwf_free(item.gradientX);
                fftwf_free(item.gradientZ);
                fftwf_free(item.displacementX);
                fftwf_free(item.displacementZ);
            }
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

    lastGeometryResolutionIndex = lastGradientResolutionIndex = ULONG_MAX;
    geometryResolutionIndex = generatorGeometryResolutionIndex = defaultGeometryResolutionIndex;
    gradientResolutionIndex = generatorGradientResolutionIndex = defaultGradientResolutionIndex;

    windDirection = defaultWindDirection;

    lastWindSpeed = DBL_MAX;
    windSpeed = generatorWindSpeed = defaultWindSpeed;

    lastSize = DBL_MAX;
    size = generatorSize = defaultSize;

    lastDampening = DBL_MAX;
    dampening = generatorDampening = defaultDampening;

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
    NSAssert(YES == [ baseMeshes generateWithResolutions:resolutions numberOfResolutions:8 ], @"");
    baseMeshIndex = ULONG_MAX;
    baseMeshScale = (FVector2){.x = 1.0f, .y = 1.0f};

    timeStamp = DBL_MAX;

    area = 0.0;

    heightRange    = (FVector2){.x = 0.0f, .y = 0.0f};
    gradientXRange = (FVector2){.x = 0.0f, .y = 1.0f};
    gradientZRange = (FVector2){.x = 0.0f, .y = 1.0f};
    displacementXRange = (FVector2){.x = 0.0f, .y = 1.0f};
    displacementZRange = (FVector2){.x = 0.0f, .y = 1.0f};

    animated = YES;

    fm4_m_set_identity(&modelMatrix);

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

- (const FMatrix4 * const) modelMatrix
{
    return &modelMatrix;
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

- (double) area
{
    return area;
}

- (FVector2) heightRange
{
    return heightRange;
}

- (FVector2) gradientXRange
{
    return gradientXRange;
}

- (FVector2) gradientZRange
{
    return gradientZRange;
}

- (FVector2) displacementXRange
{
    return displacementXRange;
}

- (FVector2) displacementZRange
{
    return displacementZRange;
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
    [ projector update:frameTime ];
    [ basePlane update:frameTime ];

    const double totalElapsedTime
        = [[[ NPEngineCore instance ] timer ] totalElapsedTime ];

    BOOL settingsChanged = NO;

    // in case spectrum generation settings changed
    // update the generator thread's' settings and clear
    // the resultQueue of still therein residing data
    if ( windSpeed != lastWindSpeed
         || size != lastSize
         || dampening != lastDampening
         || geometryResolutionIndex != lastGeometryResolutionIndex
         || gradientResolutionIndex != lastGradientResolutionIndex )
    {
        lastWindSpeed = windSpeed;
        lastSize = size;
        lastDampening = dampening;
        lastGeometryResolutionIndex = geometryResolutionIndex;
        lastGradientResolutionIndex = gradientResolutionIndex;
        settingsChanged = YES;
    }

    if ( settingsChanged == YES )
    {
        [ settingsMutex lock ];
        generatorWindSpeed = windSpeed;
        generatorSize = size;
        generatorDampening = dampening;
        generatorGeometryResolutionIndex = geometryResolutionIndex;
        generatorGradientResolutionIndex = gradientResolutionIndex;
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
            

            //hf = [ resultQueue heightfieldAtIndex:0 ];
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

        area = hf->size.x;

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
            baseMeshScale.x = hf->size.x / resX;
            baseMeshScale.y = hf->size.y / resY;

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

            NSData * empty = [ NSData data ];

            [ baseMeshes
                updateMeshAtIndex:baseMeshIndex
                        withYData:textureData
                 supplementalData:supplemental ];

            NPBufferObject * yStream
                = [[ baseMeshes meshAtIndex:baseMeshIndex ] yStream ];

            NPBufferObject * supplementalStream
                = [[ baseMeshes meshAtIndex:baseMeshIndex ] supplementalStream ];

            [ heightfield generateUsingWidth:hf->resolution.x
                                      height:hf->resolution.y
                                 pixelFormat:NpTexturePixelFormatR
                                  dataFormat:NpTextureDataFormatFloat32
                                     mipmaps:NO
                                bufferObject:yStream ];

            [ supplementalData generateUsingWidth:hf->resolution.x
                                           height:hf->resolution.y
                                      pixelFormat:NpTexturePixelFormatRGBA
                                       dataFormat:NpTextureDataFormatFloat32
                                          mipmaps:NO
                                     bufferObject:supplementalStream ];
        }

        //[ resultQueue removeHeightfieldAtIndex:0 ];
    }

    if ( baseMeshIndex != ULONG_MAX )
    {
        FMatrix4 rotation;
        FMatrix4 invTranslation;
        FMatrix4 translation;

        fm4_m_set_identity(&rotation);
        fm4_m_set_identity(&invTranslation);
        fm4_m_set_identity(&translation);

        const double angle = atan2(windDirection.y, windDirection.x);
        const double degree = RADIANS_TO_DEGREE(angle);

        fm4_s_rotatey_m(degree, &rotation);

        const FVector3 center = [[ baseMeshes meshAtIndex:baseMeshIndex ] center ];

        M_EL(invTranslation, 3, 0) = -center.x * baseMeshScale.x;
        M_EL(invTranslation, 3, 1) = -center.y;
        M_EL(invTranslation, 3, 2) = -center.z * baseMeshScale.y;

        M_EL(translation, 3, 0) = center.x * baseMeshScale.x;
        M_EL(translation, 3, 1) = center.y;
        M_EL(translation, 3, 2) = center.z * baseMeshScale.y;

        FMatrix4 tmp = fm4_mm_multiply(&rotation, &invTranslation);
        modelMatrix = fm4_mm_multiply(&translation, &tmp);
    }
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

