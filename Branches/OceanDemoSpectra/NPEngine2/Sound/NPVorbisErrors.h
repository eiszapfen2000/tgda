#import <Foundation/NSObject.h>

@class NSString;
@class NSError;

extern NSString * const NPVorbisNumberOfChannelsErrorString;

@interface NPVorbisErrors : NSObject

+ (NSError *) vorbisOpenError:(int)error;
+ (NSError *) vorbisReadError:(long)error;

@end
