#import <Foundation/NSException.h>
#import "NPEngineSound.h"
#import "NP.h"

static NPEngineSound * NP_ENGINE_SOUND = nil;

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
    return [ self initWithName:@"NP Engine Sound" parent:nil ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
{
    self = [ super init ];

    ASSIGNCOPY(name, newName);
    objectID = crc32_of_pointer(self);

    volume = 1.0f;

    return self;
}

- (void) shutdownOpenAL
{
    alcMakeContextCurrent(NULL);
    alcDestroyContext(context);
    context = NULL;

    alcCloseDevice(device);
    device = NULL;
}

- (void) dealloc
{
    [ self shutdownOpenAL ];
    [ super dealloc ];
}

- (NSString *) name
{
    return @"NP Engine Sound";
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

- (void) setupOpenAL
{
    NPLOG(@"Opening default OpenAL device");

    device = alcOpenDevice(NULL);
    if ( device == NULL )
    {
        NPLOG_ERROR_STRING(@"Failed to open OpenAL device");
        [ self checkForALErrors ];

        return;
    }

    NPLOG(@"Default device: %s", alcGetString(device, ALC_DEFAULT_DEVICE_SPECIFIER));

    ALCint major, minor;
    alcGetIntegerv(device, ALC_MAJOR_VERSION, 1, &major);
    alcGetIntegerv(device, ALC_MINOR_VERSION, 1, &minor);

    NPLOG(@"ALC version: %d.%d", (int)major, (int)minor);

    context = alcCreateContext(device, NULL);
    if ( context == NULL )
    {
        NPLOG_ERROR_STRING(@"Failed to create OpenAL context");
        [ self checkForALErrors ];

        return;
    }

    ALCboolean success = alcMakeContextCurrent(context);
    if ( success == ALC_FALSE )
    {
        [ self checkForALErrors ];
    }

    NPLOG(@"OpenAL vendor string: %s", alGetString(AL_VENDOR));
    NPLOG(@"OpenAL renderer string: %s", alGetString(AL_RENDERER));
    NPLOG(@"OpenAL version string: %s", alGetString(AL_VERSION));

    [ self checkForALErrors ];
}

- (void) setup
{
    NPLOG(@"");
    NPLOG(@"%@ initialising...", name);
    NPLOG_PUSH_PREFIX(@"    ");

    [ self setupOpenAL ];

    NPLOG_POP_PREFIX();
    NPLOG(@"%@ up and running", name);
    NPLOG(@"");
}

- (void) checkForALErrors
{
    if ( device != NULL )
    {
        ALCenum error = alcGetError(device);
        if( error != ALC_NO_ERROR )
        {
            NPLOG_ERROR_STRING(@"%s", (const char*)alcGetString(device, error));
        }
    }

    ALenum error = alGetError();
    if( error != AL_NO_ERROR )
    {
        NPLOG_ERROR_STRING(@"%s", (const char*)alGetString(error));
    }
}

- (void) update
{
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

