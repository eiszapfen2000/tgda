#import <Foundation/NSObject.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Basics/NpBasics.h"
#import "NPKeyboard.h"
#import "NPMouse.h"
#import "NPInputActions.h"
#import "NPEngineInput.h"

static NPEngineInput * NP_ENGINE_INPUT = nil;

@implementation NPEngineInput

+ (void) initialize
{
	if ( [ NPEngineInput class ] == self )
	{
		[[ self alloc ] init ];
	}
}

+ (NPEngineInput *) instance
{
    return NP_ENGINE_INPUT;
} 

+ (id) allocWithZone:(NSZone *)zone
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
    self = [ super init ];

    objectID = crc32_of_pointer(self);
    keyboard = [[ NPKeyboard alloc ] init ];
    mouse = [[ NPMouse alloc ] init ];
    inputActions = [[ NPInputActions alloc ] init ];

    return self;
}

- (void) dealloc
{
    DESTROY(inputActions);
    DESTROY(mouse);
    DESTROY(keyboard);

    [ super dealloc ];
}

- (NSString *) name
{
    return @"NPEngine Input";
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

- (NPKeyboard *) keyboard
{
    return keyboard;
}

- (NPMouse *) mouse
{
    return mouse;
}

- (NPInputActions *) inputActions
{
    return inputActions;
}

- (void) update
{
    [ mouse update ];
    [ inputActions update ];
}

- (BOOL) isAnythingPressed
{
    return ( [ keyboard isAnyKeyPressed ] || [ mouse isAnyButtonPressed ] );
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
    return UINT_MAX;  //denotes an object that cannot be released
} 

- (oneway void) release
{
    //do nothing
} 

- (id) autorelease
{
    return self;
}

@end

