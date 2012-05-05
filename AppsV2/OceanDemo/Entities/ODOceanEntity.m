#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSPointerArray.h>
#import <Foundation/NSThread.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/Thread/NPSemaphore.h"
#import "Core/Timer/NPTimer.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/NPOrthographic.h"
#import "Graphics/NPEngineGraphics.h"
#import "ODProjector.h"
#import "ODProjectedGrid.h"
#import "Ocean/ODPhillipsSpectrum.h"
#import "Ocean/ODGaussianRNG.h"
#import "fftw3.h"
#import "ODOceanEntity.h"

static NPSemaphore * semaphore = nil;
static NSLock * mutex = nil;

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

typedef struct
{
    IVector2 resolution;
    Vector2 size;
    float  * data32f;
    double * data64f;
}
OdHeightfieldData;

@interface ODOceanEntity (Private)

- (void) generate:(id)argument;

@end

@implementation ODOceanEntity (Private)

- (void) generate:(id)argument
{
    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    NPTimer * timer = [[ NPTimer alloc ] initWithName:@"Thread Timer" ];
    ODPhillipsSpectrum * s = [[ ODPhillipsSpectrum alloc ] init ];

    while ( [[ NSThread currentThread ] isCancelled ] == NO )
    {    
        [ semaphore wait ];

        NSAutoreleasePool * innerPool = [ NSAutoreleasePool new ];

        if ( [[ NSThread currentThread ] isCancelled ] == NO )
        {
            ODSpectrumSettings settings;

            {
                [ mutex lock ];
                settings = spectrumSettings;
                [ mutex unlock ];
            }

            float * c2r = ALLOC_ARRAY(float, settings.resolution.x * settings.resolution.y);

            OdHeightfieldData * result = ALLOC(OdHeightfieldData);
            result->size = settings.size;
            result->resolution = settings.resolution;
            result->data32f = NULL;
            result->data64f = NULL;

            [ timer update ];

            const float totalTime = [ timer totalElapsedTime ];

            fftwf_complex * halfcomplexSpectrum
                = [ s generateFloatFrequencySpectrumHC:settings atTime:totalTime ];

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
            fftwf_plan plan;
            plan = fftwf_plan_dft_c2r_2d(settings.resolution.x,
                                        settings.resolution.y,
                                        halfcomplexSpectrum,
                                        c2r,
                                        FFTW_ESTIMATE);

            fftwf_execute(plan);
            fftwf_destroy_plan(plan);
            [ timer update ];

            const float fpsIFFTHC = [ timer frameTime ];
            //printf("PHILLIPS HC: %f IFFT: %f Time:%f\n", fpsHC, fpsIFFTHC, totalTime);
            //fflush(stdout);

            fftwf_free(halfcomplexSpectrum);

            result->data32f = c2r;

            {
                [ mutex lock ];
                [ resultQueue addPointer:result ];
                [ mutex unlock ];
            }
        }

        DESTROY(innerPool);
    }    

    DESTROY(s);
    DESTROY(timer);
    DESTROY(pool);
}

@end

static const Vector2 defaultWindDirection = {1.0, 0.0};
static const int32_t resolutions[4] = {64, 128, 256, 512};
static const NSUInteger defaultResolutionIndex = 0;

@implementation ODOceanEntity

- (id) init
{
    return [ self initWithName:@"ODOceanEntity" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    lastResolutionIndex = ULONG_MAX;
    resolutionIndex = defaultResolutionIndex;

    lastWindDirection = (Vector2){DBL_MAX, DBL_MAX};
    windDirection = defaultWindDirection;

    NSPointerFunctionsOptions options
        = NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality;
    resultQueue = [[ NSPointerArray alloc ] initWithOptions:options ];

    projector = [[ ODProjector alloc ] initWithName:@"Projector" ];
    projectedGrid = [[ ODProjectedGrid alloc ] initWithName:@"Projected Grid" ];
    [ projectedGrid setProjector:projector ];

    heightfield = [[ NPTexture2D alloc ] initWithName:@"Height Texture" ];

    effect
        = [[[ NPEngineGraphics instance ] effects ]
                getAssetWithFileName:@"fullscreen.effect" ];

    ASSERT_RETAIN(effect);

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(stateset);
    DESTROY(effect);
    DESTROY(heightfield);
    DESTROY(projector);
    DESTROY(projectedGrid);

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
    DESTROY(resultQueue);

    [ super dealloc ];
}

- (void) start
{
    odgaussianrng_initialise();

    if ( semaphore == nil )
    {
        semaphore = [[ NPSemaphore alloc ] init ];
    }

    if ( mutex == nil )
    {
        mutex = [[ NSLock alloc ] init ];
    }

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
            [ semaphore post ];

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

    SAFE_DESTROY(semaphore);
    SAFE_DESTROY(mutex);

    odgaussianrng_shutdown();
}

- (ODProjector *) projector
{
    return projector;
}

- (ODProjectedGrid *) projectedGrid
{
    return projectedGrid;
}

- (void) setCamera:(ODCamera *)newCamera
{
    [ projector setCamera:newCamera ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    NSAssert(config != nil, @"");

    NSString * oceanName = [ config objectForKey:@"Name" ];
    NSArray  * resolutionStrings = [ config objectForKey:@"Resolution" ];

    if ( resolutionStrings == nil )
    {
        if ( error != NULL )
        {
            *error = nil;
        }
        
        return NO;
    }

    [ self setName:oceanName ];

    IVector2 resolution;
    resolution.x = [[ resolutionStrings objectAtIndex:0 ] intValue ];
    resolution.y = [[ resolutionStrings objectAtIndex:1 ] intValue ];

    [ projectedGrid setResolution:resolution ];

    return YES;
}

- (void) update:(const float)frameTime
{
    [ projector     update:frameTime ];
    [ projectedGrid update:frameTime ];

    {
        [ mutex lock ];

        if ( windDirection.x != lastWindDirection.x
             || windDirection.y != lastWindDirection.y
             || resolutionIndex != lastResolutionIndex )
        {
            spectrumSettings.windDirection = windDirection;
            spectrumSettings.size = (Vector2){10.0, 10.0};

            const int32_t res = resolutions[resolutionIndex];
            spectrumSettings.resolution = (IVector2){res, res};

            lastWindDirection = windDirection;
            lastResolutionIndex = resolutionIndex;

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
        }

        [ mutex unlock ];
    }

    [ semaphore post ];
}

- (void) render
{
    OdHeightfieldData * hf = NULL;

    {
        [ mutex lock ];

        if ( [ resultQueue count ] != 0)
        {
            hf = [ resultQueue pointerAtIndex:0 ];
            [ resultQueue removePointerAtIndex:0 ];
        }

        [ mutex unlock ];
    }

    if ( hf != NULL )
    {
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

        SAFE_FREE(hf->data32f);
        FREE(hf);
    }

    [ projectedGrid render:heightfield ];
    [ projector render ];

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
}

@end

