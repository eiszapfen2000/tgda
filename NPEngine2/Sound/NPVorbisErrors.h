@class NSError;

@interface NPVorbisErrors

+ (NSError *) vorbisOpenError:(int)error;
+ (NSError *) vorbisReadError:(long)error;

@end
