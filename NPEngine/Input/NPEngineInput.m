#import <AppKit/NSEvent.h>
#import "NPEngineInput.h"
#import "NP.h"

static NPEngineInput * NP_ENGINE_INPUT = nil;

@implementation NPEngineInput

+ (void) initialize
{
	if ( [ NPEngineInput class ] == self )
	{
		[[ self alloc ] init ];
	}
}

+ (NPEngineInput *)instance
{
    return NP_ENGINE_INPUT;
} 

+ (id)allocWithZone:(NSZone *)zone
{
    if ( self != [ NPEngineInput class ] )
    {
        [ NSException raise:NSInvalidArgumentException
	                 format:@"Illegal attempt to subclass NPEngineInput as %@", self ];
    }

    if ( NP_ENGINE_INPUT == nil )
    {
        NP_ENGINE_INPUT = [ super allocWithZone:zone ];
    }

    return NP_ENGINE_INPUT;
}

- (id) init
{
    return [ self initWithName:@"NP Engine Input" parent:nil ];
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

    keyboard = [[ NPKeyboard alloc ] initWithName:@"NP Engine Input Keyboard" parent:self ];
    mouse = [[ NPMouse alloc ] initWithName:@"NP Engine Input Mouse" parent:self ];

    inputActions = [[ NPInputActions alloc ] initWithName:@"NP Engine Input Actions" parent:self ];

    return self;
}

- (void) dealloc
{
    NPLOG(@"");
    NPLOG(@"NP Engine Input Dealloc");

    [ inputActions release ];
    [ mouse release ];
    [ keyboard release ];
    [ name release ];

    [ super dealloc ];
}

- (void) setup
{
    NPLOG(@"NPEngine Input setup....");

    NPLOG(@"NPEngine Input ready");
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

- (NPKeyboard *) keyboard
{
    return keyboard;
}

- (NPMouse *) mouse
{
    return mouse;
}

- (id) inputActions
{
    return inputActions;
}

// updates keyboard and mouse states
- (void) processEvent:(NSEvent *)event
{
    UInt eventMask = NSEventMaskFromType([ event type ]);

    if ( eventMask & GSKeyEventMask )
    {
        [ keyboard processEvent:event ];
    }

    if ( eventMask & GSMouseEventMask )
    {
        [ mouse processEvent:event ];
    }
}

- (void) update
{
    [ mouse update ];
    [ inputActions update ];
}

- (BOOL) isAnythingPressed
{
    BOOL mouseButtonPressed = [ mouse isAnyButtonPressed ];
    BOOL keyPressed = [ keyboard isAnyKeyPressed ];

    return ( mouseButtonPressed || keyPressed );
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

