#import "NSArray+NPPObject.h"

@implementation NSArray (NPPObject)

- (id) objectWithName:(NSString *)name
{
    NSUInteger numberOfObjects = [ self count ];
    for ( NSUInteger i = 0; i < numberOfObjects; i++ )
    {
        id object = [ self objectAtIndex:i ];
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
