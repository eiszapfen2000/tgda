#import "NP.h"
#import "RTVCore.h"
#import "RTVMenu.h"

@implementation RTVMenu

- (id) init
{
    return [ self initWithName:@"Menu" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    projection = fm4_alloc_init();
    identity   = fm4_alloc_init();
    fm4_mssss_orthographic_2d_projection_matrix(projection, 0.0f, 1.0f, 0.0f, 1.0f);

    menuEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Menu.cgfx" ];
    scale = [ menuEffect parameterWithName:@"scale" ];

    menuAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"Menu" primaryInputAction:NP_INPUT_KEYBOARD_M ];
    menuActive = NO;

    blendTime = 1.0f;
    currentBlendTime = 0.0f;
    blendStartTime = 0.0f;

    return self;
}

- (void) dealloc
{
    fm4_free(projection);
    fm4_free(identity);

    [ super dealloc ];
}

- (void) update:(Float)frameTime
{
    if ( [ menuAction activated ] == YES )
    {
        if ( menuActive == NO )
        {
            menuActive = YES;
            blendStartTime   = [[[ NP Core ] timer ] totalElapsedTime ];
        }
        else
        {
            menuActive = NO;
        }
    }

    if ( menuActive == YES )
    {
        currentBlendTime += frameTime;
    }
}

- (void) render
{
    if ( menuActive == YES )
    {
        NPTransformationState * trafo = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
        [ trafo setProjectionMatrix:projection ];

        [ menuEffect uploadFloatParameter:scale andValue:currentBlendTime ];
        [ menuEffect activate ];

        

        [ menuEffect deactivate ];

        [ trafo setProjectionMatrix:identity ];
    }
}

@end

