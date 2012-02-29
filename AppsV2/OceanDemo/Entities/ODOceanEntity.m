#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSThread.h>
#import "Core/Timer/NPTimer.h"
#import "Core/Thread/NPSemaphore.h"
#import "ODProjector.h"
#import "ODProjectedGrid.h"
#import "Ocean/ODPhillipsSpectrum.h"
#import "Ocean/ODGaussianRNG.h"
#import "fftw3.h"
#import "ODOceanEntity.h"

static NPSemaphore * semaphore = nil;
static NSLock * mutex = nil;

@interface ODOceanEntity (Private)

- (void) generate:(id)argument;

@end

@implementation ODOceanEntity (Private)

- (void) generate:(id)argument
{
    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    NPTimer * timer = [[ NPTimer alloc ] initWithName:@"Thread Timer" ];

    ODSpectrumSettings settings;
    settings.size = (Vector2){10.0f, 10.0f};
    settings.resolution = (IVector2){256, 256};
    settings.windDirection = (Vector2){10.0f, 15.0f};

    ODPhillipsSpectrum * s = [[ ODPhillipsSpectrum alloc ] init ];

    fftw_complex * complexHeights
        = fftw_malloc(sizeof(fftw_complex) * settings.resolution.x * settings.resolution.y);

    fftw_complex * r2c = fftw_malloc(sizeof(fftw_complex) * settings.resolution.x * ((settings.resolution.y / 2) + 1));

    double * c2r = ALLOC_ARRAY(double, settings.resolution.x * settings.resolution.y);
    double * heights = ALLOC_ARRAY(double, settings.resolution.x * settings.resolution.y);

    while ( [[ NSThread currentThread ] isCancelled ] == NO )
    {    
        [ semaphore wait ];

        NSAutoreleasePool * innerPool = [ NSAutoreleasePool new ];

        if ( [[ NSThread currentThread ] isCancelled ] == NO )
        {
            [ timer update ];

            fftw_complex * complexSpectrum
                = [ s generateFrequencySpectrum:settings atTime:1.0];

            [ timer update ];

            const float fpsC = [ timer frameTime ];

            fftw_complex * halfcomplexSpectrum
                = [ s generateFrequencySpectrumHC:settings atTime:1.0];

            [ timer update ];

            const float fpsHC = [ timer frameTime ];

            printf("PHILLIPS: %f %f\n", fpsC, fpsHC);
            fflush(stdout);

            /*
            printf("spectrum\n");

            for ( int32_t j = 0; j < settings.resolution.y; j++ )
            {
                for ( int32_t k = 0; k < settings.resolution.x; k++ )
                {
                    printf("%f %fi ", complexSpectrum[k * settings.resolution.y + j][0], complexSpectrum[k * settings.resolution.y + j][1]);
                }

                printf("\n");
            }
            fflush(stdout);
            */
            
            /*
            printf("spectrumHC\n");

            for ( int32_t j = 0; j < ((settings.resolution.y/2)+1); j++ )
            {
                for ( int32_t k = 0; k < settings.resolution.x; k++ )
                {
                    printf("%f %fi ", halfcomplexSpectrum[k * ((settings.resolution.y/2)+1) + j][0], halfcomplexSpectrum[k * ((settings.resolution.y/2)+1) + j][1]);
                }

                printf("\n");
            }
            fflush(stdout);
            */


            [ timer update ];
            fftw_plan plan;
            plan = fftw_plan_dft_2d(settings.resolution.x,
                                    settings.resolution.y,
                                    complexSpectrum,
                                    complexHeights,
                                    FFTW_BACKWARD,
                                    FFTW_ESTIMATE);

            fftw_execute(plan);
            fftw_destroy_plan(plan);
            [ timer update ];

            const float fpsIFFTC = [ timer frameTime ];

            // write real part to result array
            for ( int32_t j = 0; j < settings.resolution.x; j++ )
            {
                for ( int32_t k = 0; k < settings.resolution.y; k++ )
                {
                    heights[k + settings.resolution.y * j] = complexHeights[k + settings.resolution.y * j][0];
                }
            }

            /*
            printf("heights\n");
            for ( int32_t j = 0; j < spectrumResolution.y; j++ )
            {
                for ( int32_t k = 0; k < spectrumResolution.x; k++ )
                {
                    printf("%f ", heights[k * spectrumResolution.y + j]);
                }

                printf("\n");
            }
            fflush(stdout);
            */

            /*
            plan = fftw_plan_dft_r2c_2d(spectrumResolution.x,
                                        spectrumResolution.y,
                                        heights,
                                        r2c,
                                        FFTW_ESTIMATE);

            fftw_execute(plan);
            fftw_destroy_plan(plan);
            */

            /*
            printf("r2c spectrum\n");
            for ( int32_t j = 0; j < ((spectrumResolution.y/2)+1); j++ )
            {
                for ( int32_t k = 0; k < spectrumResolution.x; k++ )
                {
                    printf("%f %fi ", r2c[k * ((spectrumResolution.y/2)+1) + j][0], r2c[k * ((spectrumResolution.y/2)+1) + j][1]);
                }

                printf("\n");
            }
            fflush(stdout);
            */

            [ timer update ];
            plan = fftw_plan_dft_c2r_2d(settings.resolution.x,
                                        settings.resolution.y,
                                        //r2c,
                                        halfcomplexSpectrum,
                                        c2r,
                                        FFTW_ESTIMATE);

            fftw_execute(plan);
            fftw_destroy_plan(plan);
            [ timer update ];

            const float fpsIFFTHC = [ timer frameTime ];

            /*
            printf("heights HC\n");
            for ( int32_t j = 0; j < spectrumResolution.y; j++ )
            {
                for ( int32_t k = 0; k < spectrumResolution.x; k++ )
                {
                    printf("%f ", c2r[k * spectrumResolution.y + j]);
                }

                printf("\n");
            }
            fflush(stdout);
            */

            printf("IFFT: %f %f\n", fpsIFFTC, fpsIFFTHC);
            fflush(stdout);

            /*
            printf("c2r spectrum\n");
            for ( int32_t j = 0; j < spectrumResolution.y; j++ )
            {
                for ( int32_t k = 0; k < spectrumResolution.x; k++ )
                {
                    printf("%f ", c2r[k * spectrumResolution.y + j] / (spectrumResolution.x * spectrumResolution.y));
                }
                printf("\n");
            }
            fflush(stdout);
            */

            fftw_free(complexSpectrum);
            fftw_free(halfcomplexSpectrum);
        }

        DESTROY(innerPool);
    }    

    fftw_free(complexHeights);
    fftw_free(r2c);
    SAFE_FREE(heights);
    SAFE_FREE(c2r);

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

    projector = [[ ODProjector alloc ] initWithName:@"Projector" ];
    projectedGrid = [[ ODProjectedGrid alloc ] initWithName:@"Projected Grid" ];
    [ projectedGrid setProjector:projector ];

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(stateset);

    DESTROY(projector);
    DESTROY(projectedGrid);

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
    [ semaphore post ];

    [ projector     update:frameTime ];
    [ projectedGrid update:frameTime ];
}

- (void) render
{
    [ projectedGrid render ];
    [ projector     render ];
}

@end

