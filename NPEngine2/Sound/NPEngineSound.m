#import <Foundation/NSObject.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSError.h>
#import "Log/NPLog.h"
#import "Core/Basics/NpBasics.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "NPEngineSoundErrors.h"
#import "NPListener.h"
#import "NPSoundSources.h"
#import "NPEngineSound.h"

static NPEngineSound * NP_ENGINE_SOUND = nil;

@interface NPEngineSound (Private)

- (BOOL) startupOpenAL;
- (void) shutdownOpenAL;

@end

@implementation NPEngineSound

+ (void) initialize
{
	if ( [ NPEngineSound class ] == self )
	{
		[[ self alloc ] init ];
	}
}

+ (NPEngineSound *) instance
{
    return NP_ENGINE_SOUND;
} 

+ (id) allocWithZone:(NSZone*)zone
{
    if ( self != [ NPEngineSound class ] )
    {
        [ NSException raise:NSInvalidArgumentException
	                 format:@"Illegal attempt to subclass NPEngineSound as %@", self ];
    }

    if ( NP_ENGINE_SOUND == nil )
    {
        NP_ENGINE_SOUND = [ super allocWithZone:zone ];
    }

    return NP_ENGINE_SOUND;
}

- (id) init
{
    self = [ super init ];

    objectID = crc32_of_pointer(self);

    listener = [[ NPListener alloc ] initWithName:@"NPEngine Sound Listener" ];
    sources = [[ NPSoundSources alloc ] initWithName:@"NPEngine Sound Sources" ];

    samples = [[ NPAssetArray alloc ]
                    initWithName:@"NP Engine Sound Samples"
                      assetClass:NSClassFromString(@"NPSoundSample") ];

    streams = [[ NPAssetArray alloc ]
                    initWithName:@"NP Engine Sound Streams"
                      assetClass:NSClassFromString(@"NPSoundStream") ];

    if (samples == nil || streams == nil)
    {
        NSLog(@"FUCK");
    }


    volume = 1.0f;

    return self;
}

- (void) dealloc
{
    DESTROY(samples);
    DESTROY(streams);
    DESTROY(sources);
    DESTROY(listener);

    [ self shutdownOpenAL ];
    [ super dealloc ];
}

- (NSString *) name
{
    return @"NPEngine Sound";
}

- (uint32_t) objectID
{
    return objectID;
}

- (void) setName:(NSString *)newName
{
}

- (void) setObjectID:(uint32_t)newObjectID
{
}

- (Float) volume
{
    return volume;
}

- (void) setVolume:(Float)newVolume
{
    volume = newVolume;
}

- (NPListener *) listener
{
    return listener;
}

- (NPSoundSources *) sources
{
    return sources;
}

- (NPAssetArray *) samples
{
    return samples;
}

- (NPAssetArray *) streams
{
    return streams;
}

- (BOOL) startup
{
    NPLOG(@"");
    NPLOG(@"NPEngine Sound initialising...");

    BOOL result = [ self startupOpenAL ];
    if ( result == NO )
    {
        return NO;
    }

    result = result && [ sources startup ];
    if ( result == NO )
    {
        return NO;
    }

    NPLOG(@"NPEngine Sound up and running");
    NPLOG(@"");

    return YES;
}

- (void) shutdown
{
    NPLOG(@"");
    NPLOG(@"NPEngine Sound shutting down...");

    [ sources shutdown ];
    [ self shutdownOpenAL ];

    NPLOG(@"NPEngine Sound shut down");
    NPLOG(@"");
}

- (BOOL) checkForALError:(NSError **)error
{
    if ( device != NULL )
    {
        ALCenum alcError = alcGetError(device);
        if( alcError != ALC_NO_ERROR )
        {
            if ( error != NULL )
            {
                NSString * errorString
                    = [ NSString stringWithUTF8String:alcGetString(device, alcError) ];

                *error = [ NSError errorWithCode:NPOpenALCError
                                     description:errorString ];
            }

            return NO;
        }
    }

    ALenum alError = alGetError();
    if( alError != AL_NO_ERROR )
    {
        if ( error != NULL )
        {
            NSString * errorString
                = [ NSString stringWithUTF8String:alGetString(alError) ];

            *error = [ NSError errorWithCode:NPOpenALError
                                 description:errorString ];
        }

        return NO;
    }

    return YES;
}

- (void) checkForALErrors
{
    NSError * error = nil;
    while ( [ self checkForALError:&error ] == NO )
    {
        NPLOG_ERROR(error);
        error = nil;
    }    
}

- (void) update
{
    [ listener update ];
    [ sources update ];

    [ self checkForALErrors ];
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return ULONG_MAX;
} 

- (void) release
{
    //do nothing
} 

- (id) autorelease
{
    return self;
}

@end

@implementation NPEngineSound (Private)

- (BOOL) startupOpenAL
{
    NPLOG(@"Opening default OpenAL device");

    device = alcOpenDevice(NULL);
    if ( device == NULL )
    {
        [ self checkForALErrors ];
        return NO;
    }

    NPLOG(@"Default device: %s", alcGetString(device, ALC_DEFAULT_DEVICE_SPECIFIER));

    ALCint major, minor;
    alcGetIntegerv(device, ALC_MAJOR_VERSION, 1, &major);
    alcGetIntegerv(device, ALC_MINOR_VERSION, 1, &minor);

    NPLOG(@"ALC version: %d.%d", (int)major, (int)minor);

    context = alcCreateContext(device, NULL);
    if ( context == NULL )
    {
        [ self checkForALErrors ];
        return NO;
    }

    ALCboolean success = alcMakeContextCurrent(context);
    if ( success == ALC_FALSE )
    {
        [ self checkForALErrors ];
        return NO;
    }

    NPLOG(@"OpenAL vendor string: %s", alGetString(AL_VENDOR));
    NPLOG(@"OpenAL renderer string: %s", alGetString(AL_RENDERER));
    NPLOG(@"OpenAL version string: %s", alGetString(AL_VERSION));

    return YES;
}

- (void) shutdownOpenAL
{
    alcMakeContextCurrent(NULL);

    if ( context != NULL )
    {
        alcDestroyContext(context);
        context = NULL;
    }

    if ( device != NULL )
    {
        alcCloseDevice(device);
        device = NULL;
    }
}

@end

