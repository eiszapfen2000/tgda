#import "NSArray+NPPPersistentObject.h"

@implementation NSArray (NPPPersistentObject)

- (id <NPPPersistentObject>) objectWithFileName:(NSString *)fileName
{
    NSUInteger numberOfObjects = [ self count ];
    for ( NSUInteger i = 0; i < numberOfObjects; i++ )
    {
        id object = [ self objectAtIndex:i ];
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
