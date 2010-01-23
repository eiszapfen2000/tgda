#import "NPEngineSound.h"
#import "NP.h"

static NPEngineSound * NP_ENGINE_SOUND = nil;

@implementation NPEngineSound

+ (NPEngineSound *)instance
{
    @synchronized(self)
    {
        if ( NP_ENGINE_SOUND == nil )
        {
            [[ self alloc ] init ];
        }
    }

    return NP_ENGINE_SOUND;
} 

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (NP_ENGINE_SOUND == nil)
        {
            NP_ENGINE_SOUND = [ super allocWithZone:zone ];
            return NP_ENGINE_SOUND;
        }
    }

    return nil;
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

    name = [ newName retain ];
    objectID = crc32_of_pointer(self);

    NPLOG(@"%@ initialising...", name);

    NPLOG_PUSH_PREFIX(@"    ");
    NPLOG(@"Opening default OpenAL device");

    device = alcOpenDevice(NULL);
    if ( device == NULL )
    {
        NPLOG_ERROR(@"Failed to open OpenAL device");
        [ self checkForALErrors ];

        return self;
    }

    NPLOG(@"Default device: %s", alcGetString(device, ALC_DEFAULT_DEVICE_SPECIFIER));

    ALCint major, minor;
    alcGetIntegerv(device, ALC_MAJOR_VERSION, 1, &major);
    alcGetIntegerv(device, ALC_MINOR_VERSION, 1, &minor);

    NPLOG(@"ALC version: %d.%d", (int)major, (int)minor);

    context = alcCreateContext(device, NULL);
    if ( context == NULL )
    {
        NPLOG_ERROR(@"Failed to create OpenAL context");
        [ self checkForALErrors ];

        return self;
    }

    ALCboolean success = alcMakeContextCurrent(context);
    if ( success == ALC_FALSE )
    {
        [ self checkForALErrors ];
    }

    NPLOG(@"OpenAL vendor string: %s", alGetString(AL_VENDOR));
    NPLOG(@"OpenAL renderer string: %s", alGetString(AL_RENDERER));
    NPLOG(@"OpenAL version string: %s", alGetString(AL_VERSION));

    NPLOG_POP_PREFIX();
    NPLOG(@"%@ up and running", name);
    NPLOG(@"");

    [ self checkForALErrors ];

    channels = [[ NPSoundChannels alloc ] initWithName:@"NP Sound Channels" parent:self ];
    soundManager = [[ NPSoundManager alloc ] initWithName:@"NP Sound Manager" parent:self ];    

    return self;
}

- (void) dealloc
{
    NPLOG(@"");
    NPLOG(@"%@ Dealloc", name);

    [ soundManager release ];
    [ channels release ];

    alcMakeContextCurrent(NULL);
    alcDestroyContext(context);
    context = NULL;

    alcCloseDevice(device);
    device = NULL;

    [ name release ];

    [ super dealloc ];
}

- (NSString *) name
{
    return name;
}

- (void) setName:(NSString *)newName
{
    ASSIGN(name, newName);
}

- (NPObject *) parent
{
    return nil;
}

- (void) setParent:(NPObject *)newParent
{
}

- (UInt32) objectID
{
    return objectID;
}

- (void) checkForALErrors
{
    if ( device != NULL )
    {
        ALCenum error = alcGetError(device);
        if( error != ALC_NO_ERROR )
        {
            NPLOG_ERROR(@"%s", (const char*)alcGetString(device, error));
        }
    }

    ALenum error = alGetError();
    if( error != AL_NO_ERROR )
    {
        NPLOG_ERROR(@"%s", (const char*)alGetString(error));
    }
}

- (void) update
{
    [ channels update ];

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
    return UINT_MAX;  //denotes an object that cannot be released
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

