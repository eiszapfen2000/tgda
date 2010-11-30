#import <Foundation/NSException.h>
#import "Log/NPLogger.h"
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

    timer = [[ NPTimer alloc ] initWithName:@"NPEngine Timer" parent:self ];

    localPathManager = 
        [[ NPLocalPathManager alloc ] 
            initWithName:@"NPEngine Local Path Manager"
                  parent:self ];

    transformationState =
        [[ NPTransformationState alloc ]
            initWithName:@"NPEngine Transformation State"
                  parent:self ];

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

- (void) setName:(NSString *)newName
{

}

- (id <NPPObject>) parent
{
    return nil;
}

- (void) setParent:(id <NPPObject>)newParent
{
}

- (uint32_t) objectID
{
    return objectID;
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
