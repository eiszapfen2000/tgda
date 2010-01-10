#import "NPSoundSample.h"
#import "NP.h"

@implementation NPSoundSample

- (id) init
{
    return [ self initWithName:@"Sound Sample" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    alID = UINT_MAX;
    volume = 1.0f;
    length = 0.0f;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) deleteALBuffer
{
    if ( alID > 0 && alID < UINT_MAX )
    {
        alDeleteBuffers(1, &alID);
        alID = UINT_MAX;
    }
}

- (void) generateALBuffer
{
    [ self deleteALBuffer ];

    alGenBuffers(1, &alID);
}

- (UInt32) alID
{
    return alID;
}

- (Float) volume
{
    return volume;
}

- (Float) range
{
    return range;
}

- (Float) length
{
    return length;
}

- (void) clear
{
    [ self deleteALBuffer ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    [ self setName:path ];

    ALenum format;
    Byte * data = NULL;
    ALsizei size;
    ALsizei frequency;
    ALboolean loop;
    ALint bitDepth;

    const char * string = [ path cStringUsingEncoding:NSASCIIStringEncoding ];
    alutLoadWAVFile((char *)string, &format, (void **)(&data), &size, &frequency, &loop);

    [ self generateALBuffer ];
    alBufferData(alID, format, data, size, frequency);

    alutUnloadWAV(format, data, size, frequency);

    alGetBufferi(alID, AL_BITS, &bitDepth);
    length = ldiv((size * 8), bitDepth).quot / frequency;

    return YES;
}

@end
