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
#import "Core/Utilities/NSData+NPEngine.h"
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
#import "Ocean/ODConstants.h"
#import "Ocean/ODFrequencySpectrum.h"
#import "ODHeightfieldQueue.h"
#import "ODOceanBaseMesh.h"
#import "ODOceanBaseMeshes.h"
#import "ODOceanEntity.h"

static void print_complex_spectrum(const IVector2 resolution, fftwf_complex * spectrum)
{
    printf("Complex spectrum\n");
    for ( int32_t j = 0; j < resolution.y; j++ )
    {
        for ( int32_t k = 0; k < resolution.x; k++ )
        {
            printf("%+f %+fi ", spectrum[j * resolution.x + k][0], spectrum[j * resolution.x + k][1]);
        }

        printf("\n");
    }

    printf("\n");
}

static void print_real_spectrum(const IVector2 resolution, float * spectrum)
{
    printf("Real spectrum\n");
    for ( int32_t j = 0; j < resolution.y; j++ )
    {
        for ( int32_t k = 0; k < resolution.x; k++ )
        {
            printf("%+f ", spectrum[j * resolution.x + k]);
        }

        printf("\n");
    }

    printf("\n");
}

static void print_half_complex_spectrum(const IVector2 resolution, fftwf_complex * spectrum)
{
    printf("Half Complex spectrum\n");
    for ( int32_t j = 0; j < resolution.y; j++ )
    {
        for ( int32_t k = 0; k < ((resolution.x/2)+1); k++ )
        {
            printf("%+f %+fi ", spectrum[j * ((resolution.x/2)+1) + k][0], spectrum[j * ((resolution.x/2)+1) + k][1]);
        }

        printf("\n");
    }

    printf("\n");
}

typedef struct OdSpectrumVariance
{
    float * baseSpectrum;
    float maxMeanSlopeVariance;
    float effectiveMeanSlopeVariance;
}
OdSpectrumVariance;

static const NSUInteger defaultNumberOfLods = 2;
static const NSUInteger defaultSpectrumType = 1;
static const double defaultWindSpeed = 4.5;
static const Vector2 defaultWindDirection = {1.0, 0.0};
static const double defaultSize = 80.0;
static const double defaultDampening = 0.001;
static const double defaultSpectrumScale = PHILLIPS_CONSTANT;
static const int32_t resolutions[6] = {8, 64, 128, 256, 512, 1024};
static const NSUInteger defaultGeometryResolutionIndex = 0;
static const NSUInteger defaultGradientResolutionIndex = 0;
static const double OneDivSixty = 1.0 / 30.0;

static const double defaultAreaScale = 1.0;
static const double defaultDisplacementScale = 1.0;
static const double defaultHeightScale = 1.0;

static size_t index_for_resolution(int32_t resolution)
{
    switch ( resolution )
    {
        case 8:
            return 0;
        case 64:
            return 1;
        case 128:
            return 2;
        case 256:
            return 3;
        case 512:
            return 4;
        case 1024:
            return 5;
        default:
            return SIZE_MAX;
    }
}

@interface ODOceanEntity (Private)

- (void) startupFFTW;
- (void) shutdownFFTW;
- (void) generate:(id)argument;
- (void) transformSpectra:(const OdFrequencySpectrumFloat *)item
                     into:(OdHeightfieldData *)result
                         ;

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

        if ( fftwf_import_wisdom_from_filename([ wisdomFileName UTF8String ]) != 0 )
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
                                    FFTW_PATIENT);

        complexPlans[i]
            = fftwf_plan_dft_2d(resolutions[i],
                                resolutions[i],
                                source,
                                complexTarget,
                                FFTW_BACKWARD,
                                FFTW_PATIENT);

        fftwf_free(source);
        fftwf_free(complexTarget);
        fftwf_free(realTarget);
    }

    if ( obtainedWisdom == NO )
    {
        if ( fftwf_export_wisdom_to_filename([ wisdomFileName UTF8String ]) != 0 )
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

    fftwf_forget_wisdom();
    fftwf_cleanup();
}

- (void) generate:(id)argument
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    NPTimer * timer = [[ NPTimer alloc ] initWithName:@"Generator Timer" ];
    ODFrequencySpectrum * s = [[ ODFrequencySpectrum alloc ] init ];

    float generationTime = 0.0;

    while ( [[ NSThread currentThread ] isCancelled ] == NO )
    {    
        [ generateCondition lock ];

        while ( generateData == NO )
        {
            [ generateCondition wait ];
        }

        [ generateCondition unlock ];

        //NSLog(@"Generate");

        NSAutoreleasePool * innerPool = [ NSAutoreleasePool new ];

        #define ODZERO(_type, _name) \
            _type _name; \
            memset(&(_name), 0, sizeof((_name)));

        if ( [[ NSThread currentThread ] isCancelled ] == NO )
        {
            OdGeneratorSettings generatorSettings;
            NSUInteger geometryResIndex;
            NSUInteger gradientResIndex;
            uint32_t lodCount;
            double maxSize;

            {
                [ settingsMutex lock ];

                const OdSpectrumGenerator generatorType
                     = (OdSpectrumGenerator)generatorSpectrumType;

                switch ( generatorType )
                {
                    case Phillips:
                    {
                        generatorSettings.generatorType = Phillips;
                        generatorSettings.phillips.windDirection = defaultWindDirection;
                        generatorSettings.phillips.windSpeed = generatorWindSpeed;
                        generatorSettings.phillips.dampening = generatorDampening;
                        break;
                    }

                    case Unified:
                    {
                        generatorSettings.generatorType = Unified;
                        generatorSettings.unified.U10 = generatorWindSpeed;
                        generatorSettings.unified.Omega = 0.84;
                        break;
                    }
                }

                generatorSettings.spectrumScale = generatorSpectrumScale;
                generatorSettings.options = ULONG_MAX;

                NSAssert(generatorNumberOfLods <= UINT32_MAX, @"Lod out of bounds");

                lodCount = (uint32_t)generatorNumberOfLods;
                maxSize = generatorSize;

                geometryResIndex = generatorGeometryResolutionIndex;
                gradientResIndex = generatorGradientResolutionIndex;

                [ settingsMutex unlock ];
            }

            const int32_t geometryRes = resolutions[geometryResIndex];
            const int32_t gradientRes = resolutions[gradientResIndex];

            OdSpectrumGeometry geometry = geometry_zero();
            geometry_init_with_resolutions_and_lods(&geometry, geometryRes, gradientRes, lodCount);
            // first LOD is the largest one, set it to our desired size
            geometry_set_max_size(&geometry, maxSize);

            const int32_t largerResolution = MAX(geometryRes, gradientRes);
            const float halfResolution = ((float)largerResolution) / 2.0f;

            // compute size of smaller LODS
            // in order not to compute redundant frequencies we have to
            // scale down by at least half the resolution and epsilon
            // ac < (al / (res/2))
            for ( NSUInteger i = 1; i < generatorNumberOfLods; i++ )
            {
                const float x = geometry.sizes[i-1].x / halfResolution;
                const float y = geometry.sizes[i-1].y / halfResolution;

                geometry.sizes[i]
                    = (Vector2){x * (-2.0f * FLT_EPSILON + 1.0f), y * (-2.0f * FLT_EPSILON + 1.0f)};
            }

            [ timer update ];

            OdFrequencySpectrumFloat complexSpectrum
                = [ s generateFloatSpectrumWithGeometry:geometry
                                              generator:generatorSettings
                                                 atTime:generationTime
                                   generateBaseGeometry:NO ];


            [ timer update ];
            const double genTime = [ timer frameTime ];
            //NSLog(@"%lf", genTime);

            generationTime += 1.0f/30.0f;

            geometry_clear(&geometry);

            NSUInteger queueCount = 0;
            {
                [ spectrumQueueMutex lock ];
                [ spectrumQueue addPointer:&complexSpectrum ];
                //[ spectrumQueue addPointer:&halfcomplexSpectrum ];
                queueCount = [ spectrumQueue count ];
                [ spectrumQueueMutex unlock ];
            }

            [ generateCondition lock ];
            generateData = ( queueCount < 16 ) ? YES : NO;
            [ generateCondition unlock ];

            [ transformCondition lock ];
            transformData = YES;
            //transformData = NO;
            [ transformCondition signal ];
            [ transformCondition unlock ];
        }

        DESTROY(innerPool);
    }

    DESTROY(s);
    DESTROY(timer);
    DESTROY(pool);
}

- (void) transformSpectra:(const OdFrequencySpectrumFloat *)item
                     into:(OdHeightfieldData *)result
{
    const IVector2 geometryResolution = item->geometry.geometryResolution;
    const IVector2 gradientResolution = item->geometry.gradientResolution;

    const size_t geometryIndex = index_for_resolution(geometryResolution.x);
    const size_t gradientIndex = index_for_resolution(gradientResolution.x);

    const size_t numberOfGeometryElements = geometryResolution.x * geometryResolution.y;
    const size_t numberOfGradientElements = gradientResolution.x * gradientResolution.y;

    NSAssert2(geometryIndex != SIZE_MAX && gradientIndex != SIZE_MAX,
              @"Invalid resolution %d %d", geometryResolution.x, gradientResolution.x);

    fftwf_complex * complexHeights = fftwf_alloc_complex(numberOfGeometryElements);

    fftwf_execute_dft(complexPlans[geometryIndex], item->data.height, complexHeights);
    result->timeStamp = item->timestamp;

    for ( int32_t i = 0; i < geometryResolution.y; i++ )
    {
        for ( int32_t j = 0; j < geometryResolution.x; j++ )
        {
            const int32_t k = geometryResolution.y - 1 - i;
            const int32_t sourceIndex = i * geometryResolution.x + j;
            const int32_t targetIndex = k * geometryResolution.x + j;
            result->heights32f[targetIndex] = complexHeights[sourceIndex][0];
        }
    }

    heightfield_hf_compute_min_max(result);

    if ( item->data.gradient != NULL )
    {
        fftwf_complex * complexGradient = fftwf_alloc_complex(numberOfGradientElements);
        fftwf_complex * complexDisplacementXdXdZ = fftwf_alloc_complex(numberOfGradientElements);
        fftwf_complex * complexDisplacementZdXdZ = fftwf_alloc_complex(numberOfGradientElements);

        fftwf_execute_dft(complexPlans[gradientIndex], item->data.gradient, complexGradient);
        fftwf_execute_dft(complexPlans[gradientIndex], item->data.displacementXdXdZ, complexDisplacementXdXdZ);
        fftwf_execute_dft(complexPlans[gradientIndex], item->data.displacementZdXdZ, complexDisplacementZdXdZ);

        for ( int32_t i = 0; i < gradientResolution.y; i++ )
        {
            for ( int32_t j = 0; j < gradientResolution.x; j++ )
            {
                const int32_t k = gradientResolution.y - 1 - i;
                const int32_t sourceIndex = i * gradientResolution.x + j;
                const int32_t targetIndex = k * gradientResolution.x + j;

                result->gradients32f[targetIndex].x = complexGradient[sourceIndex][0];
                result->gradients32f[targetIndex].y = complexGradient[sourceIndex][1];

                result->displacementDerivatives32f[targetIndex].x = complexDisplacementXdXdZ[sourceIndex][0];
                result->displacementDerivatives32f[targetIndex].y = complexDisplacementXdXdZ[sourceIndex][1];
                result->displacementDerivatives32f[targetIndex].z = complexDisplacementZdXdZ[sourceIndex][0];
                result->displacementDerivatives32f[targetIndex].w = complexDisplacementZdXdZ[sourceIndex][1];
            }
        }

        heightfield_hf_compute_min_max_gradients(result);
        heightfield_hf_compute_min_max_displacement_derivatives(result);

        fftwf_free(complexDisplacementZdXdZ);
        fftwf_free(complexDisplacementXdXdZ);
        fftwf_free(complexGradient);
    }

    if ( item->data.displacement != NULL )
    {
        fftwf_complex * complexDisplacement = fftwf_alloc_complex(numberOfGeometryElements);

        fftwf_execute_dft(complexPlans[geometryIndex], item->data.displacement, complexDisplacement);

        for ( int32_t i = 0; i < geometryResolution.y; i++ )
        {
            for ( int32_t j = 0; j < geometryResolution.x; j++ )
            {
                const int32_t k = geometryResolution.y - 1 - i;
                const int32_t sourceIndex = i * geometryResolution.x + j;
                const int32_t targetIndex = k * geometryResolution.x + j;

                result->displacements32f[targetIndex].x = complexDisplacement[sourceIndex][0];
                result->displacements32f[targetIndex].y = complexDisplacement[sourceIndex][1];
            }
        }

        heightfield_hf_compute_min_max_displacements(result);
        fftwf_free(complexDisplacement);
    }

    fftwf_free(complexHeights);
}

- (void) transform:(id)argument
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];
    NPTimer * timer = [[ NPTimer alloc ] initWithName:@"Transform Timer" ];

    while ( [[ NSThread currentThread ] isCancelled ] == NO )
    {    
        [ transformCondition lock ];

        while ( transformData == NO )
        {
            [ transformCondition wait ];
        }

        [ transformCondition unlock ];

        //NSLog(@"Transform");

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
                OdFrequencySpectrumFloat item;
                memset(&item, 0, sizeof(item));
                item.timestamp = FLT_MAX;

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

                if ( item.timestamp == FLT_MAX
                     || item.geometry.geometryResolution.x == 0 || item.geometry.geometryResolution.y == 0
                     || item.geometry.gradientResolution.x == 0 || item.geometry.gradientResolution.y == 0
                     || item.geometry.sizes == NULL ||  item.data.height == NULL )
                {
                    process = NO;
                }

                if ( process == YES )
                {
                    OdHeightfieldData result;
                    heightfield_hf_init_with_resolutions_and_size(
                                &result,
                                item.geometry.geometryResolution,
                                item.geometry.gradientResolution,
                                item.geometry.sizes[0]);

                    [ self transformSpectra:&item into:&result ];

                    NSUInteger queueCount = 0;

                    {
                        [ heightfieldQueueMutex lock ];

                        OdSpectrumVariance variance;
                        variance.baseSpectrum = item.baseSpectrum;
                        variance.maxMeanSlopeVariance = item.maxMeanSlopeVariance;
                        variance.effectiveMeanSlopeVariance = item.effectiveMeanSlopeVariance;

                        [ varianceQueue addPointer:&variance ];
                        [ resultQueue addHeightfield:&result ];

                        queueCount = [ resultQueue count ];

                        [ heightfieldQueueMutex unlock ];
                    }

                    [ transformCondition lock ];
                    transformData = ( spectrumCount != 0 ) ? YES : NO;
                    [ transformCondition unlock ];
                }

                frequency_spectrum_clear(&item);
            }

        }

        DESTROY(innerPool);
    }

    DESTROY(timer);
    DESTROY(pool);
}

@end

static NSUInteger od_freq_spectrum_size(const void * item)
{
    return sizeof(OdFrequencySpectrumFloat);
}

static NSUInteger od_variance_size(const void * item)
{
    return sizeof(OdSpectrumVariance);
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

    lastNumberOfLods = ULONG_MAX;
    numberOfLods = generatorNumberOfLods = defaultNumberOfLods;

    lastSpectrumType = ULONG_MAX;
    spectrumType = generatorSpectrumType = defaultSpectrumType;

    windDirection = defaultWindDirection;

    lastWindSpeed = DBL_MAX;
    windSpeed = generatorWindSpeed = defaultWindSpeed;

    lastSize = DBL_MAX;
    size = generatorSize = defaultSize;

    lastDampening = DBL_MAX;
    dampening = generatorDampening = defaultDampening;

    lastSpectrumScale = DBL_MAX;
    spectrumScale = generatorSpectrumScale = defaultSpectrumScale;

    const NSUInteger options
        = NSPointerFunctionsMallocMemory
          | NSPointerFunctionsStructPersonality
          | NSPointerFunctionsCopyIn;

    NSPointerFunctions * pFunctionsSpectrum
        = [ NSPointerFunctions pointerFunctionsWithOptions:options ];

    NSPointerFunctions * pFunctionsVariance
        = [ NSPointerFunctions pointerFunctionsWithOptions:options ];

    [ pFunctionsSpectrum setSizeFunction:&od_freq_spectrum_size ];
    [ pFunctionsVariance setSizeFunction:&od_variance_size];

    spectrumQueue = [[ NSPointerArray alloc ] initWithPointerFunctions:pFunctionsSpectrum ];
    varianceQueue = [[ NSPointerArray alloc ] initWithPointerFunctions:pFunctionsVariance ];

    resultQueue = [[ ODHeightfieldQueue alloc ] init ];

    projector = [[ ODProjector alloc ] initWithName:@"Projector" ];
    basePlane = [[ ODBasePlane alloc ] initWithName:@"BasePlane" ];
    [ basePlane setProjector:projector ];

    baseSpectrum = [[ NPTexture2D alloc ] initWithName:@"Base Spectrum Texture" ];
    heightfield  = [[ NPTexture2D alloc ] initWithName:@"Height Texture" ];
    displacement = [[ NPTexture2D alloc ] initWithName:@"Height Texture Displacement" ];
    gradient     = [[ NPTexture2D alloc ] initWithName:@"Height Texture Gradient" ];

    displacementDerivatives
        = [[ NPTexture2D alloc ] initWithName:@"Height Texture Displacement Derivatives" ];

    [ baseSpectrum setTextureFilter:NpTextureFilterNearest ];
    [ heightfield  setTextureFilter:NpTextureFilterLinear  ];
    [ displacement setTextureFilter:NpTextureFilterLinear  ];
    [ gradient     setTextureFilter:NpTextureFilterLinear  ];

    [ displacementDerivatives setTextureFilter:NpTextureFilterLinear  ];

    [ baseSpectrum setTextureWrap:NpTextureWrapToBorder ];
    [ heightfield  setTextureWrap:NpTextureWrapRepeat   ];
    [ displacement setTextureWrap:NpTextureWrapRepeat   ];
    [ gradient     setTextureWrap:NpTextureWrapRepeat   ];

    [ displacementDerivatives setTextureWrap:NpTextureWrapRepeat   ];

    baseMeshes = [[ ODOceanBaseMeshes alloc ] init ];
    NSAssert(YES == [ baseMeshes generateWithResolutions:resolutions numberOfResolutions:6 ], @"");
    baseMeshIndex = ULONG_MAX;
    baseMeshScale = (FVector2){.x = 1.0f, .y = 1.0f};

    timeStamp = DBL_MAX;

    area = 0.0;

    displacementScale = defaultDisplacementScale;
    areaScale = defaultAreaScale;
    heightScale = defaultHeightScale;

    heightRange    = (FVector2){.x = 0.0f, .y = 0.0f};
    gradientXRange = (FVector2){.x = 0.0f, .y = 1.0f};
    gradientZRange = (FVector2){.x = 0.0f, .y = 1.0f};
    displacementXRange = (FVector2){.x = 0.0f, .y = 1.0f};
    displacementZRange = (FVector2){.x = 0.0f, .y = 1.0f};
    displacementXdXRange = (FVector2){.x = 0.0f, .y = 1.0f};
    displacementXdZRange = (FVector2){.x = 0.0f, .y = 1.0f};
    displacementZdXRange = (FVector2){.x = 0.0f, .y = 1.0f};
    displacementZdZRange = (FVector2){.x = 0.0f, .y = 1.0f};

    animated = YES;
    updateSlopeVariance = NO;

    baseSpectrumResolution = iv2_zero();
    baseSpectrumSize = v2_zero();
    baseSpectrumDeltaVariance = 0.0f;

    fm4_m_set_identity(&modelMatrix);

    return self;
}

- (void) dealloc
{
    NSUInteger spectrumCount = [ spectrumQueue count ];
    for ( NSUInteger i = 0; i < spectrumCount; i++ )
    {
        frequency_spectrum_clear([ spectrumQueue pointerAtIndex:i ]);
    }

    [ spectrumQueue removeAllPointers ];
    [ varianceQueue removeAllPointers ];
    [ resultQueue removeAllHeightfields ];

    DESTROY(baseMeshes);
    DESTROY(heightfield);
    DESTROY(displacement);
    DESTROY(displacementDerivatives);
    DESTROY(gradient);
    DESTROY(baseSpectrum);
    DESTROY(projector);
    DESTROY(basePlane);
    DESTROY(resultQueue);
    DESTROY(varianceQueue);
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

- (NPTexture2D *) baseSpectrum
{
    return baseSpectrum;
}

- (NPTexture2D *) heightfield
{
    return heightfield;
}

- (NPTexture2D *) displacement
{
    return displacement;
}

- (NPTexture2D *) displacementDerivatives
{
    return displacementDerivatives;
}

- (NPTexture2D *) gradient
{
    return gradient;
}

- (double) area
{
    return area;
}

- (double) areaScale
{
    return areaScale;
}

- (double) displacementScale
{
    return displacementScale;
}

- (double) heightScale
{
    return heightScale;
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

- (IVector2) baseSpectrumResolution
{
    return baseSpectrumResolution;
}

- (Vector2) baseSpectrumSize
{
    return baseSpectrumSize;
}

- (float) baseSpectrumDeltaVariance
{
    return baseSpectrumDeltaVariance;
}

- (FVector2) baseMeshScale
{
    return baseMeshScale;
}

- (BOOL) updateSlopeVariance
{
    return updateSlopeVariance;
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
    if ( spectrumType != lastSpectrumType
         || numberOfLods != lastNumberOfLods
         || windSpeed != lastWindSpeed
         || size != lastSize
         || dampening != lastDampening
         || spectrumScale != lastSpectrumScale
         || geometryResolutionIndex != lastGeometryResolutionIndex
         || gradientResolutionIndex != lastGradientResolutionIndex )
    {
        lastSpectrumType = spectrumType;
        lastNumberOfLods = numberOfLods;
        lastWindSpeed = windSpeed;
        lastSize = size;
        lastDampening = dampening;
        lastSpectrumScale = spectrumScale;
        lastGeometryResolutionIndex = geometryResolutionIndex;
        lastGradientResolutionIndex = gradientResolutionIndex;
        settingsChanged = YES;
    }

    if ( settingsChanged == YES )
    {
        [ settingsMutex lock ];
        generatorSpectrumType = spectrumType;
        generatorNumberOfLods = numberOfLods;
        generatorWindSpeed = windSpeed;
        generatorSize = size;
        generatorDampening = dampening;
        generatorSpectrumScale = spectrumScale;
        generatorGeometryResolutionIndex = geometryResolutionIndex;
        generatorGradientResolutionIndex = gradientResolutionIndex;
        [ settingsMutex unlock ];

        [ spectrumQueueMutex lock ];

        NSUInteger spectrumCount = [ spectrumQueue count ];
        for ( NSUInteger i = 0; i < spectrumCount; i++ )
        {
            frequency_spectrum_clear([ spectrumQueue pointerAtIndex:i ]);
        }

        [ spectrumQueue removeAllPointers ];
        [ spectrumQueueMutex unlock ];

        [ heightfieldQueueMutex lock ];
        [ varianceQueue removeAllPointers ];
        [ resultQueue removeAllHeightfields ];
        [ heightfieldQueueMutex unlock ];
    }

    NSUInteger spectrumQueueCount = 0;
    NSUInteger resultQueueCount   = 0;
    NSUInteger varianceQueueCount = 0;

    OdHeightfieldData * hf = NULL;
    OdSpectrumVariance * variance = NULL;

    {
        [ spectrumQueueMutex lock ];
        spectrumQueueCount = [ spectrumQueue count ];
        [ spectrumQueueMutex unlock ];
    }

    {
        [ heightfieldQueueMutex lock ];

        resultQueueCount   = [ resultQueue   count ];
        varianceQueueCount = [ varianceQueue count ];

        NSAssert2(resultQueueCount == varianceQueueCount, @"%lu %lu", resultQueueCount, varianceQueueCount);

        // get heightfield data
        if ( resultQueueCount != 0 )
        {
            NSUInteger f = NSNotFound;
            double queueMinTimeStamp =  DBL_MAX;
            double queueMaxTimeStamp = -DBL_MAX;

            for ( NSUInteger i = 0; i < resultQueueCount; i++ )
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
                variance = [ varianceQueue pointerAtIndex:f ];

                NSRange range = NSMakeRange(0, f);
                [ varianceQueue removePointersInRange:range ];
                [ resultQueue removeHeightfieldsInRange:range ];
            }
            else
            {
                hf = [ resultQueue heightfieldAtIndex:0 ];
                variance = [ varianceQueue pointerAtIndex:0 ];
            }
            
            //hf = [ resultQueue heightfieldAtIndex:0 ];
            //variance = [ varianceQueue pointerAtIndex:0 ];
        }

        resultQueueCount = [ resultQueue count ];

        [ heightfieldQueueMutex unlock ];
    }

    // update condition variable
    // in case we have 16 or more heightfields in our buffer
    // the generating thread will be put to sleep
    {
        [ generateCondition lock ];
        generateData = ( spectrumQueueCount < 16 ) ? YES : NO;
        [ generateCondition signal ];
        [ generateCondition unlock ];
    }

    updateSlopeVariance = NO;

    // update texture and associated min max
    if ( hf != NULL && animated == YES)
    {
        timeStamp = hf->timeStamp;

        area = hf->size.x;

        heightRange = hf->heightRange;
        gradientXRange = hf->gradientXRange;
        gradientZRange = hf->gradientZRange;
        displacementXRange = hf->displacementXRange;
        displacementZRange = hf->displacementZRange;
        displacementXdXRange = hf->displacementXdXRange;
        displacementXdZRange = hf->displacementXdZRange;
        displacementZdXRange = hf->displacementZdXRange;
        displacementZdZRange = hf->displacementZdZRange;

        {
            const double resX = hf->geometryResolution.x;
            const double resY = hf->geometryResolution.y;
            baseMeshScale.x = hf->size.x / resX;
            baseMeshScale.y = hf->size.y / resY;

            const NSUInteger numberOfGeometryBytes
                = hf->geometryResolution.x * hf->geometryResolution.y * sizeof(float);

            const NSUInteger numberOfGradientBytes
                = hf->gradientResolution.x * hf->gradientResolution.y * sizeof(float);

            NSData * heightsData
                = [ NSData dataWithBytesNoCopyNoFree:hf->heights32f
                                              length:numberOfGeometryBytes ];

            NSData * displacementsData
                = [ NSData dataWithBytesNoCopyNoFree:hf->displacements32f
                                              length:numberOfGeometryBytes * 2 ];

            NSData * displacementDerivativesData
                = [ NSData dataWithBytesNoCopyNoFree:hf->displacementDerivatives32f
                                              length:numberOfGradientBytes * 4 ];

            NSData * gradientsData
                = [ NSData dataWithBytesNoCopyNoFree:hf->gradients32f
                                              length:numberOfGradientBytes * 2 ];

            [ heightfield generateUsingWidth:hf->geometryResolution.x
                                      height:hf->geometryResolution.y
                                 pixelFormat:NpTexturePixelFormatR
                                  dataFormat:NpTextureDataFormatFloat32
                                     mipmaps:YES
                                        data:heightsData ];

            [ displacement generateUsingWidth:hf->geometryResolution.x
                                       height:hf->geometryResolution.y
                                  pixelFormat:NpTexturePixelFormatRG
                                   dataFormat:NpTextureDataFormatFloat32
                                      mipmaps:YES
                                         data:displacementsData ];

            [ displacementDerivatives
                generateUsingWidth:hf->gradientResolution.x
                            height:hf->gradientResolution.y
                       pixelFormat:NpTexturePixelFormatRGBA
                        dataFormat:NpTextureDataFormatFloat32
                           mipmaps:YES
                              data:displacementDerivativesData ];

            [ gradient generateUsingWidth:hf->gradientResolution.x
                                   height:hf->gradientResolution.y
                              pixelFormat:NpTexturePixelFormatRG
                               dataFormat:NpTextureDataFormatFloat32
                                  mipmaps:YES
                                     data:gradientsData ];

            if ( variance != NULL && variance->baseSpectrum != NULL )
            {
                baseSpectrumSize = hf->size;
                baseSpectrumResolution.x = MAX(hf->geometryResolution.x, hf->gradientResolution.x);
                baseSpectrumResolution.y = MAX(hf->geometryResolution.y, hf->gradientResolution.y);

                const NSUInteger numberOfBaseSpectrumBytes
                    = baseSpectrumResolution.x * baseSpectrumResolution.y * sizeof(float);

                NSData * baseSpectrumData
                    = [ NSData dataWithBytesNoCopyNoFree:variance->baseSpectrum
                                                  length:numberOfBaseSpectrumBytes ];

                [ baseSpectrum generateUsingWidth:baseSpectrumResolution.x
                                           height:baseSpectrumResolution.y
                                      pixelFormat:NpTexturePixelFormatR
                                       dataFormat:NpTextureDataFormatFloat32
                                          mipmaps:NO
                                             data:baseSpectrumData ];

                baseSpectrumDeltaVariance
                    = variance->maxMeanSlopeVariance - variance->effectiveMeanSlopeVariance;

                fftwf_free(variance->baseSpectrum);
                variance->baseSpectrum = NULL;

                updateSlopeVariance = YES;
            }

            /*
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
            */
        }

        //[ resultQueue removeHeightfieldAtIndex:0 ];
        //[ varianceQueue removePointerAtIndex:0 ];
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

