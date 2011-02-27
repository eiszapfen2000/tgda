#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "NPEngineCore.h"

static NPEngineCore * NP_ENGINE_CORE = nil;

@implementation NPEngineCore

+ (void) initialize
{
	if ( [ NPEngineCore class ] == self )
	{
		[[ self alloc ] init ];
	}
}

+ (NPEngineCore *) instance
{
    return NP_ENGINE_CORE;
}

+ (id) allocWithZone:(NSZone*)zone
{
    if ( self != [ NPEngineCore class ] )
    {
        [ NSException raise:NSInvalidArgumentException
	                 format:@"Illegal attempt to subclass NPEngineCore as %@", self ];
    }

    if ( NP_ENGINE_CORE == nil )
    {
        NP_ENGINE_CORE = [ super allocWithZone:zone ];
    }

    return NP_ENGINE_CORE;
}

- (id) init
{
    npbasics_initialise();
    npmath_initialise();

    self = [ super init ];
    objectID = crc32_of_pointer(self);

    objectManager = [[ NPObjectManager alloc ] init ];

    NPLOG(@"NPEngine Core initialising...");

    timer = [[ NPTimer alloc ] initWithName:@"NPEngine Timer" ];

    localPathManager = 
        [[ NPLocalPathManager alloc ] 
            initWithName:@"NPEngine Local Path Manager" ];

    transformationState =
        [[ NPTransformationState alloc ]
            initWithName:@"NPEngine Transformation State" ];

    NPLOG(@"NPEngine Core up and running.");

    return self;
}

- (void) dealloc
{
    DESTROY(transformationState);
    DESTROY(localPathManager);
    DESTROY(timer);
    DESTROY(objectManager);

    [ super dealloc ];
}

- (NSString *) name
{
    return @"NPEngine Core";
}

- (uint32_t) objectID
{
    return objectID;
}

- (void) setName:(NSString *)newName
{

}

- (void) setObjectID:(uint32_t)newObjectID
{

}

- (NPTimer *) timer
{
    return timer;
}

- (NPObjectManager *) objectManager
{
    return objectManager;
}

- (NPLocalPathManager *) localPathManager
{
    return localPathManager;
}

- (NPTransformationState *) transformationState
{
    return transformationState;
}

- (void) update
{
    [ timer update ];
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return ULONG_MAX;
} 

- (void) release
{

} 

- (id) autorelease
{
    return self;
}

@end
