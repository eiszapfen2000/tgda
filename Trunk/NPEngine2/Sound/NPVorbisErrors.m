#import <vorbis/vorbisfile.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import "Core/NPObject/NPObject.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "NPEngineSoundErrors.h"
#import "NPVorbisErrors.h"

static NSString * const NPVorbisReadErrorString = @"A read from media returned an error.";
static NSString * const NPVorbisNotVorbisErrorString = @"Bitstream is not Vorbis data.";
static NSString * const NPVorbisVersionMismatchErrorString = @"Vorbis version mismatch.";
static NSString * const NPVorbisBadHeaderErrorString = @"Invalid Vorbis bitstream header.";
static NSString * const NPVorbisInternalErrorString = @"Internal logic fault; indicates a bug or heap/stack corruption.";

static NSString * const NPVorbisHoleErrorString = @"Data interruption.";
static NSString * const NPVorbisBadLinkErrorString = @"Invalid stream section, or the requested link is corrupt.";
static NSString * const NPVorbisBadInputErrorString = @"Initial file headers couldn't be read or are corrupt.";

NSString * const NPVorbisNumberOfChannelsErrorString = @"Unsupported number of channels.";

@implementation NPVorbisErrors

+ (NSError *) vorbisOpenError:(int)error
{
    NSString * errorString = nil;
    int32_t errorCode = 0;

    switch ( error )
    {
        case OV_EREAD:
            errorString = NPVorbisReadErrorString;
            errorCode = NPVorbisReadError;
            break;
        case OV_ENOTVORBIS:
            errorString = NPVorbisNotVorbisErrorString;
            errorCode = NPVorbisStreamNotVorbisError;
            break;
        case OV_EVERSION:
            errorString = NPVorbisVersionMismatchErrorString;
            errorCode = NPVorbisVersionMismatchError;
            break;
        case OV_EBADHEADER:
            errorString = NPVorbisBadHeaderErrorString;
            errorCode = NPVorbisBadHeaderError;
            break;
        case OV_EFAULT:
            errorString = NPVorbisInternalErrorString;
            errorCode = NPVorbisInternalError;
            break;

        default:
            break;
    }

    NSMutableDictionary * errorDetail = [ NSMutableDictionary dictionary ];
    [ errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
   
    return [ NSError errorWithDomain:NPEngineErrorDomain 
                                code:errorCode
                            userInfo:errorDetail ];
}

+ (NSError *) vorbisReadError:(long)error
{
    NSString * errorString = nil;
    int32_t errorCode = 0;

    switch ( error )
    {
        case OV_HOLE:
            errorString = NPVorbisHoleErrorString;
            errorCode = NPVorbisHoleError;
            break;
        case OV_EBADLINK:
            errorString = NPVorbisBadLinkErrorString;
            errorCode = NPVorbisBadLinkError;
            break;
        case OV_EINVAL:
            errorString = NPVorbisBadInputErrorString;
            errorCode = NPVorbisBadInputError;
            break;
        default:
            break;
    }

    NSMutableDictionary * errorDetail = [ NSMutableDictionary dictionary ];
    [ errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
   
    return [ NSError errorWithDomain:NPEngineErrorDomain 
                                code:errorCode
                            userInfo:errorDetail ];
}

@end

