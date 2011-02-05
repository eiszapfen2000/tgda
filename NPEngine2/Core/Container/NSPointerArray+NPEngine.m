#import "NSPointerArray+NPEngine.h"

@implementation NSPointerArray (NPEngine)

- (BOOL) containsPointer:(void *)pointer
{
    NSUInteger numberOfPointers = [ self count ];
    for ( NSUInteger i = 0; i < numberOfPointers; i++ )
    {
        if ( [ self pointerAtIndex:i ] == pointer )
        {
            return YES;
        }
    }

    return NO;
}

- (NSUInteger) indexOfPointerIdenticalTo:(void *)pointer
{
    NSUInteger numberOfPointers = [ self count ];
    for ( NSUInteger i = 0; i < numberOfPointers; i++ )
    {
        if ( [ self pointerAtIndex:i ] == pointer )
        {
            return i;
        }
    }

    return NSNotFound;
}

- (void) removePointerIdenticalTo:(void *)pointer
{
    NSUInteger index = [ self indexOfPointerIdenticalTo:pointer ];
    if ( index != NSNotFound )
    {
        [ self removePointerAtIndex:index ];
    }
}

@end
