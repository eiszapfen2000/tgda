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
            NSString * objectFileName = [ object fileName ];

            if ( objectFileName != nil && [ objectFileName isEqual:fileName ] == YES )
            {
                return object;
            }
        }
    }

    return nil;
}

@end

