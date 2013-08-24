#import "NSData+NPEngine.h"

@implementation NSData (NPEngine)

+ (id)dataWithBytesNoCopyNoFree:(void *)bytes
                         length:(NSUInteger)length
{
    return [ NSData dataWithBytesNoCopy:bytes 
                                 length:length
                           freeWhenDone:NO ];
}

@end

