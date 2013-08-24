#import <Foundation/NSData.h>

@interface NSData (NPEngine)

+ (id)dataWithBytesNoCopyNoFree:(void *)bytes
                         length:(NSUInteger)length
                               ;

@end
