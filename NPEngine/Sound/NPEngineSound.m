#import "NPEngineSound.h"
#import "NP.h"

static NPEngineSound * NP_ENGINE_SOUND = nil;

@implementation NPEngineSound

+ (NPEngineSound *)instance
{
    @synchronized(self)
    {
        if ( NP_ENGINE_SOUND == nil )
        {
            [[ self alloc ] init ];
        }
    }

    return NP_ENGINE_SOUND;
} 

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (NP_ENGINE_SOUND == nil)
        {
            NP_ENGINE_SOUND = [ super allocWithZone:zone ];
            return NP_ENGINE_SOUND;
        }
    }

    return nil;
}

- (id) init
{
    return [ self initWithName:@"NP Engine Sound" parent:nil ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
{
    self = [ super init ];

    name = [ newName retain ];
    objectID = crc32_of_pointer(self);

    return self;
}

- (void) dealloc
{
    NPLOG(@"");
    NPLOG(@"NP Engine Sound Dealloc");

    [ name release ];

    [ super dealloc ];
}

- (void) setup
{
    NPLOG(@"NPEngine Sound setup....");

    NPLOG(@"NPEngine Sound ready");
    NPLOG(@"");
}

- (NSString *) name
{
    return name;
}

- (void) setName:(NSString *)newName
{
    ASSIGN(name, newName);
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

- (void) update
{

}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
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

