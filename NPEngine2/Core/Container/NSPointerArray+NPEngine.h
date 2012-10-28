#import <Foundation/NSRange.h>
#import <Foundation/NSPointerArray.h>

@interface NSPointerArray (NPEngine)

- (BOOL) containsPointer:(void *)pointer;
- (NSUInteger) indexOfPointerIdenticalTo:(void *)pointer;
- (void) removePointerIdenticalTo:(void *)pointer;
- (void) removePointersInRange:(NSRange)aRange;

@end

