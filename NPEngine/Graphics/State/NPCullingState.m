#import "NPCullingState.h"
#import "Core/NPEngineCore.h"

@implementation NPCullingState

- (id) init
{
    return [ self initWithName:@"NP Culling State" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    return [ self initWithName:newName parent:nil configuration:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent configuration:(NPStateConfiguration *)newConfiguration
{
    self = [ super initWithName:newName parent:newParent configuration:newConfiguration ];

    enabled          = NO;
    defaultEnabled   = NO;
    currentlyEnabled = YES;

    cullFace        = NP_BACK_FACE;
    defaultCullFace = NP_BACK_FACE;
    currentCullFace = NP_FRONT_FACE;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) enabled
{
    return enabled;
}

- (void) setEnabled:(BOOL)newEnabled
{
    if ( [ super changeable ] == YES )
    {
        enabled = newEnabled;
    }
}

- (BOOL) defaultEnabled
{
    return defaultEnabled;
}

- (void) setDefaultEnabled:(BOOL)newDefaultEnabled
{
    defaultEnabled = newDefaultEnabled;
}

- (NpState) cullFace
{
    return cullFace;
}

- (void) setCullFace:(NpState)newCullFace
{
    if ( [ super changeable ] == YES )
    {
        cullFace = newCullFace;
    }
}

- (NpState) defaultCullFace
{
    return defaultCullFace;
}

- (void) setDefaultCullFace:(NpState)newDefaultCullFace
{
    defaultCullFace = newDefaultCullFace;
}

- (void) activate
{
    if ( [ super changeable ] == NO )
    {
         return;
    }

    if ( currentlyEnabled != enabled )
    {
        currentlyEnabled = enabled;

        if ( enabled == YES )
        {
            glEnable(GL_CULL_FACE);
        }
        else
        {
            glDisable(GL_CULL_FACE);
        }
    }

    if ( enabled == YES )
    {
        GLenum face = GL_BACK;

        if ( currentCullFace != cullFace )
        {
            currentCullFace = cullFace;

            switch ( cullFace )
            {
                case NP_FRONT_FACE : { face = GL_FRONT; break; }
                case NP_BACK_FACE  : { face = GL_BACK;  break; }
                default: { NPLOG_ERROR(@"Unknown cull face parameter"); break; }
            }

            glCullFace(face);
        }
    }
}

- (void) deactivate
{
    if ( [ super changeable ] == YES )
    {
        [ self reset ];
        [ self activate ];
    }
}

- (void) reset
{
    if ( [ super changeable ] == YES )
    {
        enabled  = defaultEnabled;
        cullFace = defaultCullFace;
    }
}


@end
