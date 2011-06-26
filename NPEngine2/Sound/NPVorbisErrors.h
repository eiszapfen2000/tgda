@class NSString;
@class NSError;

/*
// vorbis open errors
NSString * const NPVorbisReadErrorString;
NSString * const NPVorbisNotVorbisErrorString;
NSString * const NPVorbisVersionMismatchErrorString;
NSString * const NPVorbisBadHeaderErrorString;
NSString * const NPVorbisInternalErrorString;

// vorbis read errors
NSString * const NPVorbisHoleErrorString;
NSString * const NPVorbisBadLinkErrorString;
NSString * const NPVorbisBadInputErrorString;
*/

extern NSString * const NPVorbisNumberOfChannelsErrorString;

@interface NPVorbisErrors

+ (NSError *) vorbisOpenError:(int)error;
+ (NSError *) vorbisReadError:(long)error;

@end
