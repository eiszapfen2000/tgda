#import "NSPointerArray+NPPPersistentObject.h"

@implementation NSPointerArray (NPPPersistentObject)

- (id <NPPPersistentObject>) pointerWithFileName:(NSString *)fileName
{
    NSUInteger numberOfPointers = [ self count ];
    for ( NSUInteger i = 0; i < numberOfPointers; i++ )
    {
        id object = [ self pointerAtIndex:i ];
        if ( [ object conformsToProtocol:@protocol(NPPPersistentObject) ] == YES )
        {
            if ( [[ object fileName ] isEqual:fileName ] == YES )
            {
                return object;
            }
        }
    }

    return nil;
}

@end

