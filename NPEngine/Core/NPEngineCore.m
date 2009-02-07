#import "NPEngineCore.h"
#import "NP.h"

static NPEngineCore * NP_ENGINE_CORE = nil;

@implementation NPEngineCore

+ (NPEngineCore *)instance
{
    NSLock * lock = [[ NSLock alloc ] init ];

    if ( [ lock tryLock ] )
    {
        if ( NP_ENGINE_CORE == nil )
        {
            [[ self alloc ] init ]; // assignment not done here
        }

        [ lock unlock ];
    }

    [ lock release ];

    return NP_ENGINE_CORE;
} 

+ (id)allocWithZone:(NSZone *)zone
{
    NSLock * lock = [[ NSLock alloc ] init ];

    if ( [ lock tryLock ] )
    {
        if (NP_ENGINE_CORE == nil)
        {
            NP_ENGINE_CORE = [ super allocWithZone:zone ];

            [ lock unlock ];
            [ lock release ];

            return NP_ENGINE_CORE;  // assignment and return on first allocation
        }
    }

    [ lock release ];

    return nil; //on subsequent allocation attempts return nil
}

- (id) init
{
    return [ self initWithName:@"NPEngine Core" parent:nil ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
{
    npbasics_initialise();
    npmath_initialise();

    self = [ super init ];

    name = [ newName retain ];
    objectID = crc32_of_pointer(self);

    objectManager = [[ NPObjectManager alloc ] init ];
    logger        = [[ NPLogger        alloc ] initWithName:@"NPEngine Logger" parent:self ];

    NPLOG(@"%@ initialising...", name);

    timer         = [[ NPTimer       alloc ] initWithName:@"NPEngine Timer"        parent:self ];
    pathManager   = [[ NPPathManager alloc ] initWithName:@"NPEngine Path Manager" parent:self ];

    randomNumberGeneratorManager = [[ NPRandomNumberGeneratorManager alloc ] initWithName:@"NPEngine RandomNumberGenerator Manager" parent:self ];
    transformationStateManager   = [[ NPTransformationStateManager   alloc ] initWithName:@"NPEngine Transformation State Manager"  parent:self ];

    NPLOG(@"%@ up and running", name);

    return self;
}

- (void) dealloc
{
    NPLOG(@"");
    NPLOG(@"NP Engine Core Dealloc");

    [ transformationStateManager release ];
    [ randomNumberGeneratorManager release ];
    [ pathManager release ];
    [ timer release ];
    [ logger release ];
    [ objectManager release ];
    [ name release ];

    [ super dealloc ];
}

- (NSString *) name
{
    return name;
}

- (void) setName:(NSString *)newName
{
    if ( name != newName )
    {
        [ name release ];

        name = [ newName retain ];
    }
}

- (NPObject *) parent
{
    return nil;
}

- (void) setParent:(NPObject *)newParent
{
}

- (UInt32) objectID
{
    return objectID;
}

- (NPLogger *)logger
{
    return logger;
}

- (NPTimer *)timer
{
    return timer;
}

- (NPObjectManager *)objectManager
{
    return objectManager;
}

- (NPPathManager *)pathManager
{
    return pathManager;
}

- (NPRandomNumberGeneratorManager *) randomNumberGeneratorManager
{
    return randomNumberGeneratorManager;
}

- (NPTransformationStateManager *)transformationStateManager
{
    return transformationStateManager;
}

- (void) update
{
    [ timer update ];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
} 

- (void)release
{
    //do nothing
} 

- (id)autorelease
{
    return self;
}

@end
