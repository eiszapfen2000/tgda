#import "NPTextureBindingStateManager.h"
#import "NPTextureBindingState.h"

@implementation NPTextureBindingStateManager

- (id) init
{
    return [ self initWithName:@"NPEngine Core Texture Binding State" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    textureBindingStates = [ [ NSMutableArray alloc ] init ];
    currentTextureBindingState = nil;

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(currentTextureBindingState);
    [ textureBindingStates release ];

    [ super dealloc ];
}

- (void) setup
{
    NPTextureBindingState * textureBindingState = [[ NPTextureBindingState alloc ] initWithName:@"Default Texture Binding State" parent:self ];
    [ textureBindingStates addObject:textureBindingState ];
    [ self setCurrentTextureBindingState:textureBindingState ];
    [ textureBindingState release ];
}

- (NPTextureBindingState *)currentTextureBindingState
{
    return currentTextureBindingState;
}

- (void) setCurrentTextureBindingState:(NPTextureBindingState *)newCurrentTextureBindingState
{
    if ( currentTextureBindingState != newCurrentTextureBindingState )
    {
        [ currentTextureBindingState release ];
        currentTextureBindingState = [ newCurrentTextureBindingState retain ];
    }
}

- (NPTextureBindingState *) createTextureBindingState
{
    NPTextureBindingState * textureBindingState = [ [ NPTextureBindingState alloc ] initWithName:@"" parent:self ];
    [ textureBindingStates addObject:textureBindingState ];
    [ textureBindingState release ];

    return textureBindingState;
}

@end
