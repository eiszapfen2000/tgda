#import "ODVariance.h"

@implementation ODVariance

- (id) init
{
    return [ self initWithName:@"ODVariance" ];
}

- (id) initWithName:(NSString *)newName
{
	return [ self initWithName:newName effect:nil ];
}

- (id) initWithName:(NSString *)newName
			 effect:(NPEffect *)newEffect
{
	self = [ super initWithName:newName ];

	return self;
}

- (void) dealloc
{
	[ super dealloc ];
}

@end
