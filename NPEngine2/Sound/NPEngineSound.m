#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSError.h>
#import "Log/NPLog.h"
#import "Core/Basics/NpBasics.h"
#import "Core/NPObject/NPObject.h"
#import "NPEngineSoundErrors.h"
#import "NPEngineSound.h"

static NPEngineSound * NP_ENGINE_SOUND = nil;

@interface NPEngineSound (Private)

- (BOOL) startupOpenAL:(NSError **)error;
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

    world = [[ NPSoundWorld alloc ] initWithName:@"NP Sound World" parent:self ];

    volume = 1.0f;

    return self;
}

- (void) dealloc
{
    [ self shutdownOpenAL ];
    DESTROY(world);

    [ super dealloc ];
}

- (NSString *) name
{
    return @"NPEngine Sound";
}

- (void) setName:(NSString *)newName
{

}

- (id <NPPObject>) parent
{
    return nil;
}

- (void) setParent:(id <NPPObject>)newParent
{
}

- (uint32_t) objectID
{
    return objectID;
}

- (Float) volume
{
    return volume;
}

- (void) setVolume:(Float)newVolume
{
    volume = newVolume;
}

- (NPSoundWorld *) world
{
    return world;
}

- (BOOL) startupOpenAL:(NSError **)error
{
    NPLOG(@"Opening default OpenAL device");

    device = alcOpenDevice(NULL);
    if ( device == NULL )
    {
        //NPLOG_ERROR_STRING(@"Failed to open OpenAL device");
        [ self checkForALError:error ];

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
        //NPLOG_ERROR_STRING(@"Failed to create OpenAL context");
        [ self checkForALError:error ];

        return NO;
    }

    ALCboolean success = alcMakeContextCurrent(context);
    if ( success == ALC_FALSE )
    {
        [ self checkForALError:error ];

        return NO;
    }

    NPLOG(@"OpenAL vendor string: %s", alGetString(AL_VENDOR));
    NPLOG(@"OpenAL renderer string: %s", alGetString(AL_RENDERER));
    NPLOG(@"OpenAL version string: %s", alGetString(AL_VERSION));

    return [ self checkForALError:error ];
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

- (BOOL) startup:(NSError **)error
{
    NPLOG(@"");
    NPLOG(@"NPEngine Sound initialising...");

    BOOL result = [ self startupOpenAL:error ];
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

    [ self shutdownOpenAL ];

    NPLOG(@"NPEngine Sound shut down");
    NPLOG(@"");
}

- (BOOL) checkForALError:(NSError **)error
{
    NSMutableDictionary * errorDetail = nil;
    NSString * errorString = nil;

    if ( device != NULL )
    {
        ALCenum alcError = alcGetError(device);
        if( alcError != ALC_NO_ERROR )
        {
            errorDetail = [ NSMutableDictionary dictionary ];
            errorString = [ NSString stringWithUTF8String:alcGetString(device, alcError) ];
            [ errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
   
            *error = [ NSError errorWithDomain:NPEngineErrorDomain 
                                          code:NPOpenALCError
                                      userInfo:errorDetail ];

            return NO;
        }
    }

    ALenum alError = alGetError();
    if( alError != AL_NO_ERROR )
    {
            errorDetail = [ NSMutableDictionary dictionary ];
            errorString = [ NSString stringWithUTF8String:alGetString(alError) ];
            [ errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
   
            *error = [ NSError errorWithDomain:NPEngineErrorDomain 
                                          code:NPOpenALError
                                      userInfo:errorDetail ];

            return NO;
    }

    return YES;
}

- (void) update
{
    [ world update ];

    // error forwarding mechanism!?

    NSError * error = nil;
    if ([ self checkForALError:&error ] == NO)
    {
        NPLOG_ERROR(error);
    }
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

