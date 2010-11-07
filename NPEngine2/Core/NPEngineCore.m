#import <Foundation/NSException.h>
#import "NPEngineCore.h"
//#import "NP.h"

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
    logger        = [[ NPLogger        alloc ] init ];

    //NPLOG(@"%@ initialising...", name);

    timer = [[ NPTimer alloc ] initWithName:@"NPEngine Timer" parent:self ];

    localPathManager = 
        [[ NPLocalPathManager alloc ] 
            initWithName:@"NPEngine Local Path Manager"
                  parent:self ];

    transformationState =
        [[ NPTransformationState alloc ]
            initWithName:@"NPEngine Transformation State"
                  parent:self ];

    //NPLOG(@"%@ up and running", name);

    return self;
}

- (void) dealloc
{
    //NPLOG(@"");
    //NPLOG(@"NP Engine Core Dealloc");

    DESTROY(transformationState);
    DESTROY(localPathManager);
    DESTROY(timer);
    DESTROY(logger);
    DESTROY(objectManager);

    [ super dealloc ];
}

- (NSString *) name
{
    return @"NP Engine Core";
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

- (NPLogger *) logger
{
    return logger;
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
    return ULONG_MAX;  //denotes an object that cannot be released
} 

- (void) release
{
    //do nothing
} 

- (id) autorelease
{
    return self;
}

@end
