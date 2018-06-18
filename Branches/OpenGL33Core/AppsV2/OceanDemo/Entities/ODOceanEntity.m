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
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTexture2DArray.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Texture/NPTextureBuffer.h"
#import "Graphics/NPOrthographic.h"
#import "Graphics/NPEngineGraphics.h"
#import "ODProjector.h"
#import "ODBasePlane.h"
#import "Ocean/ODConstants.h"
#import "Ocean/ODFrequencySpectrum.h"
#import "ODHeightfieldQueue.h"
#import "ODOceanEntity.h"

#define FFTWF_FREE(_pointer)        do {void *_ptr=(void *)(_pointer); fftwf_free(_ptr); _pointer=NULL; } while (0)
#define FFTWF_SAFE_FREE(_pointer)   { if ( (_pointer) != NULL ) FFTWF_FREE((_pointer)); }

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
static const NSUInteger defaultSpectrumType = 0;

static const NSUInteger defaultOptions
	= OdGeneratorOptionsHeights | OdGeneratorOptionsGradient
	  | OdGeneratorOptionsDisplacement | OdGeneratorOptionsDisplacementDerivatives;

static const double defaultWindSpeed = 4.5;
static const Vector2 defaultWindDirection = {1.0, 0.0};
static const double defaultSize = 237.0;
static const double defaultFetch = 100000.0;
static const double defaultSpectrumScale = 1.0;
static const int32_t resolutions[6] = {8, 16, 32, 64, 128, 256};
static const NSUInteger defaultGeometryResolutionIndex = 3;
static const NSUInteger defaultGradientResolutionIndex = 5;
static const double OneDivSixty = 1.0 / 30.0;
static const double defaultDisplacementScale = 1.0;

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

        fftwf_complex * source = fftwf_alloc_complex(arraySize);
        fftwf_complex * complexTarget = fftwf_alloc_complex(arraySize);

        complexPlans[i]
            = fftwf_plan_dft_2d(resolutions[i],
                                resolutions[i],
                                source,
                                complexTarget,
                                FFTW_BACKWARD,
                                FFTW_PATIENT);

        fftwf_free(source);
        fftwf_free(complexTarget);
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
                    case PiersonMoskowitz:
                    {
                        generatorSettings.generatorType = PiersonMoskowitz;
                        generatorSettings.piersonmoskowitz.U10 = generatorWindSpeed;
                        break;
                    }

                    case JONSWAP:
                    {
                        generatorSettings.generatorType = JONSWAP;
                        generatorSettings.jonswap.U10 = generatorWindSpeed;
                        generatorSettings.jonswap.fetch = generatorFetch;
                        break;
                    }

                    case Donelan:
                    {
                        generatorSettings.generatorType = Donelan;
                        generatorSettings.donelan.U10 = generatorWindSpeed;
                        generatorSettings.donelan.fetch = generatorFetch;
                        break;
                    }

                    case Unified:
                    {
                        generatorSettings.generatorType = Unified;
                        generatorSettings.unified.U10 = generatorWindSpeed;
                        generatorSettings.unified.fetch = generatorFetch;

                        break;
                    }

                    default:
                    {
                        generatorSettings.generatorType = Unknown;
                        NSAssert1(NO, @"Unknown Spectrum Type %d", generatorType);
                        break;
                    }
                }

                generatorSettings.spectrumScale = generatorSpectrumScale;
                //generatorSettings.options = OdGeneratorOptionsHeights | OdGeneratorOptionsGradient | OdGeneratorOptionsDisplacement;
                //generatorSettings.options = ULONG_MAX;
                generatorSettings.options = generatorOptions;

                NSAssert(generatorNumberOfLods > 0 &&  generatorNumberOfLods < UINT32_MAX, @"Lod out of bounds");

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
            // use golden ratio
            for ( NSInteger i = 1; i < lodCount; i++ )
            {
                const float x = geometry.sizes[i-1].x;// / halfResolution;
                const float y = geometry.sizes[i-1].y;// / halfResolution;

                geometry.sizes[i]
                    = (Vector2){x * 0.382f, y * 0.382f};
            }

            [ timer update ];

            OdFrequencySpectrumFloat complexSpectrum
                = [ s generateFloatSpectrumWithGeometry:geometry
                                              generator:generatorSettings
                                                 atTime:generationTime
                                   generateBaseGeometry:NO ];


            [ timer update ];
            //NSLog(@"Gen Time %f", [ timer frameTime ]);

            generationTime += OneDivSixty;

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

static NPTimer * transformTimer = nil;

- (void) transformSpectra:(const OdFrequencySpectrumFloat *)item
                     into:(OdHeightfieldData *)result
{
    const IVector2 geometryResolution = item->geometry.geometryResolution;
    const IVector2 gradientResolution = item->geometry.gradientResolution;

    const size_t geometryIndex = index_for_resolution(geometryResolution.x);
    const size_t gradientIndex = index_for_resolution(gradientResolution.x);

    const int32_t lodCount = (int32_t)item->geometry.numberOfLods;

    const int32_t numberOfGeometryElements = geometryResolution.x * geometryResolution.y;
    const int32_t numberOfGradientElements = gradientResolution.x * gradientResolution.y;

    NSAssert2(geometryIndex != SIZE_MAX && gradientIndex != SIZE_MAX,
              @"Invalid resolution %d %d", geometryResolution.x, gradientResolution.x);

    result->timeStamp = item->timestamp;

    double heightTime = 0.0;
    double displacementTime = 0.0;
    double gradientTime = 0.0;
    double dispDerivativesTime = 0.0;

    fftwf_complex * complexHeights = NULL;
    fftwf_complex * complexDisplacement = NULL;
    fftwf_complex * complexGradient = NULL;
    fftwf_complex * complexDisplacementXdXdZ = NULL;
    fftwf_complex * complexDisplacementZdXdZ = NULL;

    if ( item->height != NULL )
    {
        complexHeights = fftwf_alloc_complex(lodCount * numberOfGeometryElements);

        [ transformTimer update ];

        for ( int32_t l = 0; l < lodCount; l++ )
        {
            const int32_t offset = l * numberOfGeometryElements;

            fftwf_execute_dft(
                complexPlans[geometryIndex],
                item->height   + offset,
                complexHeights + offset
                );
        }

        [ transformTimer update ];
        heightTime = [ transformTimer frameTime ];
    }

    if ( item->displacement != NULL )
    {
        complexDisplacement = fftwf_alloc_complex(lodCount * numberOfGeometryElements);

        [ transformTimer update ];

        for ( int32_t l = 0; l < lodCount; l++ )
        {
            const int32_t offset = l * numberOfGeometryElements;

            fftwf_execute_dft(
                complexPlans[geometryIndex],
                item->displacement  + offset,
                complexDisplacement + offset
                );
        }

        [ transformTimer update ];
        displacementTime = [ transformTimer frameTime ];
    }

    if ( item->gradient != NULL )
    {
        complexGradient = fftwf_alloc_complex(lodCount * numberOfGradientElements);

        [ transformTimer update ];

        for ( int32_t l = 0; l < lodCount; l++ )
        {
            const int32_t offset = l * numberOfGradientElements;

            fftwf_execute_dft(
                complexPlans[gradientIndex],
                item->gradient  + offset,
                complexGradient + offset
                );
        }

        [ transformTimer update ];
        gradientTime = [ transformTimer frameTime ];
    }

    if ( item->displacementXdXdZ != NULL && item->displacementZdXdZ != NULL )
    {
        complexDisplacementXdXdZ = fftwf_alloc_complex(lodCount * numberOfGradientElements);
        complexDisplacementZdXdZ = fftwf_alloc_complex(lodCount * numberOfGradientElements);

        [ transformTimer update ];

        for ( int32_t l = 0; l < lodCount; l++ )
        {
            const int32_t offset = l * numberOfGradientElements;

            fftwf_execute_dft(
                complexPlans[gradientIndex],
                item->displacementXdXdZ  + offset,
                complexDisplacementXdXdZ + offset
                );

            fftwf_execute_dft(
                complexPlans[gradientIndex],
                item->displacementZdXdZ  + offset,
                complexDisplacementZdXdZ + offset
                );
        }

        [ transformTimer update ];
        dispDerivativesTime = [ transformTimer frameTime ];
    }

    if ( item->height != NULL )
    {
        for ( int32_t l = 0; l < lodCount; l++ )
        {
            const int32_t offset = l * numberOfGeometryElements;

            for ( int32_t i = 0; i < geometryResolution.y; i++ )
            {
                for ( int32_t j = 0; j < geometryResolution.x; j++ )
                {
                    const int32_t k = geometryResolution.y - 1 - i;
                    const int32_t sourceIndex = i * geometryResolution.x + j;
                    const int32_t targetIndex = k * geometryResolution.x + j;
                    result->heights32f[offset + targetIndex] = complexHeights[offset + sourceIndex][0];
                }
            }
        }
    }

    if ( item->displacement != NULL )
    {
        for ( int32_t l = 0; l < lodCount; l++ )
        {
            const int32_t offset = l * numberOfGeometryElements;

            for ( int32_t i = 0; i < geometryResolution.y; i++ )
            {
                for ( int32_t j = 0; j < geometryResolution.x; j++ )
                {
                    const int32_t k = geometryResolution.y - 1 - i;
                    const int32_t sourceIndex = i * geometryResolution.x + j;
                    const int32_t targetIndex = k * geometryResolution.x + j;

                    result->displacements32f[offset + targetIndex].x = complexDisplacement[offset + sourceIndex][0];
                    result->displacements32f[offset + targetIndex].y = complexDisplacement[offset + sourceIndex][1];
                }
            }
        }
    }

    if ( item->gradient != NULL )
    {
        for ( int32_t l = 0; l < lodCount; l++ )
        {
            const int32_t offset = l * numberOfGradientElements;

            for ( int32_t i = 0; i < gradientResolution.y; i++ )
            {
                for ( int32_t j = 0; j < gradientResolution.x; j++ )
                {
                    const int32_t k = gradientResolution.y - 1 - i;
                    const int32_t sourceIndex = i * gradientResolution.x + j;
                    const int32_t targetIndex = k * gradientResolution.x + j;

                    result->gradients32f[offset + targetIndex].x = complexGradient[offset + sourceIndex][0];
                    result->gradients32f[offset + targetIndex].y = complexGradient[offset + sourceIndex][1];
                }
            }
        }
    }

    if ( item->displacementXdXdZ != NULL && item->displacementZdXdZ != NULL )
    {
        for ( int32_t l = 0; l < lodCount; l++ )
        {
            const int32_t offset = l * numberOfGradientElements;

            for ( int32_t i = 0; i < gradientResolution.y; i++ )
            {
                for ( int32_t j = 0; j < gradientResolution.x; j++ )
                {
                    const int32_t k = gradientResolution.y - 1 - i;
                    const int32_t sourceIndex = i * gradientResolution.x + j;
                    const int32_t targetIndex = k * gradientResolution.x + j;

                    result->displacementDerivatives32f[offset + targetIndex].x = complexDisplacementXdXdZ[offset + sourceIndex][0];
                    result->displacementDerivatives32f[offset + targetIndex].y = complexDisplacementXdXdZ[offset + sourceIndex][1];
                    result->displacementDerivatives32f[offset + targetIndex].z = complexDisplacementZdXdZ[offset + sourceIndex][0];
                    result->displacementDerivatives32f[offset + targetIndex].w = complexDisplacementZdXdZ[offset + sourceIndex][1];
                }
            }
        }
    }

    FFTWF_SAFE_FREE(complexHeights);
    FFTWF_SAFE_FREE(complexDisplacement);
    FFTWF_SAFE_FREE(complexGradient);
    FFTWF_SAFE_FREE(complexDisplacementXdXdZ);
    FFTWF_SAFE_FREE(complexDisplacementZdXdZ);

    heightfield_hf_compute_min_max(result);
    heightfield_hf_compute_min_max_displacements(result);
    heightfield_hf_compute_min_max_gradients(result);
    heightfield_hf_compute_min_max_displacement_derivatives(result);

    result->timings[H0_GEN_TIMING] = item->timings[H0_GEN_TIMING];
    result->timings[H_GEN_TIMING] = item->timings[H_GEN_TIMING];
    result->timings[QSWAP_TIMING] = item->timings[QSWAP_TIMING];
    result->timings[HEIGHTS_FFT_TIMING] = heightTime;
    result->timings[DISPLACEMENTS_FFT_TIMING] = displacementTime;
    result->timings[GRADIENTS_FFT_TIMING] = gradientTime;
    result->timings[DISP_DERIVATIVES_FFT_TIMING] = dispDerivativesTime;
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
                     || item.geometry.sizes == NULL )
                {
                    process = NO;
                }

                if ( process == YES )
                {
                    OdHeightfieldData result = heightfield_zero();

                    heightfield_hf_init_with_geometry_and_options(
                                &result,
                                &item.geometry,
                                item.options);

                    [ self transformSpectra:&item into:&result ];

                    {
                        [ heightfieldQueueMutex lock ];

                        OdSpectrumVariance variance;
                        variance.baseSpectrum = item.baseSpectrum;
                        variance.maxMeanSlopeVariance = item.maxMeanSlopeVariance;
                        variance.effectiveMeanSlopeVariance = item.effectiveMeanSlopeVariance;

                        [ varianceQueue addPointer:&variance ];
                        [ resultQueue addHeightfield:&result ];


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

+ (void) initialize
{
    transformTimer = [[ NPTimer alloc ] initWithName:@"Transform Timer" ];
}

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

    lastOptions = 0;
    options = generatorOptions = defaultOptions;

    lastSpectrumType = ULONG_MAX;
    spectrumType = generatorSpectrumType = defaultSpectrumType;

    windDirection = defaultWindDirection;

    lastWindSpeed = DBL_MAX;
    windSpeed = generatorWindSpeed = defaultWindSpeed;

    lastSize = DBL_MAX;
    size = generatorSize = defaultSize;

    lastFetch = DBL_MAX;
    fetch = generatorFetch = defaultFetch;

    lastSpectrumScale = DBL_MAX;
    spectrumScale = generatorSpectrumScale = defaultSpectrumScale;

    const NSUInteger pfoptions
        = NSPointerFunctionsMallocMemory
          | NSPointerFunctionsStructPersonality
          | NSPointerFunctionsCopyIn;

    NSPointerFunctions * pFunctionsSpectrum
        = [ NSPointerFunctions pointerFunctionsWithOptions:pfoptions ];

    NSPointerFunctions * pFunctionsVariance
        = [ NSPointerFunctions pointerFunctionsWithOptions:pfoptions ];

    [ pFunctionsSpectrum setSizeFunction:&od_freq_spectrum_size ];
    [ pFunctionsVariance setSizeFunction:&od_variance_size];

    spectrumQueue = [[ NSPointerArray alloc ] initWithPointerFunctions:pFunctionsSpectrum ];
    varianceQueue = [[ NSPointerArray alloc ] initWithPointerFunctions:pFunctionsVariance ];

    resultQueue = [[ ODHeightfieldQueue alloc ] init ];

    projector = [[ ODProjector alloc ] initWithName:@"Projector" ];
    basePlane = [[ ODBasePlane alloc ] initWithName:@"BasePlane" ];
    [ basePlane setProjector:projector ];

    sizesStorage = [[ NPBufferObject alloc ] initWithName:@"Sizes Storage" ];
    sizes = [[ NPTextureBuffer alloc ] initWithName:@"Sizes Texture Buffer" ];

    baseSpectrum = [[ NPTexture2DArray alloc ] initWithName:@"Base Spectrum Texture" ];

    heightfield  = [[ NPTexture2DArray alloc ] initWithName:@"Height Texture" ];
    displacement = [[ NPTexture2DArray alloc ] initWithName:@"Height Texture Displacement" ];
    gradient     = [[ NPTexture2DArray alloc ] initWithName:@"Height Texture Gradient" ];

    displacementDerivatives
        = [[ NPTexture2DArray alloc ] initWithName:@"Height Texture Displacement Derivatives" ];

    waterColor
        = [[[ NPEngineGraphics instance ] textures2D ] getAssetWithFileName:@"WaterColor.png" ];

    waterColorIntensity
        = [[[ NPEngineGraphics instance ] textures2D ] getAssetWithFileName:@"BlackToWhiteRamp.png" ];

    ASSERT_RETAIN(waterColor);
    ASSERT_RETAIN(waterColorIntensity);

    waterColorCoordinate = v2_zero();
    waterColorIntensityCoordinate = v2_one();

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

    displacementScale = defaultDisplacementScale;

    receivedHeight = NO;
    receivedDisplacement = NO;
    receivedGradient = NO;
    receivedDisplacementDerivatives = NO;

    heightRanges = gradientXRanges = gradientZRanges
        = displacementXRanges = displacementZRanges = displacementXdXRanges
        = displacementXdZRanges = displacementZdXRanges = displacementZdZRanges
        = NULL;

    baseSpectrumResolution = iv2_zero();
    baseSpectrumSize = v2_zero();
    baseSpectrumDeltaVariance = 0.0f;
    updateSlopeVariance = NO;

    animated = YES;

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

    DESTROY(waterColor);
    DESTROY(waterColorIntensity);
    DESTROY(heightfield);
    DESTROY(displacement);
    DESTROY(displacementDerivatives);
    DESTROY(gradient);
    DESTROY(baseSpectrum);
    DESTROY(sizesStorage);
    DESTROY(sizes);
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

- (ODProjector *) projector
{
    return projector;
}

- (ODBasePlane *) basePlane
{
    return basePlane;
}

- (NPTexture2DArray *) baseSpectrum
{
    return baseSpectrum;
}

- (NPTextureBuffer *) sizes
{
    return sizes;
}

- (NPTexture2DArray *) heightfield
{
    return heightfield;
}

- (NPTexture2DArray *) displacement
{
    return displacement;
}

- (NPTexture2DArray *) gradient
{
    return gradient;
}

- (NPTexture2DArray *) displacementDerivatives
{
    return displacementDerivatives;
}

- (NPTexture2D *) waterColor
{
    return waterColor;
}

- (NPTexture2D *) waterColorIntensity
{
    return waterColorIntensity;
}

- (double) displacementScale
{
    return displacementScale;
}

- (Vector2) waterColorCoordinate
{
    return waterColorCoordinate;
}

- (Vector2) waterColorIntensityCoordinate
{
    return waterColorIntensityCoordinate;
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
    const double totalElapsedTime
        = [[[ NPEngineCore instance ] timer ] totalElapsedTime ];

    BOOL settingsChanged = NO;

    // in case spectrum generation settings changed
    // update the generator thread's' settings and clear
    // the resultQueue of still therein residing data
    if ( spectrumType != lastSpectrumType
         || numberOfLods != lastNumberOfLods
         || options != lastOptions
         || windSpeed != lastWindSpeed
         || size != lastSize
         || fetch != lastFetch
         || spectrumScale != lastSpectrumScale
         || geometryResolutionIndex != lastGeometryResolutionIndex
         || gradientResolutionIndex != lastGradientResolutionIndex )
    {
        lastSpectrumType = spectrumType;
        lastNumberOfLods = numberOfLods;
        lastOptions = options;
        lastWindSpeed = windSpeed;
        lastSize = size;
        lastFetch = fetch;
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
        generatorOptions = options;
        generatorWindSpeed = windSpeed;
        generatorSize = size;
        generatorFetch = fetch;
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

                /*
                NSRange range = NSMakeRange(1, resultQueueCount - 1);
                [ varianceQueue removePointersInRange:range ];
                [ resultQueue removeHeightfieldsInRange:range ];
                */
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
        receivedHeight = NO;
        receivedDisplacement = NO;
        receivedGradient = NO;
        receivedDisplacementDerivatives = NO;

        SAFE_FREE(heightRanges);
        SAFE_FREE(gradientXRanges);
        SAFE_FREE(gradientZRanges);
        SAFE_FREE(displacementXRanges);
        SAFE_FREE(displacementZRanges);
        SAFE_FREE(displacementXdXRanges);
        SAFE_FREE(displacementXdZRanges);
        SAFE_FREE(displacementZdXRanges);
        SAFE_FREE(displacementZdZRanges);

        //---------------------------------------------

        // geometry sizes texture buffer update
        const uint32_t lodCount = hf->geometry.numberOfLods;
        FVector2 geometrySizes[lodCount];

        for ( uint32_t i = 0; i < lodCount; i++ )
        {
            geometrySizes[i] = fv2_v_from_v2(&hf->geometry.sizes[i]);
        }

        NSData * geometrySizesData
            = [ NSData dataWithBytesNoCopyNoFree:geometrySizes
                                          length:lodCount * sizeof(FVector2) ];

        [ sizesStorage generate:NpBufferObjectTypeTexture
                     updateRate:NpBufferDataUpdateOftenUseOften
                      dataUsage:NpBufferDataWriteCPUToGPU
                     dataFormat:NpBufferDataFormatFloat32
                     components:2
                           data:geometrySizesData
                     dataLength:[ geometrySizesData length ]
                          error:NULL ];

        [ sizes
            attachBuffer:sizesStorage
        numberOfElements:0
             pixelFormat:NpTexturePixelFormatRG
              dataFormat:NpTextureDataFormatFloat32 ];

        //---------------------------------------------

        // ranges update

        heightRanges          = ALLOC_ARRAY(FVector2, lodCount);
        gradientXRanges       = ALLOC_ARRAY(FVector2, lodCount);
        gradientZRanges       = ALLOC_ARRAY(FVector2, lodCount);
        displacementXRanges   = ALLOC_ARRAY(FVector2, lodCount);
        displacementZRanges   = ALLOC_ARRAY(FVector2, lodCount);
        displacementXdXRanges = ALLOC_ARRAY(FVector2, lodCount);
        displacementXdZRanges = ALLOC_ARRAY(FVector2, lodCount);
        displacementZdXRanges = ALLOC_ARRAY(FVector2, lodCount);
        displacementZdZRanges = ALLOC_ARRAY(FVector2, lodCount);

        double minHeight = 0.0;
        double maxHeight = 0.0;

        for ( uint32_t i = 0; i < lodCount; i++ )
        {
            heightRanges[i]          = hf->ranges[i * NUMBER_OF_RANGES + HEIGHT_RANGE];
            gradientXRanges[i]       = hf->ranges[i * NUMBER_OF_RANGES + GRADIENT_X_RANGE];
            gradientZRanges[i]       = hf->ranges[i * NUMBER_OF_RANGES + GRADIENT_Z_RANGE];
            displacementXRanges[i]   = hf->ranges[i * NUMBER_OF_RANGES + DISPLACEMENT_X_RANGE];
            displacementZRanges[i]   = hf->ranges[i * NUMBER_OF_RANGES + DISPLACEMENT_Z_RANGE];
            displacementXdXRanges[i] = hf->ranges[i * NUMBER_OF_RANGES + DISPLACEMENT_X_DX_RANGE];
            displacementXdZRanges[i] = hf->ranges[i * NUMBER_OF_RANGES + DISPLACEMENT_X_DZ_RANGE];
            displacementZdXRanges[i] = hf->ranges[i * NUMBER_OF_RANGES + DISPLACEMENT_Z_DX_RANGE];
            displacementZdZRanges[i] = hf->ranges[i * NUMBER_OF_RANGES + DISPLACEMENT_Z_DZ_RANGE];

            minHeight += heightRanges[i].x;
            maxHeight += heightRanges[i].y;
        }

        [ projector setLowerBound:minHeight ];
        [ projector setUpperBound:maxHeight ];

        //---------------------------------------------

        {
            const IVector2 geometryResolution = hf->geometry.geometryResolution;
            const IVector2 gradientResolution = hf->geometry.gradientResolution;

            const NSUInteger numberOfGeometryBytes
                = geometryResolution.x * geometryResolution.y
                  * lodCount * sizeof(float);

            const NSUInteger numberOfGradientBytes
                = gradientResolution.x * gradientResolution.y
                  * lodCount * sizeof(float);


            if ( hf->heights32f != NULL )
            {
                receivedHeight = YES;

                NSData * heightsData
                    = [ NSData dataWithBytesNoCopyNoFree:hf->heights32f
                                                  length:numberOfGeometryBytes ];

                [ heightfield generateUsingWidth:geometryResolution.x
                                          height:geometryResolution.y
                                          layers:lodCount
                                     pixelFormat:NpTexturePixelFormatR
                                      dataFormat:NpTextureDataFormatFloat32
                                         mipmaps:YES
                                            data:heightsData ];
            }

            if ( hf->displacements32f != NULL )
            {
                receivedDisplacement = YES;

                NSData * displacementsData
                    = [ NSData dataWithBytesNoCopyNoFree:hf->displacements32f
                                                  length:numberOfGeometryBytes * 2 ];

                [ displacement generateUsingWidth:geometryResolution.x
                                           height:geometryResolution.y
                                          layers:lodCount
                                      pixelFormat:NpTexturePixelFormatRG
                                       dataFormat:NpTextureDataFormatFloat32
                                          mipmaps:YES
                                             data:displacementsData ];
            }

            if ( hf->gradients32f != NULL )
            {
                receivedGradient = YES;

                NSData * gradientsData
                    = [ NSData dataWithBytesNoCopyNoFree:hf->gradients32f
                                                  length:numberOfGradientBytes * 2 ];

                [ gradient generateUsingWidth:gradientResolution.x
                                       height:gradientResolution.y
                                       layers:lodCount
                                  pixelFormat:NpTexturePixelFormatRG
                                   dataFormat:NpTextureDataFormatFloat32
                                      mipmaps:YES
                                         data:gradientsData ];
            }

            if ( hf->displacementDerivatives32f != NULL )
            {
                receivedDisplacementDerivatives = YES;

                NSData * displacementDerivativesData
                    = [ NSData dataWithBytesNoCopyNoFree:hf->displacementDerivatives32f
                                                  length:numberOfGradientBytes * 4 ];

                [ displacementDerivatives
                    generateUsingWidth:gradientResolution.x
                                height:gradientResolution.y
                                layers:lodCount
                           pixelFormat:NpTexturePixelFormatRGBA
                            dataFormat:NpTextureDataFormatFloat32
                               mipmaps:YES
                                  data:displacementDerivativesData ];
            }

            if ( variance != NULL && variance->baseSpectrum != NULL )
            {
                baseSpectrumSize = hf->geometry.sizes[0];
                baseSpectrumResolution.x = MAX(geometryResolution.x, gradientResolution.x);
                baseSpectrumResolution.y = MAX(geometryResolution.y, gradientResolution.y);

                const NSUInteger numberOfBaseSpectrumBytes
                    = baseSpectrumResolution.x * baseSpectrumResolution.y 
                      * lodCount * sizeof(float);

                NSData * baseSpectrumData
                    = [ NSData dataWithBytesNoCopyNoFree:variance->baseSpectrum
                                                  length:numberOfBaseSpectrumBytes ];

                [ baseSpectrum generateUsingWidth:baseSpectrumResolution.x
                                           height:baseSpectrumResolution.y
                                           layers:lodCount
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
        }

        //[ resultQueue removeHeightfieldAtIndex:0 ];
        //[ varianceQueue removePointerAtIndex:0 ];
    }

    [ projector update:frameTime ];
    [ basePlane update:frameTime ];
}

- (void) renderBasePlane
{
    [ basePlane render ];
}

@end

