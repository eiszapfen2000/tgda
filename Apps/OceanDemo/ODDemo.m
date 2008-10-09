#import "Core/Basics/NpBasics.h"

#import "ODDemo.h"

static ODDemo * OD_DEMO = nil;

@implementation ODDemo

+ (ODDemo *)instance
{
    NSLock * lock = [[ NSLock alloc ] init ];

    if ( [ lock tryLock ] )
    {
        if ( OD_DEMO == nil )
        {
            [[ self alloc ] init ]; // assignment not done here
        }

        [ lock unlock ];
    }

    [ lock release ];

    return OD_DEMO;
} 

+ (id)allocWithZone:(NSZone *)zone
{
    NSLock * lock = [[ NSLock alloc ] init ];

    if ( [ lock tryLock ] )
    {
        if (OD_DEMO == nil)
        {
            OD_DEMO = [ super allocWithZone:zone ];

            [ lock unlock ];
            [ lock release ];

            return OD_DEMO;  // assignment and return on first allocation
        }
    }

    [ lock release ];

    return nil; //on subsequent allocation attempts return nil
}

- (id) init
{
    return [ self initWithName:@"Ocean Demo" parent:nil ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super init ];

    objectID = crc32_of_pointer(self);
    name = [ newName retain ];
    //scenes = [[ NSMutableDictionary alloc ] init ];
    currentScene = nil;
    timer = nil;

    return self;
}

- (void) dealloc
{
    [ timer invalidate ];
    TEST_RELEASE(currentScene);
    //[ scenes release ];
    [ name release ];

    [ super dealloc ];
}

- (NSString *) name
{
    return name;
}

- (void) setName:(NSString *)newName
{
    ASSIGN(name,newName);
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

- (ODScene *) currentScene
{
    return currentScene;
}

- (void) setCurrentScene:(ODScene *)newCurrentScene
{
    ASSIGN(currentScene, newCurrentScene);
}

- (void) setupRenderLoop
{
        /*timer = [[ NSTimer alloc ] initWithFireDate:nil
                                           interval:1.0/60.0
                                                  target:self
                                                selector:@selector(updateAndRender:)
                                                userInfo:nil
                                                 repeats:YES ];*/

        timer = [ NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                                  target:self
                                                selector:@selector(updateAndRender:)
                                                userInfo:nil
                                                 repeats:YES ];
}

- (void) updateAndRender:(NSTimer *)timer
{
    [ self update ];
    [ self render ];
}

- (void) update
{
    [ currentScene update ];
}

- (void) render
{
    [ currentScene render ];
}

@end

