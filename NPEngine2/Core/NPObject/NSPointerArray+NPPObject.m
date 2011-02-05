#import "NSPointerArray+NPPObject.h"

@implementation NSPointerArray (NPPObject)

- (id) pointerWithName:(NSString *)name
{
    NSUInteger numberOfPointers = [ self count ];
    for ( NSUInteger i = 0; i < numberOfPointers; i++ )
    {
        id object = [ self pointerAtIndex:i ];
        if ( [ object conformsToProtocol:@protocol(NPPObject) ] == YES )
        {
            if ( [[ object name ] isEqual:name ] == YES )
            {
                return object;
            }
        }
    }

    return nil;
}

@end

